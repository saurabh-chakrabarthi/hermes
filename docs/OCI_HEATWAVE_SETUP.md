# OCI MySQL HeatWave Setup Guide

## Current Setup vs OCI HeatWave

### Current (MySQL in Docker)
```
✅ Pros:
- Free (runs on VM)
- Easy setup
- No additional configuration
- Good for development

❌ Cons:
- Limited to VM resources
- No automatic backups
- No high availability
- Manual scaling
```

### OCI HeatWave (Managed Service)
```
✅ Pros:
- Managed service (automatic backups, patches)
- High availability
- Better performance
- Automatic scaling
- 50GB free storage (Always Free Tier)

❌ Cons:
- Requires manual setup in OCI Console
- More complex networking
- Separate from VM
```

## Option 1: Keep MySQL in Docker (Current - RECOMMENDED for Learning)

**Why:** 
- Simpler architecture
- Everything in one place
- Easier to manage
- Good for portfolio/learning

**Current Status:** ✅ Already working

---

## Option 2: Migrate to OCI HeatWave

### Step 1: Create MySQL Database in OCI Console

1. Go to OCI Console → Databases → MySQL → DB Systems
2. Click "Create DB System"
3. Select:
   - **Shape**: MySQL.Free (Always Free)
   - **Storage**: 50GB
   - **VCN**: hermes-payment-portal-vcn
   - **Subnet**: Same as compute instance
   - **Username**: admin
   - **Password**: (use same as DB_PASSWORD secret)

4. Wait 10-15 minutes for provisioning

### Step 2: Get Connection Details

After creation, note:
```
Endpoint: <db-system-name>.mysql.database.oraclecloud.com
Port: 3306
Username: admin
Password: <your-password>
```

### Step 3: Update docker-compose.yml

Remove MySQL container, keep only Redis:

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  payment-server:
    image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/hermes-payment-server:latest
    container_name: payment-server
    ports:
      - "9292:9292"
    environment:
      - PORT=9292
      - NODE_ENV=production
      - DB_HOST=<heatwave-endpoint>.mysql.database.oraclecloud.com
      - DB_USER=admin
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=hermes_payments
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped

  payment-dashboard:
    image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/hermes-payment-dashboard:latest
    container_name: payment-dashboard
    ports:
      - "8080:8080"
    environment:
      - PAYMENT_SERVER_URL=http://payment-server:9292
    depends_on:
      - payment-server
    restart: unless-stopped

volumes:
  redis_data:
```

### Step 4: Initialize Schema

```bash
# SSH to VM
ssh ubuntu@152.70.200.104

# Install MySQL client
sudo apt-get install -y mysql-client

# Connect to HeatWave
mysql -h <endpoint>.mysql.database.oraclecloud.com -u admin -p

# Run schema
source /opt/hermes/init-schema.sql
```

### Step 5: Update Security Lists

Add ingress rule for MySQL:
- **Source CIDR**: <vm-private-ip>/32
- **Destination Port**: 3306
- **Protocol**: TCP

### Step 6: Deploy

```bash
git add -A
git commit -m "Migrate to OCI HeatWave"
git push
```

---

## Comparison

| Feature | MySQL in Docker | OCI HeatWave |
|---------|-----------------|--------------|
| **Cost** | Free | Free (50GB) |
| **Setup** | Easy | Medium |
| **Backups** | Manual | Automatic |
| **HA** | No | Yes |
| **Performance** | Good | Better |
| **Scaling** | Manual | Automatic |
| **Maintenance** | Manual | Managed |
| **Learning Value** | High | Medium |

## Recommendation

**For your use case (learning/portfolio):**

✅ **Keep MySQL in Docker** because:
1. Simpler architecture
2. Everything containerized
3. Easier to demonstrate
4. Better for k3s migration (Phase 2)
5. More portable

**Use OCI HeatWave if:**
- You need production-grade reliability
- You want automatic backups
- You need high availability
- You're building for real users

## Current Status

✅ **MySQL in Docker is working**
- Running on VM
- Connected to Node.js server
- Data persisted in Docker volume
- Health checks passing

No action needed unless you want managed MySQL!
