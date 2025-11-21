# Development Scripts

## Local Development

### Start Both Services
```bash
./start_both.sh
```
Starts Node.js server (port 3000) and Java client (port 8080) locally.

### Test Node.js Only
```bash
./test_local.sh
```
Starts Node.js server with in-memory storage for quick testing.

### Restart Java Client
```bash
./restart_client.sh
```
Restarts Java Spring Boot client after configuration changes.

## Requirements

- Node.js 18+
- Java 17+
- Maven 3.6+

## Access URLs

- **Payment Form**: http://localhost:3000/payment
- **Dashboard**: http://localhost:8080/