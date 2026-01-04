# Setup Instructions

## Prerequisites

1. **OCI Account** with Always Free Tier
2. **GitHub Account**
3. **MongoDB Atlas** account (free tier)

## Quick Start

### 1. Create MongoDB Atlas Cluster

1. Go to https://www.mongodb.com/cloud/atlas/register
2. Create free M0 cluster
3. Create database user and password
4. Whitelist IP: `0.0.0.0/0` (or your VM's public IP)
5. Get connection details (cluster URL)

### 2. Configure GitHub Secrets

Add these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `OCI_USER_OCID` | Your OCI user OCID | `ocid1.user.oc1..aaa...` |
| `OCI_FINGERPRINT` | API key fingerprint | `aa:bb:cc:...` |
| `OCI_TENANCY_OCID` | Tenancy OCID | `ocid1.tenancy.oc1..aaa...` |
| `OCI_REGION` | OCI region | `us-ashburn-1` |
| `OCI_PRIVATE_KEY` | API private key (full PEM) | `-----BEGIN PRIVATE KEY-----...` |
| `OCI_COMPARTMENT_ID` | Compartment OCID | `ocid1.compartment.oc1..aaa...` |
| `SSH_PUBLIC_KEY` | SSH public key for VM | `ssh-rsa AAAA...` |
| `MONGODB_USER` | MongoDB username | `admin` |
| `MONGODB_PASSWORD` | MongoDB password | `YourSecurePassword123!` |
| `MONGODB_CLUSTER` | MongoDB cluster URL | `cluster0.abc123.mongodb.net` |
| `MONGODB_DATABASE` | Database name | `hermes_payments` |

### 3. Deploy

```bash
git add .
git commit -m "Initial deployment"
git push
```

GitHub Actions will automatically:
1. Run tests
2. Build Docker images
3. Deploy infrastructure with Terraform
4. Install Docker on VM
5. Deploy applications with Docker Compose

### 4. Access Applications

After ~10 minutes:

- **Payment Server**: `http://<VM_IP>:9292`
- **Dashboard**: `http://<VM_IP>:8080`

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
└──────────────────────────────────┘
```

## Tech Stack

- **Backend**: Node.js + Express
- **Frontend**: Micronaut + Thymeleaf
- **Database**: MongoDB Atlas (NoSQL, serverless)
- **Orchestration**: Docker Compose
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Registry**: GitHub Container Registry

## Local Development

### Node.js Server

```bash
cd server
npm install
cp .env.example .env
# Edit .env with your MongoDB credentials
npm run dev
```

### Micronaut Dashboard

```bash
cd dashboard
mvn clean install
mvn mn:run
```

## Troubleshooting

### Services not starting

```bash
ssh -i ~/.ssh/hermes-pvt-key.key ubuntu@<VM_IP>
docker ps
docker logs hermes-payment-server
```

### MongoDB connection issues

Check:
1. `MONGODB_PASSWORD` secret is set correctly
2. MongoDB Atlas IP whitelist includes `0.0.0.0/0`
3. Database user has read/write permissions

### Out of memory

Check resource usage:
```bash
docker stats
free -h
```

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
# View logs
docker logs hermes-payment-server -f
docker logs hermes-payment-dashboard -f
```

## Cost

**Total Monthly Cost: $0**

- OCI VM: Always Free (1 OCPU, 1GB RAM)
- MongoDB Atlas: M0 Free (512MB)
- GitHub Actions: Free tier (2000 minutes/month)
- Container Registry: Free (500MB)

## Support

For issues, check:
1. GitHub Actions logs
2. Docker container logs
3. OCI cloud-init logs: `/var/log/cloud-init-output.log`
