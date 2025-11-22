#!/bin/bash

echo "Setting up basic OCI instance with Node.js server"

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x and Java 17
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs git curl openjdk-17-jdk maven

# Clone repo and setup
cd /home/ubuntu
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal/server

# Install dependencies
npm install

# Create simple environment file (no database)
cat > .env << EOF
PORT=9292
NODE_ENV=production
EOF

# Create systemd service
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Hermes Payment Portal Node.js Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
EnvironmentFile=/home/ubuntu/payment-portal/server/.env
ExecStart=/usr/bin/node server-simple.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl start payment-server

# Open firewall
sudo ufw allow 9292

echo "✅ Basic setup complete"
echo "Node.js: $(node -v)"
echo "Service status: $(sudo systemctl is-active payment-server)"