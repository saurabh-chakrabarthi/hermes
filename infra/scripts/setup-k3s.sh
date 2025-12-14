#!/bin/bash
set -e

echo "=== Setting up k3s Kubernetes for Hermes Payment Portal ==="

# Update system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y --fix-missing || echo "Warning: apt upgrade had issues, continuing..."

# Install dependencies
apt-get install -y curl iptables-persistent

# Remove OCI default iptables REJECT rules
echo "Removing OCI default firewall rules..."
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
iptables -D FORWARD -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
netfilter-persistent save

# Install k3s
echo "Installing k3s..."
curl -sfL https://get.k3s.io | sh -s - \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --node-name hermes-node

# Wait for k3s to be ready
echo "Waiting for k3s to be ready..."
sleep 30

# Set up kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube
chmod 600 /home/ubuntu/.kube/config

# Create namespace
kubectl create namespace hermes || true

# Create secret for DB password
kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_ROOT_PASSWORD="${DB_PASSWORD}" \
  --namespace=hermes || true

# Download K8s manifests from GitHub
echo "Downloading Kubernetes manifests..."
mkdir -p /home/ubuntu/k8s
cd /home/ubuntu/k8s

REPO_URL="https://raw.githubusercontent.com/${GITHUB_OWNER}/hermes/main/infra/k8s"
for file in mysql-service mysql-statefulset redis-service redis-deployment \
            payment-server-configmap payment-server-service payment-server-deployment \
            payment-dashboard-service payment-dashboard-deployment; do
  curl -fsSL "$REPO_URL/$file.yaml" -o "$file.yaml"
done

# Replace GITHUB_OWNER placeholder
sed -i "s|GITHUB_OWNER|${GITHUB_OWNER}|g" payment-server-deployment.yaml
sed -i "s|GITHUB_OWNER|${GITHUB_OWNER}|g" payment-dashboard-deployment.yaml

# Apply manifests in order
echo "Applying Kubernetes manifests..."
kubectl apply -f mysql-service.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f redis-service.yaml
kubectl apply -f redis-deployment.yaml
sleep 30
kubectl apply -f payment-server-configmap.yaml
kubectl apply -f payment-server-service.yaml
kubectl apply -f payment-server-deployment.yaml
kubectl apply -f payment-dashboard-service.yaml
kubectl apply -f payment-dashboard-deployment.yaml

# Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n hermes --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=redis -n hermes --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=payment-server -n hermes --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=payment-dashboard -n hermes --timeout=300s || true

# Show status
echo "=== k3s Setup Complete ==="
kubectl get pods -n hermes
kubectl get svc -n hermes

echo ""
echo "Access services:"
echo "Node.js Server: http://$(curl -s ifconfig.me):30092"
echo "Spring Boot Dashboard: http://$(curl -s ifconfig.me):30080"
