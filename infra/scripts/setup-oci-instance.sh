#!/bin/bash

# Setup script for OCI instance to prepare for GitHub Actions deployment

echo "Setting up OCI instance with Ruby version management..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y build-essential sqlite3 libsqlite3-dev git curl

# Install rbenv and ruby-build
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add rbenv to PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Install Ruby 2.7.0 (compatible with older gems)
rbenv install 2.7.0
rbenv global 2.7.0

# Install bundler
gem install bundler

# Create application directory
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone the repository
cd /home/ubuntu
if [ -d "payment-portal" ]; then
    rm -rf payment-portal
fi
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal

# Setup server with proper Ruby version
cd server
~/.rbenv/shims/bundle install
~/.rbenv/shims/bundle exec rake db:create db:migrate

# Create systemd service file
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Payment Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
Environment=PATH=/home/ubuntu/.rbenv/shims:/home/ubuntu/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/home/ubuntu/.rbenv/shims/bundle exec rackup config.ru -p 9292 -o 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl start payment-server

# Open firewall port
sudo ufw allow 9292

# Check if server is running
sleep 5
if sudo systemctl is-active --quiet payment-server; then
    echo "✅ SUCCESS! Payment server is running"
    echo "Server accessible at: http://129.213.125.13:9292"
else
    echo "❌ Server failed to start. Checking logs..."
    sudo journalctl -u payment-server --no-pager -l
fi

echo ""
echo "Next steps:"
echo "1. Add your SSH private key to GitHub repository secrets as ORACLE_SSH_KEY"
echo "2. Push your code to trigger GitHub Actions deployment"