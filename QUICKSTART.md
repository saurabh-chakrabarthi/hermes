# Quick Start Guide

Get Hermes Payment Portal running in 15 minutes!

## Prerequisites

- OCI Account (free tier)
- MongoDB Atlas Account (free tier)
- GitHub Account
- 15 minutes of your time

## Step 1: Create MongoDB Atlas Cluster (5 minutes)

1. Go to https://www.mongodb.com/cloud/atlas/register
2. Create free M0 cluster
3. Create database user and password
4. Whitelist IP: `0.0.0.0/0` (allows all IPs)
5. Get connection details:
   - Cluster URL (e.g., `cluster0.abc123.mongodb.net`)
   - Database name (e.g., `hermes_payments`)
6. Database will be auto-created on first connection

## Step 2: Configure GitHub (5 minutes)

### Fork/Clone Repository

```bash
git clone https://github.com/saurabh-chakrabarthi/hermes.git
cd hermes
```

### Add GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret | Where to find it |
|--------|------------------|
| `OCI_USER_OCID` | OCI Console → Profile → User Settings |
| `OCI_FINGERPRINT` | OCI Console → API Keys |
| `OCI_TENANCY_OCID` | OCI Console → Tenancy Details |
| `OCI_REGION` | e.g., `us-ashburn-1` |
| `OCI_PRIVATE_KEY` | Your API private key (full PEM content) |
| `OCI_COMPARTMENT_ID` | OCI Console → Identity → Compartments |
| `SSH_PUBLIC_KEY` | Your SSH public key (`cat ~/.ssh/id_rsa.pub`) |
| `MONGODB_USER` | MongoDB Atlas username |
| `MONGODB_PASSWORD` | MongoDB Atlas password |
| `MONGODB_CLUSTER` | MongoDB cluster URL (e.g., `cluster0.abc123.mongodb.net`) |
| `MONGODB_DATABASE` | Database name (e.g., `hermes_payments`) |

## Step 3: Deploy (3 minutes)

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

## Step 4: Verify (1 minute)

```bash
# Replace with your VM IP
VM_IP=<your-vm-ip>

# Test health endpoints
curl http://$VM_IP:9292/health
curl http://$VM_IP:8080/health

# Open dashboard in browser
open http://$VM_IP:8080
```

## Success! 🎉

You should see:
- ✅ Health endpoints return `{"status":"UP"}`
- ✅ Dashboard loads in browser
- ✅ Can submit payments
- ✅ Payments appear in dashboard

## Troubleshooting

### MongoDB connection failed

```bash
# Check MongoDB Atlas IP whitelist includes 0.0.0.0/0
# Or add your VM's specific public IP
```

### Services not starting

```bash
ssh -i ~/.ssh/id_rsa ubuntu@$VM_IP
docker ps
docker logs hermes-payment-server
```

### Still stuck?

Check these docs:
- [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md) - Detailed setup
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step verification

## What's Running?

After deployment:

```
MongoDB Atlas (Free)
    ↓
OCI VM (Free)
├── Docker Compose
├── Node.js Server (port 9292)
└── Micronaut Dashboard (port 8080)
```

**Total Cost: $0/month** 💰

## Next Steps

1. Test payment submission
2. Check data in MongoDB Atlas
3. Explore the dashboard
4. Read [README.md](README.md) to understand the architecture

## Need Help?

- **Setup issues**: [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- **Deployment issues**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

Happy coding! 🚀
