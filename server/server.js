const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mysql = require('mysql2/promise');
const redis = require('redis');
const { v4: uuidv4 } = require('uuid');
const Joi = require('joi');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 9292;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api', limiter);

// Database connection
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'hermes_payments',
  port: process.env.DB_PORT || 3306
};

// Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

// Payment validation schema
const paymentSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  amount: Joi.number().positive().max(10000000).required(),
  school: Joi.string().optional(),
  student_id: Joi.string().optional(),
  country_from: Joi.string().optional(),
  sender_address: Joi.string().optional(),
  currency_from: Joi.string().valid('usd', 'eur', 'cad').default('usd')
});

// Initialize connections
async function initializeConnections() {
  try {
    // Connect to Redis with error handling
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    await redisClient.connect();
    console.log('✅ Redis connected');

    // Test MySQL connection with retry
    let retries = 5;
    while (retries > 0) {
      try {
        const connection = await mysql.createConnection(dbConfig);
        await connection.execute('SELECT 1');
        await connection.end();
        console.log('✅ MySQL connected');
        break;
      } catch (err) {
        console.log(`MySQL connection failed, retrying... (${retries} attempts left)`);
        retries--;
        if (retries === 0) throw err;
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }

    // Create tables if not exist
    await createTables();
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    process.exit(1);
  }
}

// Create database tables
async function createTables() {
  const connection = await mysql.createConnection(dbConfig);
  
  await connection.execute(`
    CREATE TABLE IF NOT EXISTS payments (
      id VARCHAR(36) PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(255) NOT NULL,
      amount DECIMAL(12,2) NOT NULL,
      school VARCHAR(100),
      student_id VARCHAR(50),
      country_from VARCHAR(50),
      sender_address TEXT,
      currency_from VARCHAR(3) DEFAULT 'usd',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_email (email),
      INDEX idx_created_at (created_at)
    )
  `);
  
  await connection.end();
  console.log('✅ Database tables ready');
}

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Get all payments with caching
app.get('/api/bookings', async (req, res) => {
  try {
    // Check cache first
    const cached = await redisClient.get('payments:all');
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    // Fetch from database
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute(
      'SELECT id, name, email, amount, school, student_id, country_from, currency_from, created_at FROM payments ORDER BY created_at DESC'
    );
    await connection.end();

    // Cache for 5 minutes
    await redisClient.setEx('payments:all', 300, JSON.stringify(rows));
    
    res.json(rows);
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create payment
app.post('/api/bookings', async (req, res) => {
  try {
    // Validate input
    const { error, value } = paymentSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const paymentId = uuidv4();
    const payment = { id: paymentId, ...value };

    // Save to database
    const connection = await mysql.createConnection(dbConfig);
    await connection.execute(
      `INSERT INTO payments (id, name, email, amount, school, student_id, country_from, sender_address, currency_from) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [payment.id, payment.name, payment.email, payment.amount, payment.school, payment.student_id, payment.country_from, payment.sender_address, payment.currency_from]
    );
    await connection.end();

    // Clear cache
    await redisClient.del('payments:all');

    res.status(201).json({ id: paymentId, message: 'Payment created successfully' });
  } catch (error) {
    console.error('Error creating payment:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Serve booking form
app.get('/', (req, res) => {
  res.redirect('/payment');
});

app.get('/payment', (req, res) => {
  res.sendFile(__dirname + '/public/booking.html');
});

app.post('/payment', async (req, res) => {
  try {
    const { error, value } = paymentSchema.validate(req.body);
    if (error) {
      return res.status(400).send('Invalid payment data');
    }

    const paymentId = uuidv4();
    const payment = { id: paymentId, ...value };

    const connection = await mysql.createConnection(dbConfig);
    await connection.execute(
      `INSERT INTO payments (id, name, email, amount, school, student_id, country_from, sender_address, currency_from) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [payment.id, payment.name, payment.email, payment.amount, payment.school, payment.student_id, payment.country_from, payment.sender_address, payment.currency_from]
    );
    await connection.end();

    await redisClient.del('payments:all');
    
    res.sendFile(__dirname + '/public/confirmation.html');
  } catch (error) {
    console.error('Error processing payment:', error);
    res.status(500).send('Payment processing failed');
  }
});

// Start server
async function startServer() {
  await initializeConnections();
  
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Hermes Payment Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer().catch(console.error);