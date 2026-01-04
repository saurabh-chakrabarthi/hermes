# Docker Configuration

This directory contains Docker Compose configurations for the Hermes Payment Portal.

## Files

- `docker-compose.yml` - Production deployment configuration
- `docker-compose.dev.yml` - Development/testing configuration

## Usage

### Production Deployment

```bash
cd infra/docker
docker compose up -d
```

### Development

```bash
cd infra/docker
docker compose -f docker-compose.dev.yml up -d
```

## Environment Variables

Required environment variables for production:

- `MONGODB_USER` - MongoDB username
- `MONGODB_PASSWORD` - MongoDB password  
- `MONGODB_CLUSTER` - MongoDB cluster hostname
- `MONGODB_DATABASE` - MongoDB database name

## Security Notes

The production configuration:
- Uses health checks for service reliability
- Implements proper service dependencies
- Exposes minimal required ports
- Uses restart policies for resilience

## Container Images

Images are built and pushed to GitHub Container Registry:
- `ghcr.io/[owner]/hermes-payment-server:latest`
- `ghcr.io/[owner]/hermes-payment-dashboard-micronaut:latest`