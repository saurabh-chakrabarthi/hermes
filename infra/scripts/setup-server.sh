#!/bin/bash

echo "Setting up OCI instance with Node.js server, MySQL, and Redis"

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x and Java 17
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs git curl redis-server mysql-client openjdk-17-jdk maven

# Ensure app directory exists
sudo mkdir -p /home/ubuntu/payment-portal
sudo chown ubuntu:ubuntu /home/ubuntu/payment-portal

# Clone repo
cd /home/ubuntu
rm -rf payment-portal
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
cd payment-portal/server

# Install Node.js dependencies
npm install

# Configure Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Wait for MySQL to be ready and create database
echo "Waiting for MySQL to be ready..."
sleep 30

# Create database
mysql -h ${db_host} -u admin -p'${db_password}' -e "CREATE DATABASE IF NOT EXISTS hermes_payments;"

# Create environment file
cat > .env << EOF
PORT=9292
DB_HOST=${db_host}
DB_USER=admin
DB_PASSWORD=${db_password}
DB_NAME=hermes_payments
DB_PORT=3306
REDIS_URL=redis://localhost:6379
NODE_ENV=production
EOF

# Create systemd service
sudo tee /etc/systemd/system/payment-server.service > /dev/null <<EOF
[Unit]
Description=Hermes Payment Portal Node.js Server
After=network.target mysql.service redis.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
EnvironmentFile=/home/ubuntu/payment-portal/server/.env
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-server
sudo systemctl start payment-server

# Setup Java Spring Boot Client
cd /home/ubuntu/payment-portal/client

# Build Java client
mvn clean package -DskipTests

# Create Java client systemd service
sudo tee /etc/systemd/system/payment-client.service > /dev/null <<EOF
[Unit]
Description=Hermes Payment Client Spring Boot
After=network.target payment-server.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/client
Environment=PAYMENT_SERVER_URL=http://localhost:9292
ExecStart=/usr/bin/java -jar target/payment-booking-client-1.0.0.jar --server.port=8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable payment-client
sudo systemctl start payment-client

# Open firewall ports
sudo ufw allow 9292
sudo ufw allow 8080

echo "Node.js: $(node -v)"
echo "NPM: $(npm -v)"
echo "Redis: $(redis-server --version)"

sleep 5
if sudo systemctl is-active --quiet payment-server; then
    echo "✅ Hermes Payment Portal (Node.js) running at http://129.213.125.13:9292"
    echo "Test: curl http://129.213.125.13:9292/health"
else
    echo "❌ Server failed:"
    sudo journalctl -u payment-server --no-pager -l
fi

echo ""
echo "Services status:"
echo "Payment Server: $(sudo systemctl is-active payment-server)"
echo "Payment Client: $(sudo systemctl is-active payment-client)"
echo "Redis: $(sudo systemctl is-active redis-server)"
echo "MySQL connection: mysql -h ${db_host} -u admin -p"
echo ""
echo "Access URLs:"
echo "Payment Server: http://$(curl -s ifconfig.me):9292"
echo "Client Dashboard: http://$(curl -s ifconfig.me):8080"