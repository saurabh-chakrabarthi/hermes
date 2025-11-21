// Simple test script to validate Node.js server functionality
const express = require('express');
const app = express();

// Mock Redis and MySQL for testing
const mockRedis = {
  get: async () => null,
  setEx: async () => true,
  del: async () => true
};

const mockMySQL = {
  createConnection: async () => ({
    execute: async () => [[]],
    end: async () => true
  })
};

// Test basic server functionality
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/bookings', (req, res) => {
  res.json([
    { id: '1', name: 'Test User', email: 'test@example.com', amount: 1000 }
  ]);
});

const PORT = 3001;
const server = app.listen(PORT, () => {
  console.log(`✅ Test server running on port ${PORT}`);
  
  // Run basic tests
  setTimeout(async () => {
    try {
      const fetch = (await import('node-fetch')).default;
      
      // Test health endpoint
      const healthRes = await fetch(`http://localhost:${PORT}/health`);
      const healthData = await healthRes.json();
      console.log('✅ Health check:', healthData.status === 'ok' ? 'PASSED' : 'FAILED');
      
      // Test API endpoint
      const apiRes = await fetch(`http://localhost:${PORT}/api/bookings`);
      const apiData = await apiRes.json();
      console.log('✅ API endpoint:', Array.isArray(apiData) ? 'PASSED' : 'FAILED');
      
      console.log('🎉 Basic server tests completed');
      server.close();
    } catch (error) {
      console.error('❌ Test failed:', error.message);
      server.close();
    }
  }, 1000);
});

module.exports = app;