#!/bin/bash

# Temporary setup script you can run immediately on your OCI instance
# This doesn't depend on the repo being pushed yet

echo "Setting up OCI instance..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y ruby ruby-dev build-essential sqlite3 libsqlite3-dev git

# Install bundler
sudo gem install bundler

# Create application directory
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone the repository
cd /home/ubuntu
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal

# Setup server
cd server
bundle install
bundle exec rake db:create db:migrate

# Create systemd service file directly
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Payment Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
ExecStart=/usr/local/bin/bundle exec ruby -S rackup config.ru -p 9292 -o 0.0.0.0
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

echo "Setup complete!"
echo "Server should be running on http://129.213.125.13:9292"