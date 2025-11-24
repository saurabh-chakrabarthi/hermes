# Docker Compose Deployment Guide

## Overview

The Hermes Payment Portal now uses Docker Compose for fast, reliable deployments with pre-built container images.

## Architecture

```
GitHub Actions → Build Docker Images → Push to GHCR → Deploy to OCI VM → Docker Compose
```

### Components

1. **GitHub Container Registry (ghcr.io)** - Free private/public container registry
2. **Docker Compose** - Orchestrates 2 containers on OCI VM
3. **Terraform** - Provisions infrastructure with security validation

## Container Images

- `ghcr.io/<your-username>/hermes-payment-server:latest` - Node.js Express server
- `ghcr.io/<your-username>/hermes-payment-dashboard:latest` - Spring Boot dashboard

## Deployment Speed

| Phase | Time |
|-------|------|
| Build images (GitHub Actions) | ~3-4 minutes |
| Push to registry | ~30 seconds |
| Terraform apply | ~2 minutes |
| Docker installation | ~1 minute |
| Pull & start containers | ~30 seconds |
| **Total** | **~7-8 minutes** |

**Previous deployment**: 10-12 minutes (Maven build on VM)

## Local Development

### Build images locally
```bash
# Build payment server
cd server
docker build -t hermes-payment-server:local .

# Build dashboard
cd ../client
docker build -t hermes-payment-dashboard:local .
```

### Run locally with Docker Compose
```bash
# Update docker-compose.yml to use local images
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Test containers
```bash
# Payment server
curl http://localhost:9292/health

# Dashboard
curl http://localhost:8080/actuator/health
```

## Registry Options

### 1. GitHub Container Registry (GHCR) - RECOMMENDED ✅
- **Free**: Unlimited public/private images
- **Integrated**: Works seamlessly with GitHub Actions
- **Authentication**: Uses `GITHUB_TOKEN` (automatic)
- **URL**: `ghcr.io/<username>/<image>:tag`

**Setup**: No additional configuration needed! Already configured in workflow.

### 2. Docker Hub
- **Free**: 1 private repo, unlimited public repos
- **Limits**: 200 pulls/6 hours for free tier
- **Authentication**: Requires Docker Hub account

**Setup**:
```bash
# Add secrets to GitHub
DOCKERHUB_USERNAME=<your-username>
DOCKERHUB_TOKEN=<your-token>

# Update workflow to use docker.io instead of ghcr.io
```

### 3. Oracle Cloud Container Registry (OCIR)
- **Free**: Included with OCI account
- **Private**: All images private by default
- **Authentication**: Uses OCI credentials

**Setup**:
```bash
# Login format
docker login <region>.ocir.io -u '<tenancy-namespace>/<username>' -p '<auth-token>'

# Update docker-compose.yml
image: <region>.ocir.io/<tenancy-namespace>/hermes-payment-server:latest
```

## Security Validation

Terraform automatically validates that required ports are open:

```bash
# Terraform checks these ports
- Port 22 (SSH)
- Port 8080 (Dashboard)
- Port 9292 (Payment Server)

# Deployment fails if any port is blocked
```

## Troubleshooting

### Images not pulling
```bash
# SSH to instance
ssh ubuntu@<instance-ip>

# Check Docker status
sudo systemctl status docker

# Manually pull images
sudo docker pull ghcr.io/<username>/hermes-payment-server:latest

# Check logs
sudo journalctl -u hermes-docker -n 50
```

### Container not starting
```bash
# View container logs
sudo docker logs payment-server
sudo docker logs payment-dashboard

# Restart services
sudo systemctl restart hermes-docker

# Check container status
sudo docker ps -a
```

### Port conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep -E ':(8080|9292)'

# Stop old services if needed
sudo systemctl stop payment-server payment-client
```

## Manual Deployment

### Build and push images manually
```bash
# Run manual workflow
# Go to: Actions → Build Docker Images (Manual) → Run workflow
```

### Deploy to existing instance
```bash
# SSH to instance
ssh ubuntu@<instance-ip>

# Pull latest images
cd /opt/hermes
sudo docker compose pull

# Restart services
sudo docker compose up -d

# Verify
sudo docker ps
```

## Rollback

### Rollback to previous version
```bash
# SSH to instance
ssh ubuntu@<instance-ip>

# Use specific image tag
cd /opt/hermes
sudo nano docker-compose.yml
# Change :latest to :main-<commit-sha>

# Restart
sudo docker compose up -d
```

## Cost Analysis

| Component | Cost |
|-----------|------|
| OCI VM.Standard.E2.1.Micro | **FREE** (Always Free Tier) |
| GitHub Container Registry | **FREE** (Unlimited) |
| GitHub Actions | **FREE** (2000 min/month) |
| OCI VCN, Security Lists | **FREE** (Always Free Tier) |
| **Total** | **$0/month** |

## Next Steps

1. **Enable image caching** - Speed up builds with layer caching
2. **Add health checks** - Improve container reliability
3. **Implement blue-green deployment** - Zero-downtime updates
4. **Add monitoring** - Container metrics and alerts
5. **Multi-stage optimization** - Reduce image sizes further

## Migration from systemd

The old systemd services are automatically replaced by Docker Compose. No manual cleanup needed.

Old services:
- `payment-server.service` (systemd)
- `payment-client.service` (systemd)

New service:
- `hermes-docker.service` (systemd wrapper for docker-compose)
