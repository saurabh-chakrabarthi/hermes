#!/bin/bash

echo "🚀 Starting Hermes Payment Portal (Node.js + Java Client)..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Clean up any existing containers
docker compose down -v

# Build and start services
echo "Building and starting services..."
docker compose up --build -d

echo "⏳ Waiting for services to initialize..."
sleep 30

echo ""
echo "=== Services Status ==="
docker compose ps

echo ""
echo "=== Access URLs ==="
echo "💳 Payment Server (Node.js): http://localhost:3000"
echo "📊 Client Dashboard (Java):  http://localhost:8081"
echo "🗄️  MySQL Database:          localhost:3306"
echo "🔴 Redis Cache:              localhost:6379"

echo ""
echo "=== Testing End-to-End Flow ==="
echo "1. Testing Node.js server health..."
curl -s http://localhost:3000/health && echo " ✅"

echo "2. Testing payment API..."
curl -s http://localhost:3000/api/bookings | jq '.' 2>/dev/null || curl -s http://localhost:3000/api/bookings

echo "3. Testing Java client health..."
curl -s http://localhost:8081/actuator/health 2>/dev/null && echo " ✅" || echo " ⏳ Still starting..."

echo "4. Creating test payment..."
curl -X POST http://localhost:3000/api/bookings \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","amount":1000}' && echo " ✅"

echo "5. Checking if payment appears in API..."
sleep 2
curl -s http://localhost:3000/api/bookings | grep "Test User" && echo " ✅ Payment created"

echo ""
echo "=== Manual Testing ==="
echo "1. Visit payment form: http://localhost:3000/payment"
echo "2. Submit a payment"
echo "3. Check dashboard: http://localhost:8081"
echo "4. Verify payment appears in dashboard"

echo ""
echo "=== Quick Commands ==="
echo "View logs:     docker compose logs -f"
echo "Stop services: docker compose down"
echo "Clean up:      docker compose down -v"