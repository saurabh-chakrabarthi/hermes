# OCI Deployment Setup Guide

## Current Configuration
- **OCI Instance IP**: `129.213.125.13`
- **Server Port**: `9292`
- **Client Port**: `8080`

## Files Updated
✅ `.github/workflows/deploy.yml` - GitHub Actions workflow
✅ `client/src/main/resources/application.properties` - Client API endpoint
✅ `client/src/main/resources/application.yml` - Client server configuration

## Setup Steps

### 1. SSH Key Setup
First, you need your SSH private key to connect to the OCI instance:

```bash
# Find your SSH key (look for .pem or id_rsa files)
find ~ -name "*.pem" -o -name "id_*" 2>/dev/null

# Connect to your instance (replace with your actual key path)
ssh -i ~/.ssh/your-key.pem ubuntu@129.213.125.13
```

### 2. Initial OCI Instance Setup
Run this on your OCI instance:

```bash
# Download and run the setup script
curl -sSL https://raw.githubusercontent.com/saurabh-chakrabarthi/hermes/main/infra/scripts/setup-oci-instance.sh | bash
```

Or manually:
```bash
# Copy the setup script to your instance
scp -i ~/.ssh/your-key.pem infra/scripts/setup-oci-instance.sh ubuntu@129.213.125.13:~/
ssh -i ~/.ssh/your-key.pem ubuntu@129.213.125.13
chmod +x setup-oci-instance.sh
./setup-oci-instance.sh
```

### 3. GitHub Repository Secrets
Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- **`ORACLE_SSH_KEY`**: Your SSH private key content (the entire .pem file content)

### 4. Test Deployment
1. Push your code to the main branch
2. GitHub Actions will automatically:
   - Run tests
   - Deploy to your OCI instance
   - Restart the payment server

### 5. Access Your Application
- **Payment Portal**: http://129.213.125.13:9292
- **Client Dashboard**: http://129.213.125.13:8080 (if running client on OCI)

## Troubleshooting

### SSH Connection Issues
```bash
# Check if your key has correct permissions
chmod 600 ~/.ssh/your-key.pem

# Test connection
ssh -i ~/.ssh/your-key.pem ubuntu@129.213.125.13
```

### Server Not Running
```bash
# Check server status
sudo systemctl status payment-server

# Check logs
sudo journalctl -u payment-server -f

# Restart server
sudo systemctl restart payment-server
```

### GitHub Actions Failing
1. Check that `ORACLE_SSH_KEY` secret is properly set
2. Verify the SSH key has access to your OCI instance
3. Check GitHub Actions logs for specific errors

## Manual Deployment (Alternative)
If GitHub Actions isn't working, deploy manually:

```bash
# SSH to your instance
ssh -i ~/.ssh/your-key.pem ubuntu@129.213.125.13

# Update code
cd /home/ubuntu/payment-portal
git pull origin main
cd server && bundle install
sudo systemctl restart payment-server
```