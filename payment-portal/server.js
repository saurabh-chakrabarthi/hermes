const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const REDIS_SERVICE_URL = process.env.REDIS_SERVICE_URL || 'http://payment-redis-service:8081';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Health check for server
app.get('/health', async (req, res) => {
  const estTime = new Date().toLocaleString("sv-SE", {timeZone: "America/New_York"}).replace(' ', 'T') + '-05:00';
  
  let overallStatus = 'ok';
  let redisServiceStatus = 'disconnected';
  let redisServiceError = null;
  
  // Check Redis service health
  try {
    const response = await axios.get(`${REDIS_SERVICE_URL}/health`, { timeout: 5000 });
    redisServiceStatus = response.data.status || 'connected';
  } catch (err) {
    redisServiceStatus = 'error';
    redisServiceError = err.message;
    overallStatus = 'degraded';
    console.error('Redis service health check failed:', err.message);
  }
  
  const response = { 
    status: overallStatus,
    timestamp: estTime,
    services: {
      redisService: {
        status: redisServiceStatus,
        error: redisServiceError
      }
    }
  };
  
  const statusCode = overallStatus === 'ok' ? 200 : 503;
  res.status(statusCode).json(response);
});

// Get all payments from Redis service
app.get('/api/bookings', async (req, res) => {
  try {
    const response = await axios.get(`${REDIS_SERVICE_URL}/api/transactions`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching payments:', error.message);
    res.status(500).json({ error: 'Failed to fetch payments' });
  }
});

// Create new payment via Redis service
app.post('/api/bookings', async (req, res) => {
  try {
    const payload = {
      name: req.body.name,
      email: req.body.email,
      amount: req.body.amount,
      school: req.body.school || 'Unknown',
      countryFrom: req.body.country_from || 'Unknown',
      senderAddress: req.body.sender_address || 'Unknown',
      currencyFrom: req.body.currency_from || 'usd',
      studentId: req.body.student_id || 'Unknown'
    };

    const response = await axios.post(
      `${REDIS_SERVICE_URL}/api/transactions`,
      payload
    );

    res.status(201).json(response.data);
  } catch (error) {
    console.error('Error creating payment:', error.message);
    res.status(500).json({ error: 'Failed to create payment' });
  }
});

// Form routes
app.get('/', (req, res) => res.redirect('/payment'));
app.get('/payment', (req, res) => res.sendFile(__dirname + '/public/booking.html'));

app.post('/payment', async (req, res) => {
  try {
    const payload = {
      name: req.body.name,
      email: req.body.email,
      amount: req.body.amount,
      school: req.body.school || 'Unknown',
      countryFrom: req.body.country_from || 'Unknown',
      senderAddress: req.body.sender_address || 'Unknown',
      currencyFrom: req.body.currency_from || 'usd',
      studentId: req.body.student_id || 'Unknown'
    };

    await axios.post(`${REDIS_SERVICE_URL}/api/transactions`, payload);
    res.sendFile(__dirname + '/public/confirmation.html');
  } catch (error) {
    console.error('Error creating payment:', error.message);
    res.status(500).send('Error processing payment');
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
