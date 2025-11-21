# Hermes Payment Server (Node.js)

Modern Node.js payment server with Express, MySQL HeatWave, and Redis caching.

## Architecture

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Client UI     │    │   Node.js    │    │  OCI MySQL      │
│   (Spring Boot) │◄──►│   Express    │◄──►│  HeatWave       │
│                 │    │   Server     │    │                 │
└─────────────────┘    └──────┬───────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Redis Cache   │
                       │   (Sessions,    │
                       │   Temp Data)    │
                       └─────────────────┘
```

## Features

- **Express.js** server with security middleware
- **MySQL HeatWave** for persistent storage
- **Redis** for caching and session management
- **Rate limiting** and input validation
- **Modern payment form** with Bootstrap UI
- **RESTful API** endpoints

## API Endpoints

- `GET /health` - Health check
- `GET /` - Redirect to payment form
- `GET /payment` - Payment booking form
- `POST /payment` - Process payment (form submission)
- `GET /api/bookings` - Get all payments (JSON)
- `POST /api/bookings` - Create payment (JSON API)

## Environment Variables

```bash
PORT=80
DB_HOST=mysql-host
DB_USER=admin
DB_PASSWORD=your-password
DB_NAME=hermes_payments
DB_PORT=3306
REDIS_URL=redis://localhost:6379
NODE_ENV=production
```

## Local Development

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Start server
npm start

# Development with auto-reload
npm run dev
```

## Database Schema

```sql
CREATE TABLE payments (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  school VARCHAR(100),
  student_id VARCHAR(50),
  country_from VARCHAR(50),
  sender_address TEXT,
  currency_from VARCHAR(3) DEFAULT 'usd',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Caching Strategy

- **Payment List**: Cached for 5 minutes
- **Cache Invalidation**: On new payment creation
- **Redis Keys**: `payments:all`

## Security Features

- Helmet.js for security headers
- Rate limiting (100 requests per 15 minutes)
- Input validation with Joi
- CORS enabled
- SQL injection protection with prepared statements