#!/bin/bash

echo "🧪 Testing Node.js server locally..."

cd server

# Install dependencies
npm install

# Start simple server (no DB required)
echo "🚀 Starting server on http://localhost:3000"
npm run local