# Deployment Checklist

## Before Deployment

### ✅ MongoDB (Atlas) Setup

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
- [ ] `DB_PASSWORD`
- [ ] `MYSQL_HOST` ⭐ NEW - OCI MySQL endpoint

### ✅ Code Changes

- [ ] Micronaut dashboard created in `dashboard/` directory
- [ ] `infra/k8s/payment-server-configmap.yaml` updated with `MYSQL_HOST_PLACEHOLDER`
- [ ] `infra/scripts/setup-k3s.sh` updated to remove MySQL deployment
- [ ] `infra/terraform/variables.tf` has `mysql_host` variable
- [ ] `.github/workflows/deploy.yml` builds Micronaut image
- [ ] `deployment_trigger` = `5` in `variables.tf`

## Deployment Steps

### 1. Commit and Push

```bash
git add .
git commit -m "Migrate to Micronaut + OCI HeatWave MySQL"
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
- [ ] k3s installs (1-2 min)
- [ ] Pods start (2-3 min)

### 4. Check Services

```bash
# Get VM IP from GitHub Actions logs or Terraform output
VM_IP=<your-vm-ip>

# Check Node.js health
curl http://$VM_IP:30092/health

# Check Micronaut health
curl http://$VM_IP:30080/health

# Access dashboard
open http://$VM_IP:30080
```

## Post-Deployment Verification

### ✅ Kubernetes Pods

```bash
ssh -i ~/.ssh/hermes-pvt-key.key ubuntu@$VM_IP
kubectl get pods -n hermes
```

Expected output:
```
NAME                                 READY   STATUS    RESTARTS   AGE
redis-xxx                            1/1     Running   0          5m
payment-server-xxx                   1/1     Running   0          4m
payment-dashboard-xxx                1/1     Running   0          4m
```

### ✅ Memory Usage

```bash
kubectl top pods -n hermes
free -h
```

Expected: <500MB total usage (plenty of headroom on 1GB VM)

### ✅ Database Connection

```bash
# Check server logs for MySQL connection
kubectl logs -n hermes -l app=payment-server | grep -i mysql
```

Should see: "MySQL connected" or similar success message

### ✅ Application Functionality

- [ ] Dashboard loads at `http://$VM_IP:30080`
- [ ] Can submit payment form
- [ ] Payments appear in dashboard
- [ ] Data persists in OCI MySQL

## Troubleshooting

### Issue: Pods not starting

```bash
kubectl describe pods -n hermes
kubectl logs -n hermes -l app=payment-server
```

Common causes:
- MySQL host incorrect
- DB_PASSWORD mismatch
- Image pull errors

### Issue: MySQL connection failed

Check:
1. `MYSQL_HOST` secret is correct
2. Security list allows traffic from VM to MySQL (port 3306)
3. MySQL is in ACTIVE state
4. Database `hermes_payments` exists

### Issue: Out of memory

```bash
kubectl top pods -n hermes
free -h
```

If still OOM:
- Reduce Redis memory limit
- Check for memory leaks in logs

## Rollback Plan

If deployment fails:

```bash
# Option 1: Revert code
git revert HEAD
git push

# Option 2: Manual fix on VM
ssh ubuntu@$VM_IP
kubectl delete -f /home/ubuntu/k8s/
# Fix manifests
kubectl apply -f /home/ubuntu/k8s/
```

## Success Criteria

✅ All pods running  
✅ Health endpoints return 200  
✅ Dashboard accessible  
✅ Can create payments  
✅ Data persists in MySQL  
✅ Memory usage <500MB  
✅ No pod restarts

## Next Steps

After successful deployment:

1. Test payment submission
2. Verify data in MySQL
3. Monitor for 24 hours
4. Update documentation
5. Remove old `client/` directory (Spring Boot)

## Notes

- First deployment will take longer (~12 min)
- Subsequent deployments faster (~5 min) if no instance recreation
- To force recreation: increment `deployment_trigger` in `variables.tf`
