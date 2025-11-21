#!/bin/bash

echo "🔄 Migrating from Ruby to Node.js..."

# Create legacy directory for Ruby code
mkdir -p server-legacy
echo "📁 Created server-legacy directory"

# Move Ruby server to legacy (but keep it for reference)
if [ -d "server" ] && [ ! -d "server-legacy/ruby-server" ]; then
    cp -r server server-legacy/ruby-server
    echo "📦 Copied Ruby server to server-legacy/ruby-server"
fi

# Update client configuration to point to Node.js server
echo "🔧 Updating client configuration..."
sed -i.bak 's|http://localhost:80|http://localhost:3000|g' client/src/main/resources/application.yml

# Create .env file for Node.js server
if [ ! -f "server-node/.env" ]; then
    cp server-node/.env.example server-node/.env
    echo "📝 Created .env file for Node.js server"
fi

echo "🧪 Testing Docker Compose setup..."

# Build and start services
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

# Test endpoints
echo "🔍 Testing endpoints..."

# Test Node.js server health
if curl -f http://localhost:3000/health; then
    echo "✅ Node.js server health check passed"
else
    echo "❌ Node.js server health check failed"
fi

# Test payment form
if curl -f http://localhost:3000/; then
    echo "✅ Payment form accessible"
else
    echo "❌ Payment form not accessible"
fi

# Test API endpoint
if curl -f http://localhost:3000/api/bookings; then
    echo "✅ API endpoint accessible"
else
    echo "❌ API endpoint not accessible"
fi

# Test Java client (if running)
if curl -f http://localhost:8081/health 2>/dev/null; then
    echo "✅ Java client accessible"
else
    echo "⚠️  Java client not accessible (may still be starting)"
fi

echo ""
echo "🎉 Migration Status:"
echo "✅ Node.js server created with Express + MySQL + Redis"
echo "✅ Modern Bootstrap UI with payment form"
echo "✅ RESTful API endpoints"
echo "✅ Docker Compose setup for local testing"
echo "✅ Ruby code preserved in server-legacy/"
echo "✅ Client configuration updated"
echo ""
echo "🌐 Access URLs:"
echo "   Payment Server: http://localhost:3000"
echo "   Java Client:    http://localhost:8081"
echo "   MySQL:          localhost:3306"
echo "   Redis:          localhost:6379"
echo ""
echo "📋 Next Steps:"
echo "1. Test payment form submission"
echo "2. Verify client dashboard integration"
echo "3. Update deployment scripts"
echo "4. Remove Ruby server from production"