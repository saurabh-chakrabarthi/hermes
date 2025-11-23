#!/bin/bash
set -e

echo "=== Setting up Hermes Payment Portal ==="

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --fix-missing || echo "Warning: apt upgrade had issues, continuing..."

# Install Node.js 18.x and Java 17
echo "Installing Node.js and Java..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs git openjdk-17-jdk maven

echo "Node.js: $(node -v)"
echo "NPM: $(npm -v)"
echo "Java: $(java -version 2>&1 | head -1)"
echo "Maven: $(mvn -version | head -1)"

# Clone repository
cd /home/ubuntu
rm -rf payment-portal
git clone https://github.com/saurabh-chakrabarthi/hermes.git payment-portal
chown -R ubuntu:ubuntu /home/ubuntu/payment-portal

# ===== Setup Node.js Server =====
echo "Setting up Node.js server..."
cd /home/ubuntu/payment-portal/server
npm install

cat > .env << 'EOF'
PORT=9292
NODE_ENV=production
EOF

cat > /etc/systemd/system/payment-server.service << 'EOF'
[Unit]
Description=Hermes Payment Server (Node.js)
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/server
EnvironmentFile=/home/ubuntu/payment-portal/server/.env
ExecStart=/usr/bin/node server-simple.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable payment-server
systemctl start payment-server

# ===== Setup Spring Boot Client =====
echo "Building Spring Boot client..."
cd /home/ubuntu/payment-portal/client
su - ubuntu -c "cd /home/ubuntu/payment-portal/client && mvn clean package -DskipTests"

cat > /etc/systemd/system/payment-client.service << 'EOF'
[Unit]
Description=Hermes Payment Client (Spring Boot)
After=network.target payment-server.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/payment-portal/client
Environment="PAYMENT_SERVER_URL=http://localhost:9292"
ExecStart=/usr/bin/java -jar target/payment-client-1.0.0.jar --server.port=8080
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable payment-client
systemctl start payment-client

# ===== Verify Services =====
echo "Waiting for services to start..."
sleep 10

if systemctl is-active --quiet payment-server; then
    echo "✅ Node.js server started successfully"
else
    echo "❌ Node.js server failed"
    journalctl -u payment-server -n 20 --no-pager
fi

if systemctl is-active --quiet payment-client; then
    echo "✅ Spring Boot client started successfully"
else
    echo "❌ Spring Boot client failed"
    journalctl -u payment-client -n 20 --no-pager
fi

echo "=== Setup Complete ==="
echo "Node.js Server: http://$(curl -s ifconfig.me):9292"
echo "Spring Boot Client: http://$(curl -s ifconfig.me):8080"
