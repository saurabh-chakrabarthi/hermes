# Port Configuration Summary

## ✅ CONFIGURED PORTS

### OCI Security Lists (NSG)
- **9292**: Node.js Payment Server
- **8080**: Java Spring Boot Client  
- **22**: SSH access
- **3306**: MySQL (internal subnet only)

### Application Configuration
- **Node.js Server**: Port 9292 (`server/server.js`)
- **Java Client**: Port 8080 (`client/application.yml`)
- **MySQL HeatWave**: Port 3306 (private subnet)
- **Redis**: Port 6379 (localhost only)

### Free Tier Resources
- **VM**: `VM.Standard.E2.1.Micro` (Always Free)
- **MySQL**: `MySQL.Free` shape (Always Free)
- **Storage**: 47GB boot volume (Always Free limit)
- **Network**: VCN, subnets, gateways (Always Free)

### Access URLs (after deployment)
- **Payment Server**: `http://PUBLIC_IP:9292`
- **Client Dashboard**: `http://PUBLIC_IP:8080`
- **Health Check**: `http://PUBLIC_IP:9292/health`

All ports match OCI NSG configuration and free tier limits.