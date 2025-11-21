# 100% Free Deployment Guide

## Architecture
- **Frontend**: GitHub Pages (Static HTML/CSS/JS)
- **Backend**: Oracle Cloud Free Tier VM
- **CI/CD**: GitHub Actions (Free)

## Setup Steps

### 1. Oracle Cloud Setup (Free Forever)
1. Sign up at [Oracle Cloud](https://cloud.oracle.com/free)
2. Create VM instance (Always Free tier)
3. Note down public IP address
4. Generate SSH key pair

### 2. VM Configuration
```bash
# SSH into your Oracle VM
ssh -i your-key.pem ubuntu@YOUR_VM_IP

# Run setup script
curl -sSL https://raw.githubusercontent.com/saurabh-chakrabarthi/hermes/main/infra/scripts/oracle-setup.sh | bash
```

### 3. GitHub Secrets Setup
Add these secrets in GitHub repo → Settings → Secrets:
- `ORACLE_HOST`: Your VM's public IP
- `ORACLE_USER`: ubuntu
- `ORACLE_SSH_KEY`: Your private SSH key content

### 4. GitHub Pages Setup
1. Go to repo Settings → Pages
2. Source: GitHub Actions
3. Your site will be at: `https://saurabh-chakrabarthi.github.io/hermes`

### 5. Update API URL
Edit `client/src/main/resources/static/index.html`:
```javascript
window.API_BASE_URL = 'http://YOUR_VM_IP:9292';
```

## Deployment Flow
1. Push to `main` branch
2. GitHub Actions runs tests
3. Deploys static files to GitHub Pages
4. Deploys server to Oracle Cloud VM
5. Both services are live!

## URLs
- **Frontend**: `https://saurabh-chakrabarthi.github.io/hermes`
- **Backend**: `http://YOUR_VM_IP:9292`

## Cost Breakdown
- GitHub Actions: FREE (unlimited for public repos)
- GitHub Pages: FREE
- Oracle Cloud VM: FREE (Always Free tier)
- **Total: $0/month**

## Monitoring
- GitHub Actions: Build/deploy status
- Oracle Cloud: VM metrics dashboard
- Server logs: `sudo journalctl -u payment-server -f`