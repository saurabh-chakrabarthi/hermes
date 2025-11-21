#!/bin/bash

echo "🧪 Testing Node.js server without Docker..."

cd server

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create test environment
cat > .env << EOF
PORT=3000
DB_HOST=localhost
DB_USER=test
DB_PASSWORD=test
DB_NAME=test_db
DB_PORT=3306
REDIS_URL=redis://localhost:6379
NODE_ENV=development
EOF

echo "🚀 Starting Node.js server on port 3000..."
echo "Press Ctrl+C to stop"

# Start server with mock connections
node -e "
const app = require('./server.js');
console.log('✅ Server should be running on http://localhost:3000');
console.log('✅ Test: curl http://localhost:3000/health');
"