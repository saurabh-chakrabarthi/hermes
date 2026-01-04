#!/bin/bash
# Quick fix script to run on the VM
# Run this as: sudo bash fix-deployment.sh

set -e

echo "=== Fixing Hermes Deployment ==="

cd /home/ubuntu/app

# Create proper .env file with actual values
# Replace these with your actual MongoDB credentials
cat > .env << 'EOF'
MONGODB_USER=your_mongodb_user
MONGODB_PASSWORD=your_mongodb_password
MONGODB_CLUSTER=your_cluster.mongodb.net
MONGODB_DATABASE=hermes_payments
GITHUB_OWNER=saurabhchako89
EOF

echo "Created .env file"

# Download fixed docker-compose.yml
curl -fsSL "https://raw.githubusercontent.com/saurabh-chakrabarthi/hermes/main/infra/docker/docker-compose.yml" -o docker-compose.yml

echo "Downloaded docker-compose.yml"

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/app

# Login to GHCR (you'll need to provide token)
echo "Login to GitHub Container Registry..."
echo "Enter your GitHub token:"
read -s GITHUB_TOKEN
echo "${GITHUB_TOKEN}" | docker login ghcr.io -u saurabh-chakrabarthi --password-stdin

# Start services
echo "Starting services..."
docker compose up -d

# Wait and check
sleep 10
docker compose ps
docker compose logs

echo ""
echo "=== Fix Complete ==="
echo "Check status: docker compose ps"
echo "View logs: docker compose logs -f"