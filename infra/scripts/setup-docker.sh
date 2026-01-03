#!/bin/bash
set -e

echo "=== Setting up Docker Compose for Hermes Payment Portal ==="

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --fix-missing || echo "Warning: apt upgrade had issues, continuing..."

# Disable unattended upgrades to save memory
systemctl stop unattended-upgrades || true
systemctl disable unattended-upgrades || true

# Install Docker
echo "Installing Docker..."
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Remove OCI default iptables REJECT rules
echo "Removing OCI default firewall rules..."
apt-get install -y iptables-persistent
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
netfilter-persistent save

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Download docker-compose.yml
echo "Downloading application files..."
REPO_URL="https://raw.githubusercontent.com/${GITHUB_OWNER}/hermes/main"
curl -fsSL "$REPO_URL/docker-compose.yml" -o docker-compose.yml

# Download MongoDB properties
curl -fsSL "$REPO_URL/infra/mongodb.properties" -o mongodb.properties

# Load MongoDB properties and create .env file
source mongodb.properties
cat > .env << EOF
MONGODB_USER=${MONGODB_USER}
MONGODB_PASSWORD=${MONGODB_PASSWORD}
MONGODB_CLUSTER=${MONGODB_CLUSTER}
MONGODB_DATABASE=${MONGODB_DATABASE}
EOF

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/app

# Login to GitHub Container Registry
echo "Logging in to GitHub Container Registry..."
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u ${GITHUB_OWNER} --password-stdin

# Pull images
echo "Pulling Docker images..."
docker pull ghcr.io/${GITHUB_OWNER}/hermes-payment-server:latest
docker pull ghcr.io/${GITHUB_OWNER}/hermes-payment-dashboard-micronaut:latest

# Start services
echo "Starting services..."
cd /home/ubuntu/app
docker compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Show status
docker compose ps
docker compose logs --tail=50

echo ""
echo "=== Setup Complete ==="
echo "Payment Server: http://$(curl -s ifconfig.me):9292"
echo "Dashboard: http://$(curl -s ifconfig.me):8080"
