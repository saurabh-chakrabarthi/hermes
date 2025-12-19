# Setup Instructions

## Prerequisites

1. **OCI Account** with Always Free Tier
2. **GitHub Account**
3. **OCI HeatWave MySQL** database created

## Quick Start

### 1. Create OCI HeatWave MySQL

Follow [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) Step 1 to create the database.

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
| `DB_PASSWORD` | MySQL password | `YourSecurePassword123!` |
| `MYSQL_HOST` | OCI MySQL endpoint | `10.0.0.50` or public IP |

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
4. Set up k3s with Redis
5. Deploy applications

### 4. Access Applications

After ~10 minutes:

- **Payment Server**: `http://<VM_IP>:30092`
- **Dashboard**: `http://<VM_IP>:30080`

## Architecture

```
┌─────────────────────────────────┐
│   OCI HeatWave MySQL (Free)     │
│   - 50GB Storage                │
│   - Always Free Tier            │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│   OCI VM (1GB RAM, Free)        │
│   ┌─────────────────────────┐   │
│   │   k3s Kubernetes        │   │
│   │   ├── Redis (20MB)      │   │
│   │   ├── Node.js (100MB)   │   │
│   │   └── Micronaut (50MB)  │   │
│   └─────────────────────────┘   │
└─────────────────────────────────┘
```

## Tech Stack

- **Backend**: Node.js + Express
- **Frontend**: Micronaut + Thymeleaf
- **Database**: OCI HeatWave MySQL
- **Cache**: Redis
- **Orchestration**: k3s (lightweight Kubernetes)
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Registry**: GitHub Container Registry

## Local Development

### Node.js Server

```bash
cd server
npm install
cp .env.example .env
# Edit .env with your MySQL credentials
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
kubectl get pods -n hermes
kubectl logs -n hermes -l app=payment-server
```

### MySQL connection issues

Check security list allows traffic from VM to MySQL:
- OCI Console → Networking → VCN → Security Lists
- Ensure port 3306 is open from VM subnet

### Out of memory

Check resource usage:
```bash
kubectl top pods -n hermes
free -h
```

## Monitoring

### Health Checks

```bash
# Node.js Server
curl http://<VM_IP>:30092/health

# Micronaut Dashboard
curl http://<VM_IP>:30080/health
```

### Logs

```bash
# All pods
kubectl logs -n hermes --all-containers=true -f

# Specific app
kubectl logs -n hermes -l app=payment-server -f
```

## Cost

**Total Monthly Cost: $0**

- OCI VM: Always Free (1 OCPU, 1GB RAM)
- OCI MySQL: Always Free (50GB)
- Redis: On VM (free)
- GitHub Actions: Free tier (2000 minutes/month)
- Container Registry: Free (500MB)

## Support

For issues, check:
1. [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
2. GitHub Actions logs
3. Kubernetes pod logs
4. OCI cloud-init logs: `/var/log/cloud-init-output.log`
