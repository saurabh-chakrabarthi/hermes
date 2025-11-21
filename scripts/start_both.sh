#!/bin/bash

echo "🚀 Starting both Node.js server and Java client..."

# Start Node.js server in background
echo "1. Starting Node.js server on port 3000..."
cd server
npm run local &
NODE_PID=$!
cd ..

# Wait for Node.js to start
sleep 3
echo "2. Testing Node.js server..."
curl -s http://localhost:3000/health && echo " ✅ Node.js ready"

# Start Java client
echo "3. Starting Java client on port 8080..."
cd client
export PAYMENT_SERVER_URL=http://localhost:3000
mvn spring-boot:run &
JAVA_PID=$!

echo ""
echo "=== Services Starting ==="
echo "💳 Payment Server: http://localhost:3000/payment"
echo "📊 Client Dashboard: http://localhost:8080"
echo ""
echo "Press Ctrl+C to stop both services"

# Cleanup on exit
trap "echo 'Stopping services...'; kill $NODE_PID $JAVA_PID 2>/dev/null; exit" INT
wait