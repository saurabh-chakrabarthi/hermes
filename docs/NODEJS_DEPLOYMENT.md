# Node.js Deployment Guide

## Overview

The Hermes Payment Portal is now deployed with a **Node.js-only backend** on OCI Always Free Tier.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              OCI Free Tier Instance              │
│                                                   │
│  ┌───────────────────────────────────────────┐  │
│  │   Node.js Server (Port 9292)           │  │
│  │   - Express.js REST API                 │  │
│  │   - Payment processing logic            │  │
│  │   - In-memory storage                   │  │
│  └───────────────────────────────────────────┘  │
│                     │                          │
│                     ↓ HTTP                     │
│                     │                          │
│  ┌───────────────────────────────────────────┐  │
│  │   Spring Boot Client (Port 8080)       │  │
│  │   - Thymeleaf UI                        │  │
│  │   - Dashboard & Analytics               │  │
│  │   - Calls Node.js API                   │  │
│  └───────────────────────────────────────────┘  │
│                                                   │
│  Ubuntu 22.04 LTS | 50GB Boot Volume             │
└─────────────────────────────────────────────────────────┘
```

## Deployment Process

### 1. Infrastructure (Terraform)

- **VCN**: 10.0.0.0/16
- **Subnet**: 10.0.1.0/24
- **Security**: Ports 22, 9292, 8080 open
- **Compute**: VM.Standard.E2.1.Micro (Always Free)

### 2. Application Setup (Cloud-Init)

The `setup-nodejs.sh` script automatically:

1. Updates Ubuntu system
2. Installs Node.js 18.x and Java 17
3. Clones repository
4. Installs npm dependencies
5. Builds Spring Boot client with Maven
6. Creates systemd services for both
7. Starts Node.js server (port 9292)
8. Starts Spring Boot client (port 8080)

### 3. CI/CD Pipeline

GitHub Actions workflow:
1. Runs JUnit tests (if Java client exists)
2. Runs Node.js tests
3. Deploys infrastructure via Terraform
4. Waits for service to start
5. Performs health checks

## Required GitHub Secrets

- `OCI_USER_OCID` - IAM user OCID
- `OCI_FINGERPRINT` - API key fingerprint
- `OCI_PRIVATE_KEY` - API private key
- `OCI_TENANCY_OCID` - Tenancy OCID
- `OCI_REGION` - Region (e.g., us-ashburn-1)
- `OCI_COMPARTMENT_ID` - Compartment OCID
- `SSH_PUBLIC_KEY` - SSH public key for instance access
- `DB_PASSWORD` - (Optional, for future MySQL integration)

## Manual Deployment

```bash
# 1. Destroy existing infrastructure (if any)
cd infra/terraform
terraform destroy -auto-approve

# 2. Deploy new infrastructure
terraform init
terraform apply -auto-approve

# 3. Get instance IP
terraform output instance_public_ip

# 4. Wait 5-10 minutes for cloud-init to complete

# 5. Test
curl http://<INSTANCE_IP>:9292/health
```

## Troubleshooting

### Check cloud-init status
```bash
ssh ubuntu@<INSTANCE_IP>
sudo cloud-init status
```

### View setup logs
```bash
sudo tail -100 /var/log/cloud-init-output.log
```

### Check service status
```bash
sudo systemctl status payment-server
sudo journalctl -u payment-server -n 50
```

### Restart service
```bash
sudo systemctl restart payment-server
```

## Files Structure

```
infra/
├── scripts/
│   └── setup-nodejs.sh       # Cloud-init setup script
└── terraform/
    ├── main.tf               # Infrastructure definition
    ├── variables.tf          # Input variables
    └── outputs.tf            # Output values

server/
├── server-simple.js          # Simple Node.js server (no DB)
├── server.js                 # Full Node.js server (with DB)
└── package.json              # Dependencies
```

## Next Steps

To add MySQL HeatWave database:
1. Uncomment MySQL resources in `main.tf`
2. Update `setup-nodejs.sh` to use `server.js` instead of `server-simple.js`
3. Add database connection configuration
