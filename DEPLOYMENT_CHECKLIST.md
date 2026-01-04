# Deployment Checklist

## Before Deployment

### ✅ MongoDB Atlas Setup

- [ ] MongoDB Atlas cluster created (or managed MongoDB hosted)
- [ ] VPC / network access configured so the deployment VM can connect (allowlist IPs)
- [ ] Username and password stored in GitHub Secrets (`MONGODB_USER`, `MONGODB_PASSWORD`)
- [ ] `MONGODB_CLUSTER` and `MONGODB_DATABASE` set in GitHub Secrets (or passed to Terraform)
- [ ] Application will use the provided Atlas connection string: `mongodb+srv://<user>:<password>@<cluster>/<db>`

### ✅ Database Schema / Data

- [ ] Deployment attempts to create the database and an initial collection during VM setup (best-effort). If Atlas IP allowlist prevents direct creation, create the DB manually or allow the VM's IP.
- [ ] If needed, connect with `mongosh` or `mongo`:
  - `mongosh "mongodb+srv://<user>:<password>@<cluster>/<db>"`
  - `use <db>; db.createCollection('payments');`

### ✅ GitHub Secrets

All secrets added in GitHub repository settings:

- [ ] `OCI_USER_OCID`
- [ ] `OCI_FINGERPRINT`
- [ ] `OCI_TENANCY_OCID`
- [ ] `OCI_REGION`
- [ ] `OCI_PRIVATE_KEY`
- [ ] `OCI_COMPARTMENT_ID`
- [ ] `SSH_PUBLIC_KEY`
- [ ] `MONGODB_USER`
- [ ] `MONGODB_PASSWORD`
- [ ] `MONGODB_CLUSTER`
- [ ] `MONGODB_DATABASE`

### ✅ Code Changes

- [ ] Docker Compose configuration in `docker-compose.yml`
- [ ] `infra/scripts/setup-docker.sh` updated for Docker deployment
- [ ] `infra/terraform/main.tf` uses Docker setup script
- [ ] `.github/workflows/deploy.yml` updated for Docker Compose
- [ ] `deployment_trigger` updated in `variables.tf` if needed

## Deployment Steps

### 1. Commit and Push

```bash
git add .
git commit -m "Deploy Hermes Payment Portal"
git push
```

### 2. Monitor GitHub Actions

- [ ] Go to GitHub → Actions tab
- [ ] Watch "CI/CD Pipeline" workflow
- [ ] Verify all jobs pass:
  - [ ] JUnit Tests (skipped if no changes)
  - [ ] Node.js Tests
  - [ ] Build Docker Images
  - [ ] Deploy to OCI

### 3. Verify Deployment

Expected timeline: ~10-12 minutes

- [ ] Terraform creates/updates infrastructure (2-3 min)
- [ ] Instance terminates old VM (if exists)
- [ ] New instance provisions (3-4 min)
- [ ] Docker installs (1-2 min)
- [ ] Containers start (2-3 min)

### 4. Check Services

```bash
# Get VM IP from GitHub Actions logs or Terraform output
VM_IP=<your-vm-ip>

# Check Node.js health
curl http://$VM_IP:9292/health

# Check Micronaut health
curl http://$VM_IP:8080/health

# Access dashboard
open http://$VM_IP:8080
```

## Post-Deployment Verification

### ✅ Docker Containers

```bash
ssh -i ~/.ssh/hermes-pvt-key.key ubuntu@$VM_IP
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                                    STATUS
xxx            hermes-payment-server:latest             Up 5 minutes (healthy)
xxx            hermes-payment-dashboard-micronaut:latest Up 4 minutes (healthy)
```

### ✅ Memory Usage

```bash
docker stats
free -h
```

Expected: <300MB total usage (700MB free)

### ✅ Database Connection

```bash
# Check server logs for MongoDB connection
docker logs hermes-payment-server | grep -i mongo
```

Should see: "MongoDB connected" or similar success message

### ✅ Application Functionality

- [ ] Dashboard loads at `http://$VM_IP:8080`
- [ ] Can submit payment form
- [ ] Payments appear in dashboard
- [ ] Data persists in MongoDB Atlas

## Troubleshooting

### Issue: Containers not starting

```bash
docker ps -a
docker logs hermes-payment-server
docker logs hermes-payment-dashboard
```

Common causes:
- MongoDB connection string incorrect
- MONGODB_PASSWORD mismatch
- Image pull errors

### Issue: MongoDB connection failed

Check:
1. `MONGODB_PASSWORD` secret is correct
2. MongoDB Atlas IP whitelist includes `0.0.0.0/0` or VM's public IP
3. MongoDB cluster is active
4. Database user has read/write permissions

### Issue: Out of memory

```bash
docker stats
free -h
```

If still OOM:
- Check for memory leaks in logs
- Restart containers: `docker compose restart`

## Rollback Plan

If deployment fails:

```bash
# Option 1: Revert code
git revert HEAD
git push

# Option 2: Manual fix on VM
ssh ubuntu@$VM_IP
cd /home/ubuntu/app
docker compose down
# Fix configuration
docker compose up -d
```

## Success Criteria

✅ All containers running  
✅ Health endpoints return 200  
✅ Dashboard accessible  
✅ Can create payments  
✅ Data persists in MongoDB  
✅ Memory usage <300MB  
✅ No container restarts

## Next Steps

After successful deployment:

1. Test payment submission
2. Verify data in MongoDB Atlas
3. Monitor for 24 hours
4. Update documentation

## Notes

- First deployment will take longer (~12 min)
- Subsequent deployments faster (~5 min) if no instance recreation
- To force recreation: increment `deployment_trigger` in `variables.tf`
