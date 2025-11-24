# Hermes Payment Portal

Enterprise payment processing system with Node.js backend and Java Spring Boot dashboard.

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Spring Boot   │    │   Node.js    │    │  OCI MySQL      │
│   Dashboard     │◄──►│   Server     │◄──►│  HeatWave       │
│   (Port 8080)   │    │   (Port 9292)│    │                 │
└─────────────────┘    └──────┬───────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Redis Cache   │
                       └─────────────────┘
```

## Features

- **Payment Processing**: Modern form with validation
- **Quality Checks**: Email validation, duplicate detection, amount thresholds
- **Fee Calculation**: Tiered fee structure (2-5% based on amount)
- **Dashboard**: Real-time payment analytics with validation results
- **Over/Under Payments**: Automatic detection and status tracking

## Quick Start

### Local Development
```bash
# Option 1: Docker Compose (Recommended)
docker compose up -d

# Option 2: Native processes
./scripts/start_both.sh

# Access URLs
# Payment Server: http://localhost:9292
# Dashboard: http://localhost:8080
```

### Production Deployment
```bash
# Commit and push to trigger GitHub Actions
git add -A && git commit -m "Deploy to production" && git push

# Deployment time: ~7-8 minutes (Docker) vs ~10-12 minutes (Native)
```

## Technology Stack

- **Backend**: Node.js + Express
- **Frontend**: Java Spring Boot + Thymeleaf + Bootstrap
- **Containers**: Docker + Docker Compose
- **Registry**: GitHub Container Registry (ghcr.io)
- **Infrastructure**: OCI (Always Free Tier)
- **CI/CD**: GitHub Actions + Terraform

## Documentation

- [Docker Deployment Guide](docs/DOCKER_DEPLOYMENT.md) ⭐ NEW
- [Deployment Guide](docs/DEPLOYMENT_READY.md)
- [GitHub Secrets Setup](docs/SECRETS_REQUIRED.md)
- [Local Development](scripts/README.md)

## License

MIT License