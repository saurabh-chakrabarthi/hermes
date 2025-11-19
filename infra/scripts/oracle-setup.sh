#!/bin/bash

# Oracle Cloud VM Setup Script
# Run this on your Oracle Cloud VM

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ruby and dependencies
sudo apt install -y ruby ruby-dev build-essential sqlite3 libsqlite3-dev git

# Install bundler
sudo gem install bundler

# Create app directory
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone repository
cd /home/ubuntu/payment-portal
git clone https://github.com/saurabh-chakrabarthi/hermes.git .

# Install gems
cd server
bundle install

# Setup database
bundle exec rake db:create db:migrate

# Create systemd service
sudo cp infra/scripts/payment-server.service /etc/systemd/system/

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl start payment-server

# Open firewall port
sudo ufw allow 9292

echo "Setup complete! Server running on port 9292"