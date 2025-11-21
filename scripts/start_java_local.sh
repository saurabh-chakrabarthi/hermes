#!/bin/bash

echo "🚀 Starting Java Client locally..."

cd client

# Check if Maven is available
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven not found. Please install Maven first."
    exit 1
fi

# Set environment variable for Node.js server
export PAYMENT_SERVER_URL=http://localhost:3000

# Start Java client
echo "Starting Java client on port 8080..."
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8080"