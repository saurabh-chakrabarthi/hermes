#!/bin/bash

echo "🔄 Restarting Java client..."

# Kill existing Java client
pkill -f "spring-boot:run"
sleep 2

# Start Java client
cd client
export PAYMENT_SERVER_URL=http://localhost:3000
mvn spring-boot:run &

echo "✅ Java client restarting on port 8080..."
echo "Wait 30 seconds then visit: http://localhost:8080"