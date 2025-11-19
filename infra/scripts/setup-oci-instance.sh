#!/bin/bash

echo "Setting up OCI instance for Ruby 3 + Hermes"

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ruby 3 & dependencies
sudo apt install -y ruby-full ruby-dev build-essential sqlite3 libsqlite3-dev git curl

# Install bundler
sudo gem install bundler

# Ensure app directory exists
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone repo (only if empty)
if [ ! -d "/home/ubuntu/payment-portal/.git" ]; then
    git clone https://github.com/saurabh-chakrabarthi/hermes.git /home/ubuntu/payment-portal
fi

cd /home/ubuntu/payment-portal/server

# Install gems
bundle install || exit 1

# DB setup (only if your project actually uses migrations)
if bundle exec rake -T | grep db:migrate >/dev/null; then
    bundle exec rake db:create db:migrate
fi

# Create systemd service
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Payment Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
ExecStart=/usr/bin/env bundle exec rackup config.ru -p 9292 -o 0.0.0.0
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl restart payment-server

# Open firewall port
sudo ufw allow 9292

echo "Ruby: $(ruby -v)"
echo "Bundler: $(bundle -v)"

sleep 5
if sudo systemctl is-active --quiet payment-server; then
    echo "🚀 Payment server is running at http://129.213.125.13:9292"
else
    echo "❌ Service failed. Logs:"
    sudo journalctl -u payment-server --no-pager -l
fi

echo ""
echo "Next steps:"
echo "1. Add your SSH private key to GitHub repository secrets as ORACLE_SSH_KEY"
echo "2. Push your code to trigger GitHub Actions deployment"