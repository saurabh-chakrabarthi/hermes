#!/bin/bash
set -e

echo "=== Setting up Docker Environment for Hermes Payment Portal ==="

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --fix-missing || echo "Warning: apt upgrade had issues, continuing..."

# Install Docker
echo "Installing Docker..."
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin iptables-persistent

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Remove OCI default iptables REJECT rules
echo "Removing OCI default firewall rules..."
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
netfilter-persistent save

# Enable Docker service
systemctl enable docker
systemctl start docker

# Create deployment directory
mkdir -p /opt/hermes
cd /opt/hermes

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  payment-server:
    image: ghcr.io/GITHUB_OWNER/hermes-payment-server:latest
    container_name: payment-server
    ports:
      - "9292:9292"
    environment:
      - PORT=9292
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:9292/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  payment-dashboard:
    image: ghcr.io/GITHUB_OWNER/hermes-payment-dashboard:latest
    container_name: payment-dashboard
    ports:
      - "8080:8080"
    environment:
      - PAYMENT_SERVER_URL=http://payment-server:9292
    depends_on:
      - payment-server
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
EOF

# Replace GITHUB_OWNER placeholder
sed -i "s|GITHUB_OWNER|${GITHUB_OWNER}|g" docker-compose.yml

# Create systemd service for docker-compose
cat > /etc/systemd/system/hermes-docker.service << 'EOF'
[Unit]
Description=Hermes Payment Portal Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/hermes
ExecStartPre=/usr/bin/docker compose pull
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable hermes-docker

# Wait for Docker to be ready
sleep 5

# Pull and start containers
echo "Pulling Docker images..."
docker compose pull || echo "Warning: Failed to pull images, will retry on service start"

echo "Starting services..."
systemctl start hermes-docker

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Verify services
if docker ps | grep -q payment-server; then
    echo "✅ Payment server container running"
else
    echo "❌ Payment server container failed"
    docker logs payment-server 2>&1 | tail -20
fi

if docker ps | grep -q payment-dashboard; then
    echo "✅ Payment dashboard container running"
else
    echo "❌ Payment dashboard container failed"
    docker logs payment-dashboard 2>&1 | tail -20
fi

echo "=== Setup Complete ==="
echo "Node.js Server: http://$(curl -s ifconfig.me):9292"
echo "Spring Boot Dashboard: http://$(curl -s ifconfig.me):8080"
