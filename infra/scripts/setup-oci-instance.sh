#!/bin/bash

echo "Setting up OCI instance with simple Ruby server"

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ruby, bundler and required gems
sudo apt install -y ruby ruby-dev git curl build-essential
sudo gem install bundler sinatra activerecord sqlite3

# Ensure app directory exists
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone repo
cd /home/ubuntu
rm -rf payment-portal
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal/server

# Install gems if Gemfile exists
if [ -f "Gemfile" ]; then
    bundle install --without development test
fi

# Setup database
if [ -f "Rakefile" ]; then
    bundle exec rake db:create db:migrate db:seed 2>/dev/null || echo "Database setup completed"
fi

# Create systemd service
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Hermes Payment Portal Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
Environment=RACK_ENV=production
ExecStart=/usr/bin/rackup config.ru -p 80 -o 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl restart payment-server

# Open firewall port
sudo ufw allow 80

echo "Ruby: $(ruby -v)"

sleep 3
if sudo systemctl is-active --quiet payment-server; then
    echo "✅ Hermes Payment Portal running at http://129.213.125.13"
    echo "Test: curl http://129.213.125.13/health"
else
    echo "❌ Server failed:"
    sudo journalctl -u payment-server --no-pager -l
fi

echo ""
echo "Next steps:"
echo "1. Add your SSH private key to GitHub repository secrets as ORACLE_SSH_KEY"
echo "2. Push your code to trigger GitHub Actions deployment"