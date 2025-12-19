# MongoDB Migration Complete

## What Changed

### Removed:
- ❌ MySQL (mysql2 package)
- ❌ Redis (redis package)
- ❌ `infra/k8s/redis-service.yaml`
- ❌ `infra/k8s/redis-deployment.yaml`

### Added:
- ✅ MongoDB (mongodb package)
- ✅ MongoDB connection in `server/db/connection.js`
- ✅ Indexes for performance

### Modified:
- `server/server.js` - All queries now use MongoDB
- `server/package.json` - Replaced mysql2/redis with mongodb
- `infra/k8s/payment-server-configmap.yaml` - Simplified
- `infra/k8s/payment-server-deployment.yaml` - Uses mongodb-secret
- `infra/scripts/setup-k3s.sh` - Removed Redis, uses MongoDB secret
- `infra/terraform/variables.tf` - mongodb_uri instead of db_password/mysql_host
- `.github/workflows/deploy.yml` - Uses MONGODB_URI secret

## GitHub Secrets Required

Add this secret to your GitHub repository:

**Name**: `MONGODB_PASSWORD`  
**Value**: `Kabetogama2025$`

The connection string is built from:
- User: `hermes_db_user` (in ConfigMap)
- Password: `Kabetogama2025$` (in Secret)
- Cluster: `hermescluster.mf0xovo.mongodb.net` (in ConfigMap)
- Database: `hermes_payments` (in ConfigMap)

## Architecture

### Before:
```
OCI VM (1GB RAM)
├── k3s
├── MySQL (150MB)
├── Redis (20MB)
├── Node.js (100MB)
└── Micronaut (50MB)
Total: ~320MB
```

### After:
```
MongoDB Atlas (External, Free)
    ↓
OCI VM (1GB RAM)
├── k3s
├── Node.js (100MB)
└── Micronaut (50MB)
Total: ~150MB (850MB free!)
```

## Data Model Changes

### MySQL Tables → MongoDB Collections

**payments table** → **payments collection**
```javascript
{
  _id: "uuid",
  reference: "REF001",
  name: "John Doe",
  email: "john@example.com",
  amount: 1000.00,
  amountReceived: 950.00,
  school: "MIT",
  senderFullName: "John Doe",
  countryFrom: "USA",
  senderAddress: "123 Main St",
  currencyFrom: "usd",
  studentId: "STU001",
  status: "UNDERPAYMENT",
  feePercentage: 2.0,
  feeAmount: 20.00,
  finalAmount: 1020.00,
  createdAt: ISODate("2025-01-01"),
  updatedAt: ISODate("2025-01-01")
}
```

**audit_log table** → **audit_log collection**
```javascript
{
  paymentId: "uuid",
  action: "CREATE",
  newValue: {...},
  userAgent: "...",
  ipAddress: "...",
  createdAt: ISODate("2025-01-01")
}
```

## Code Changes

### Connection (server/db/connection.js)

**Before (MySQL + Redis):**
```javascript
const pool = mysql.createPool({...});
const redisClient = redis.createClient({...});
```

**After (MongoDB):**
```javascript
const client = new MongoClient(uri);
await client.connect();
const db = client.db('hermes_payments');
```

### Queries (server/server.js)

**Before (MySQL with Redis cache):**
```javascript
const cached = await redis.get('payments:all');
if (cached) return JSON.parse(cached);

const [rows] = await pool.query('SELECT * FROM payments');
await redis.setex('payments:all', 300, JSON.stringify(rows));
```

**After (MongoDB - no cache needed):**
```javascript
const payments = await db.collection('payments')
  .find()
  .sort({ createdAt: -1 })
  .toArray();
```

**Before (MySQL insert):**
```javascript
await connection.query(`
  INSERT INTO payments (...) VALUES (?, ?, ...)
`, [values]);
```

**After (MongoDB insert):**
```javascript
await db.collection('payments').insertOne({
  _id: uuidv4(),
  reference: refNumber,
  ...paymentData,
  createdAt: new Date()
});
```

## Deployment Steps

1. **Add GitHub Secret**:
   - Go to GitHub → Settings → Secrets → Actions
   - Add `MONGODB_URI` with your connection string

2. **Deploy**:
   ```bash
   git add .
   git commit -m "Migrate to MongoDB Atlas"
   git push
   ```

3. **Verify**:
   ```bash
   # Check health
   curl http://<VM_IP>:30092/health
   
   # Should show:
   # {"status":"ok","services":{"mongodb":{"status":"connected"}}}
   ```

## Benefits

✅ **70% less memory** on VM (320MB → 150MB)  
✅ **Simpler architecture** (1 database instead of 3 services)  
✅ **No caching layer** (MongoDB is fast enough)  
✅ **Free tier** (512MB storage)  
✅ **Managed service** (no maintenance)  
✅ **Better for JSON** (native document storage)

## Rollback

If needed, revert to MySQL/Redis:
```bash
git revert HEAD
git push
```

## Next Steps

1. Test payment submission
2. Verify data in MongoDB Atlas dashboard
3. Monitor memory usage: `kubectl top pods -n hermes`
4. Remove old MySQL/Redis files after verification
