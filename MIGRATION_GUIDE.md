# Migration Guide: Spring Boot → Micronaut + OCI HeatWave MySQL

## Architecture Changes

### Before:
```
OCI VM (1GB RAM)
├── k3s
├── MySQL (256MB)
├── Redis (20MB)
├── Node.js Server (100MB)
└── Spring Boot Dashboard (200MB)
Total: ~576MB + overhead = Out of Memory
```

### After:
```
OCI HeatWave MySQL (Free Tier, External)
    ↓
OCI VM (1GB RAM)
├── k3s
├── Redis (20MB)
├── Node.js Server (100MB)
└── Micronaut Dashboard (50MB)
Total: ~170MB = Plenty of headroom
```

## Step 1: Create OCI HeatWave MySQL

1. **OCI Console** → Databases → MySQL HeatWave → DB Systems
2. Click **"Create MySQL DB System"**
3. Configure:
   - Name: `hermes-mysql`
   - Shape: `MySQL.Free` (Always Free)
   - Storage: 50 GB
   - Username: `admin`
   - Password: Use your `DB_PASSWORD`
   - VCN: `hermes-payment-portal-vcn`
   - Subnet: Select your subnet
   - Enable public endpoint (or use private with VPN)
4. Wait 10-15 minutes for provisioning
5. Copy the **Private IP** or **Endpoint**

## Step 2: Initialize Database Schema

```bash
# Connect to OCI MySQL
mysql -h <MYSQL_ENDPOINT> -u admin -p

# Create database
CREATE DATABASE hermes_payments;
USE hermes_payments;

# Run schema from server/db/schema.sql
SOURCE server/db/schema.sql;
```

## Step 3: Add GitHub Secrets

Add new secret in GitHub repository settings:

- **Name**: `MYSQL_HOST`
- **Value**: Your OCI MySQL endpoint (e.g., `10.0.0.50` or public IP)

## Step 4: Update Deployment Trigger

The `deployment_trigger` is already set to `5` in `infra/terraform/variables.tf`.

## Step 5: Deploy

```bash
git add .
git commit -m "Migrate to Micronaut + OCI HeatWave MySQL"
git push
```

GitHub Actions will:
1. Build new Micronaut dashboard image
2. Terminate old instance
3. Create new instance with:
   - Redis only (no MySQL)
   - Micronaut dashboard (lighter than Spring Boot)
   - Connected to external OCI MySQL

## Memory Comparison

| Component | Spring Boot | Micronaut |
|-----------|-------------|-----------|
| Startup Time | 3-5s | <1s |
| Memory Usage | ~200MB | ~50MB |
| JAR Size | ~50MB | ~15MB |
| Cold Start | Slow | Fast |

## Key Changes

### Removed:
- `client/` directory (Spring Boot)
- `infra/k8s/mysql-service.yaml`
- `infra/k8s/mysql-statefulset.yaml`

### Added:
- `dashboard/` directory (Micronaut)
- `MYSQL_HOST` configuration

### Modified:
- `infra/k8s/payment-server-configmap.yaml` - Uses external MySQL
- `infra/scripts/setup-k3s.sh` - No MySQL deployment
- `.github/workflows/deploy.yml` - Builds Micronaut image

## Verification

After deployment:
```bash
# Check pods (should only see Redis + 2 apps)
kubectl get pods -n hermes

# Check memory usage
kubectl top pods -n hermes

# Test endpoints
curl http://<IP>:30092/health
curl http://<IP>:30080/health
```

## Rollback

If needed, revert to Spring Boot:
```bash
git revert HEAD
git push
```

## Benefits

✅ **70% less memory** usage on VM  
✅ **Free MySQL** with OCI HeatWave  
✅ **Faster startup** with Micronaut  
✅ **More stable** - no OOM kills  
✅ **Same functionality** - all features preserved
