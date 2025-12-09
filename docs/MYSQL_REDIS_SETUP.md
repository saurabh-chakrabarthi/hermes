# MySQL + Redis Setup Guide

## Overview

The Hermes Payment Portal now uses:
- **MySQL 8.0** for persistent data storage
- **Redis 7** for caching and performance optimization

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │────▶│   Node.js    │────▶│   MySQL     │
│  (Browser)  │     │   Server     │     │  Database   │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    Redis    │
                    │    Cache    │
                    └─────────────┘
```

## Database Schema

### Tables

1. **payments** - Main payment records
   - Primary key: `id` (UUID)
   - Unique: `reference` (REF001, REF002, etc.)
   - Indexes on: email, reference, created_at, status

2. **validation_results** - Payment validation checks
   - Foreign key to payments
   - Stores check type, result, and messages

3. **audit_log** - Audit trail for all actions
   - Tracks all payment modifications
   - Stores user agent and IP address

## Caching Strategy

### Cache-Aside Pattern

1. **Read Flow:**
   ```
   Request → Check Redis → Cache Hit? → Return cached data
                        ↓ Cache Miss
                   Query MySQL → Cache result → Return data
   ```

2. **Write Flow:**
   ```
   Request → Write to MySQL → Invalidate cache → Return success
   ```

3. **TTL:** 5 minutes (300 seconds)

### Cached Endpoints

- `GET /api/bookings` - All payments (cached for 5min)

### Cache Invalidation

- Automatic on `POST /api/bookings` (new payment)
- Automatic on payment updates

## Local Development

### Start with Docker Compose

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Check service status
docker compose ps

# Stop services
docker compose down
```

### Access Services

- **Node.js Server:** http://localhost:9292
- **MySQL:** localhost:3306
- **Redis:** localhost:6379
- **Dashboard:** http://localhost:8080

### Connect to MySQL

```bash
# Using Docker
docker exec -it mysql mysql -uroot -p hermes_payments

# Using MySQL client
mysql -h localhost -u root -p hermes_payments
```

### Connect to Redis

```bash
# Using Docker
docker exec -it redis redis-cli

# Check cached keys
docker exec -it redis redis-cli KEYS '*'

# Get cached value
docker exec -it redis redis-cli GET 'payments:all'
```

## Environment Variables

### Server (.env)

```bash
PORT=9292
NODE_ENV=production

# MySQL
DB_HOST=mysql
DB_USER=root
DB_PASSWORD=ChangeMe123!
DB_NAME=hermes_payments

# Redis
REDIS_URL=redis://redis:6379
```

### Docker Compose

```bash
DB_PASSWORD=ChangeMe123!
```

## Production Deployment (OCI)

### MySQL HeatWave Setup

1. **Create MySQL Database** (OCI Console)
   - Service: MySQL Database Service
   - Shape: MySQL.Free (Always Free)
   - Storage: 50GB
   - Network: Same VCN as compute instance

2. **Get Connection Details**
   ```bash
   DB_HOST=<mysql-endpoint>.mysql.database.oraclecloud.com
   DB_USER=admin
   DB_PASSWORD=<your-password>
   DB_NAME=hermes_payments
   ```

3. **Initialize Schema**
   ```bash
   mysql -h <endpoint> -u admin -p < server/db/schema.sql
   ```

### Redis on OCI VM

Redis runs in Docker container on the same VM:

```bash
# Already configured in docker-compose.yml
# Redis container: redis:7-alpine
# Port: 6379
# Data persisted in Docker volume
```

## Performance Metrics

### Without Cache
- Average response time: ~50-100ms
- Database queries per request: 1-3

### With Cache (5min TTL)
- Cache hit response time: ~5-10ms
- Cache miss response time: ~50-100ms
- Cache hit ratio: ~80-90% (typical)

### Savings
- **10x faster** on cache hits
- **90% reduction** in database load
- Better scalability

## Monitoring

### Check Cache Performance

```bash
# Redis stats
docker exec -it redis redis-cli INFO stats

# Cache hit/miss ratio
docker exec -it redis redis-cli INFO stats | grep keyspace
```

### Check Database Performance

```bash
# MySQL slow query log
docker exec -it mysql mysql -uroot -p -e "SHOW VARIABLES LIKE 'slow_query%'"

# Active connections
docker exec -it mysql mysql -uroot -p -e "SHOW PROCESSLIST"
```

## Troubleshooting

### MySQL Connection Issues

```bash
# Check MySQL is running
docker ps | grep mysql

# Check MySQL logs
docker logs mysql

# Test connection
docker exec -it mysql mysql -uroot -p -e "SELECT 1"
```

### Redis Connection Issues

```bash
# Check Redis is running
docker ps | grep redis

# Check Redis logs
docker logs redis

# Test connection
docker exec -it redis redis-cli PING
```

### Cache Not Working

```bash
# Check Redis connection in app logs
docker logs payment-server | grep Redis

# Manually test cache
docker exec -it redis redis-cli SET test "hello"
docker exec -it redis redis-cli GET test
```

## Next Steps

- [ ] Add Redis Streams for event processing
- [ ] Implement query result caching
- [ ] Add database connection pooling metrics
- [ ] Set up MySQL replication (if needed)
- [ ] Add cache warming strategies
