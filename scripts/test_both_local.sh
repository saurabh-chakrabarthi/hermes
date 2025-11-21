#!/bin/bash

echo "🧪 Testing both Node.js server and Java client locally..."

# Start Node.js server in background
echo "1. Starting Node.js server on port 3000..."
cd server && npm run local &
NODE_PID=$!
cd ..

# Wait for Node.js to start
sleep 5

# Test Node.js server
echo "2. Testing Node.js server..."
curl -s http://localhost:3000/health && echo " ✅ Node.js ready"

# Start Java client in background
echo "3. Starting Java client on port 8080..."
export PAYMENT_SERVER_URL=http://localhost:3000
cd client && mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8080" &
JAVA_PID=$!
cd ..

# Wait for Java client
echo "4. Waiting for Java client to start..."
sleep 30

# Test Java client
echo "5. Testing Java client..."
curl -s http://localhost:8080/actuator/health && echo " ✅ Java client ready"

echo ""
echo "=== Access URLs ==="
echo "💳 Payment Server: http://localhost:3000/payment"
echo "📊 Client Dashboard: http://localhost:8080"

echo ""
echo "Press Ctrl+C to stop both services"

# Wait for user interrupt
trap "kill $NODE_PID $JAVA_PID 2>/dev/null; exit" INT
wait