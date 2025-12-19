# Quick Start Guide

Get Hermes Payment Portal running in 15 minutes!

## Prerequisites

- OCI Account (free tier)
- GitHub Account
- 15 minutes of your time

## Step 1: Create OCI MySQL (5 minutes)

1. Login to OCI Console
2. Go to **Databases** → **MySQL HeatWave** → **DB Systems**
3. Click **Create MySQL DB System**
4. Fill in:
   - Name: `hermes-mysql`
   - Shape: **MySQL.Free** (Always Free)
   - Username: `admin`
   - Password: Create a strong password
   - VCN: `hermes-payment-portal-vcn` (will be created by Terraform)
   - Enable public endpoint
5. Click **Create** and wait ~10 minutes
6. Copy the **endpoint IP** when ready

## Step 2: Initialize Database (2 minutes)

```bash
# Connect to MySQL
mysql -h <YOUR_MYSQL_IP> -u admin -p

# Run these commands
CREATE DATABASE hermes_payments;
USE hermes_payments;

# Copy and paste the schema from server/db/schema.sql
# Or run: SOURCE /path/to/server/db/schema.sql;

# Verify
SHOW TABLES;
# Should see: payments, validation_results, audit_log

# Exit
exit;
```

## Step 3: Configure GitHub (5 minutes)

### Fork/Clone Repository

```bash
git clone https://github.com/saurabh-chakrabarthi/hermes.git
cd hermes
```

### Add GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these 9 secrets:

| Secret | Where to find it |
|--------|------------------|
| `OCI_USER_OCID` | OCI Console → Profile → User Settings |
| `OCI_FINGERPRINT` | OCI Console → API Keys |
| `OCI_TENANCY_OCID` | OCI Console → Tenancy Details |
| `OCI_REGION` | e.g., `us-ashburn-1` |
| `OCI_PRIVATE_KEY` | Your API private key (full PEM content) |
| `OCI_COMPARTMENT_ID` | OCI Console → Identity → Compartments |
| `SSH_PUBLIC_KEY` | Your SSH public key (`cat ~/.ssh/id_rsa.pub`) |
| `DB_PASSWORD` | The MySQL password you created |
| `MYSQL_HOST` | The MySQL endpoint IP from Step 1 |

## Step 4: Deploy (3 minutes)

```bash
# Commit and push
git add .
git commit -m "Initial deployment"
git push
```

### Monitor Deployment

1. Go to GitHub → **Actions** tab
2. Watch the "CI/CD Pipeline" workflow
3. Wait ~10-12 minutes for completion
4. Get the VM IP from the logs (look for "Instance IP: X.X.X.X")

## Step 5: Verify (1 minute)

```bash
# Replace with your VM IP
VM_IP=<your-vm-ip>

# Test health endpoints
curl http://$VM_IP:30092/health
curl http://$VM_IP:30080/health

# Open dashboard in browser
open http://$VM_IP:30080
```

## Success! 🎉

You should see:
- ✅ Health endpoints return `{"status":"UP"}`
- ✅ Dashboard loads in browser
- ✅ Can submit payments
- ✅ Payments appear in dashboard

## Troubleshooting

### MySQL connection failed

```bash
# Check security list allows traffic
# OCI Console → Networking → VCN → Security Lists
# Ensure port 3306 is open from VM subnet to MySQL
```

### Pods not starting

```bash
ssh -i ~/.ssh/id_rsa ubuntu@$VM_IP
kubectl get pods -n hermes
kubectl logs -n hermes -l app=payment-server
```

### Still stuck?

Check these docs:
- [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - Detailed setup
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step verification
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Architecture details

## What's Running?

After deployment:

```
OCI HeatWave MySQL (Free)
    ↓
OCI VM (Free)
├── k3s
├── Redis (cache)
├── Node.js Server (port 30092)
└── Micronaut Dashboard (port 30080)
```

**Total Cost: $0/month** 💰

## Next Steps

1. Test payment submission
2. Check data in MySQL
3. Explore the dashboard
4. Read [SUMMARY.md](SUMMARY.md) to understand the architecture

## Need Help?

- **Setup issues**: [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- **Deployment issues**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
- **Architecture questions**: [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

Happy coding! 🚀
