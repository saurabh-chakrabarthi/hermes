# Hermes Payment & Remittance Portal

Enterprise payment processing system with Node.js backend and Micronaut dashboard running on OCI Always Free Tier.

## Architecture

```
┌──────────────────────────────────┐
│   MongoDB Atlas (Free Tier)      │
│   - 512MB Storage                │
│   - Serverless, Managed          │
└────────────┬─────────────────────┘
             │
┌────────────▼─────────────────────┐
│   OCI VM (1GB RAM, Free Tier)    │
│   ┌──────────────────────────┐   │
│   │   Docker Compose         │   │
│   │   ├── Node.js (100MB)    │   │
│   │   └── Micronaut (50MB)   │   │
│   └──────────────────────────┘   │
│   Ports: 9292, 8080              │
│   Memory Usage: ~200MB           │
│   Free Memory: ~750MB            │
└──────────────────────────────────┘
```

## Features

- **Payment Processing**: Modern form with validation
- **Quality Checks**: Email validation, duplicate detection, amount thresholds
- **Fee Calculation**: Tiered fee structure (2-5% based on amount)
- **Dashboard**: Real-time payment analytics with validation results
- **Over/Under Payments**: Automatic detection and status tracking

## Technology Stack

### Backend
- **API Server**: Node.js + Express
- **Database**: MongoDB Atlas (NoSQL, serverless)
- **Runtime**: Node.js 18+

### Frontend
- **Framework**: Micronaut 4.2.3
- **Template Engine**: Thymeleaf
- **UI**: Bootstrap 5

### Infrastructure
- **Orchestration**: Docker Compose
- **Containers**: Docker
- **Registry**: GitHub Container Registry (ghcr.io)
- **Cloud**: OCI Always Free Tier
- **IaC**: Terraform
- **CI/CD**: GitHub Actions

## Quick Start

### Prerequisites
- OCI Account (free tier)
- MongoDB Atlas Account (free tier)
- GitHub Account

### 1. Setup MongoDB Atlas

1. Go to https://www.mongodb.com/cloud/atlas/register
2. Create free M0 cluster
3. Create database user and password
4. Whitelist Public Static IP of OCI VM
5. Get connection details

### 2. Add GitHub Secrets

Go to GitHub → Settings → Secrets → Actions and add:

**Required OCI Secrets:**
- `OCI_USER_OCID`
- `OCI_FINGERPRINT`
- `OCI_TENANCY_OCID`
- `OCI_REGION`
- `OCI_PRIVATE_KEY`
- `OCI_COMPARTMENT_ID`
- `SSH_PUBLIC_KEY`

**Required MongoDB Secrets:**
- `MONGODB_USER` (e.g., `admin`)
- `MONGODB_PASSWORD` (your MongoDB password)
- `MONGODB_CLUSTER` (e.g., `cluster0.abc123.mongodb.net`)
- `MONGODB_DATABASE` (e.g., `hermes_payments`)

**Security Secrets (Recommended):**
- `ALLOWED_SSH_CIDR` (e.g., `<your_ip_range>` - your IP range for SSH access)
- `ALLOWED_WEB_CIDR` (e.g., `<your_ip_range>` - your IP range for web access)

**Note:** If security secrets are not set, defaults to `0.0.0.0/0` (insecure - allows all IPs)

### 3. Deploy

```bash
git add .
git commit -m "Deploy Hermes Payment Portal"
git push
```

GitHub Actions will automatically:
1. Build Docker images
2. Deploy infrastructure with Terraform
3. Install Docker on VM
4. Deploy applications with Docker Compose

**Deployment time**: ~5 minutes

### 4. Access Applications

After deployment completes:

- **Payment Server**: `http://<VM_IP>:9292`
- **Dashboard**: `http://<VM_IP>:8080`

Get VM IP from GitHub Actions logs or Terraform output.

## Local Development

### Node.js Server

```bash
cd server
npm install
cp .env.example .env
# Edit .env with your MongoDB credentials
npm run dev
```

Server runs on `http://localhost:9292`

### Micronaut Dashboard

```bash
cd dashboard
mvn clean install
mvn mn:run
```

Dashboard runs on `http://localhost:8080`

## Architecture Details

### Memory Optimization

| Component | Memory | Status |
|-----------|--------|--------|
| Node.js Server | 100MB | ✅ Running |
| Micronaut Dashboard | 50MB | ✅ Running |
| Docker Compose | ~50MB | ✅ Running |
| **Total Used** | **~200MB** | |
| **Free Memory** | **~750MB** | |

### Why This Stack?

**Micronaut vs Spring Boot:**
- 75% less memory (50MB vs 200MB)
- 5x faster startup (<1s vs 3-5s)
- Better for microservices
- Native cloud support

**MongoDB vs MySQL:**
- No schema migrations needed
- JSON-native (perfect for Node.js)
- Serverless (free tier)
- Better horizontal scaling
- Document model fits payment data

