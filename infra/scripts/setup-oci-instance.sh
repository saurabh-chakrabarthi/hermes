#!/bin/bash

# Setup script for OCI instance to prepare for GitHub Actions deployment

echo "Setting up OCI instance for GitHub Actions deployment..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y ruby ruby-dev build-essential sqlite3 libsqlite3-dev git

# Install bundler
sudo gem install bundler

# Create application directory
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone the repository (replace with your actual repo URL)
cd /home/ubuntu
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal

# Setup server
cd server
bundle install
bundle exec rake db:create db:migrate

# Copy systemd service file
sudo cp ../infra/scripts/payment-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl start payment-server

# Open firewall port
sudo ufw allow 9292

# Setup SSH key for GitHub Actions (you'll need to add your private key to GitHub secrets)
echo "Setup complete!"
echo "Server should be running on http://129.213.125.13:9292"
echo ""
echo "Next steps:"
echo "1. Add your SSH private key to GitHub repository secrets as ORACLE_SSH_KEY"
echo "2. Push your code to trigger GitHub Actions deployment"