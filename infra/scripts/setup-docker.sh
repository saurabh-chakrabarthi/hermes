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

# Create .env file with secrets
cat > .env << EOF
DB_PASSWORD=${DB_PASSWORD}
GITHUB_REPOSITORY_OWNER=${GITHUB_OWNER}
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=$${DB_PASSWORD}
      - MYSQL_DATABASE=hermes_payments
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    command: --default-authentication-plugin=mysql_native_password

  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  payment-server:
    image: ghcr.io/$${GITHUB_REPOSITORY_OWNER}/hermes-payment-server:latest
    container_name: payment-server
    ports:
      - "9292:9292"
    environment:
      - PORT=9292
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_USER=root
      - DB_PASSWORD=$${DB_PASSWORD}
      - DB_NAME=hermes_payments
      - REDIS_URL=redis://redis:6379
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:9292/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  payment-dashboard:
    image: ghcr.io/$${GITHUB_REPOSITORY_OWNER}/hermes-payment-dashboard:latest
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

volumes:
  mysql_data:
  redis_data:
EOF

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

# Initialize MySQL schema
echo "Waiting for MySQL to be ready..."
sleep 20

# Create schema initialization script
cat > init-schema.sql << 'SQLEOF'
CREATE DATABASE IF NOT EXISTS hermes_payments;
USE hermes_payments;

CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(36) PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    amount_received DECIMAL(10, 2) NOT NULL,
    school VARCHAR(255),
    sender_full_name VARCHAR(255),
    country_from VARCHAR(100),
    sender_address TEXT,
    currency_from VARCHAR(10),
    student_id VARCHAR(100),
    status VARCHAR(50) DEFAULT 'PENDING',
    validation_status VARCHAR(50) DEFAULT 'PENDING',
    fee_percentage DECIMAL(5, 2),
    fee_amount DECIMAL(10, 2),
    final_amount DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_reference (reference),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS validation_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id VARCHAR(36) NOT NULL,
    check_type VARCHAR(100) NOT NULL,
    check_result VARCHAR(50) NOT NULL,
    check_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    INDEX idx_payment_id (payment_id),
    INDEX idx_check_type (check_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id VARCHAR(36),
    action VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    user_agent TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_id (payment_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO payments (id, reference, name, email, amount, amount_received, school, sender_full_name, country_from, sender_address, currency_from, student_id, status, fee_percentage, fee_amount, final_amount)
VALUES 
    ('1', 'REF001', 'John Doe', 'john@mit.edu', 25000.00, 24800.00, 'MIT', 'John Doe', 'USA', '123 Main St', 'usd', 'MIT001', 'UNDERPAYMENT', 2.00, 500.00, 25500.00),
    ('2', 'REF002', 'Jane Smith', 'jane@stanford.edu', 30000.00, 31500.00, 'Stanford', 'Jane Smith', 'USA', '456 Oak Ave', 'usd', 'STF002', 'OVERPAYMENT', 2.00, 600.00, 30600.00)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
SQLEOF

# Pull and start containers
echo "Pulling Docker images..."
docker compose pull || echo "Warning: Failed to pull images, will retry on service start"

echo "Starting services..."
systemctl start hermes-docker

# Wait for MySQL to be ready
echo "Waiting for MySQL to start..."
sleep 30

# Initialize database schema
echo "Initializing database schema..."
docker exec -i mysql mysql -uroot -p${DB_PASSWORD} < init-schema.sql 2>/dev/null || echo "Schema already initialized"

# Wait for all services to be healthy
echo "Waiting for all services to start..."
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