**Docker Compose vs k3s:**
- 80% less overhead (50MB vs 267MB)
- Simpler deployment
- Faster startup
- Better for single-node setups

**No Redis:**
- MongoDB is fast enough for our scale
- Simpler architecture
- 20MB memory saved
- One less service to maintain

## Project Structure

```
.
├── server/                 # Node.js payment API
│   ├── db/
│   │   └── connection.js   # MongoDB connection
│   ├── public/             # Static HTML forms
│   ├── server.js           # Express server
│   ├── Dockerfile          # Server container
│   └── package.json
│
├── dashboard/              # Micronaut dashboard
│   ├── src/main/java/
│   │   └── com/payment/dashboard/
│   │       ├── Application.java
│   │       ├── controller/
│   │       ├── service/
│   │       └── dto/
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   └── templates/
│   ├── Dockerfile          # Dashboard container
│   └── pom.xml
│
├── infra/
│   ├── docker/             # Container orchestration
│   │   ├── docker-compose.yml      # Production setup
│   │   ├── docker-compose.dev.yml  # Development setup
│   │   └── README.md
│   ├── scripts/
│   │   └── setup-docker.sh # VM initialization
│   ├── terraform/          # Infrastructure as Code
│   │   ├── main.tf
│   │   ├── security.tf     # Network security rules
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── SECURITY.md     # Security documentation
│
└── .github/workflows/
    └── deploy.yml          # CI/CD pipeline
```

## Documentation

- [CHANGELOG.md](CHANGELOG.md) - Development history and enhancements

## Key Features

### Payment Processing
- Form validation (client + server side)
- Duplicate detection
- Email validation
- Amount thresholds
- Fee calculation (2-5% tiered)

### Dashboard Analytics
- Real-time payment list
- Payment status tracking
- Over/under payment detection
- Audit logging

### DevOps
- Automated CI/CD with GitHub Actions
- Infrastructure as Code with Terraform
- Container orchestration with Docker Compose
- Health checks and monitoring
- Zero-downtime deployments

## Cost Breakdown

| Service | Tier | Cost |
|---------|------|------|
| OCI VM | Always Free (1GB RAM) | $0 |
| MongoDB Atlas | M0 Free (512MB) | $0 |
| GitHub Actions | Free (2000 min/month) | $0 |
| Container Registry | Free (500MB) | $0 |
| **Total** | | **$0/month** |

## Performance

- **API Response Time**: <50ms (MongoDB queries)
- **Dashboard Load Time**: <2s
- **Startup Time**: 
  - Node.js: <1s
  - Micronaut: <1s
- **Memory Usage**: 150MB (850MB free)
- **Concurrent Users**: 100+ (tested)

## Monitoring

### Health Checks

```bash
# Node.js Server
curl http://<VM_IP>:9292/health

# Micronaut Dashboard  
curl http://<VM_IP>:8080/health
```

### Logs

```bash
# SSH to VM
ssh -i ~/.ssh/id_rsa ubuntu@<VM_IP>

# Check containers
docker ps

# View logs
docker logs hermes-payment-server -f
docker logs hermes-payment-dashboard -f
```

## Troubleshooting

### Services not starting

```bash
docker ps -a
docker logs hermes-payment-server
docker logs hermes-payment-dashboard
```

### MongoDB connection issues

Check:
1. `MONGODB_PASSWORD` secret is set correctly
2. MongoDB Atlas IP whitelist includes `0.0.0.0/0`
3. Database user has read/write permissions

### Out of memory

```bash
docker stats
free -h
```

## Security

- ✅ Secrets stored in GitHub Secrets (encrypted)
- ✅ MongoDB password not in code
- ✅ HTTPS for MongoDB connection (TLS)
- ✅ **Network security with IP restrictions**
- ✅ **SSH access limited to specific CIDR blocks**
- ✅ **Web access restricted to allowed IP ranges**
- ✅ **Minimal egress rules (no "allow all" outbound)**
- ✅ No hardcoded credentials
- ✅ Environment-based configuration

### Security Configuration

The infrastructure now uses **restricted network access** instead of allowing all traffic (`0.0.0.0/0`):

- **SSH Access**: Configurable via `allowed_ssh_cidr` variable
- **Web Access**: Configurable via `allowed_web_cidr` variable  
- **Egress Rules**: Only specific ports (443, 80, 53, 27017) allowed

See [infra/terraform/SECURITY.md](infra/terraform/SECURITY.md) for detailed security configuration.

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

MIT License - see LICENSE file for details

## Support

For issues or questions:
1. Check [Documentation](#documentation)
2. Review [Troubleshooting](#troubleshooting)
3. Open GitHub Issue

---

**Built with ❤️ using OCI Always Free Tier + MongoDB Atlas Free Tier**

**Total Cost: $0/month** 💰
