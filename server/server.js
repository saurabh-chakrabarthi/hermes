const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const { pool, redisClient } = require('./db/connection');

const app = express();
const PORT = process.env.PORT || 3000;
const CACHE_TTL = 300; // 5 minutes

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Health check
app.get('/health', async (req, res) => {
  const estTime = new Date().toLocaleString("sv-SE", {timeZone: "America/New_York"}).replace(' ', 'T') + '-05:00';
  
  let overallStatus = 'ok';
  let mysqlStatus = 'disconnected';
  let mysqlError = null;
  let redisStatus = 'disconnected';
  let redisError = null;
  
  // Test MySQL connection
  try {
    await pool.query('SELECT 1');
    mysqlStatus = 'connected';
  } catch (err) {
    mysqlStatus = 'error';
    mysqlError = err.message;
    overallStatus = 'degraded';
    console.error('MySQL health check failed:', err);
  }
  
  // Test Redis connection
  try {
    if (redisClient.isOpen) {
      await redisClient.ping();
      redisStatus = 'connected';
    } else {
      redisStatus = 'disconnected';
      redisError = 'Redis client not open';
      overallStatus = 'degraded';
    }
  } catch (err) {
    redisStatus = 'error';
    redisError = err.message;
    overallStatus = 'degraded';
    console.error('Redis health check failed:', err);
  }
  
  const response = { 
    status: overallStatus,
    timestamp: estTime,
    services: {
      mysql: {
        status: mysqlStatus,
        error: mysqlError
      },
      redis: {
        status: redisStatus,
        error: redisError
      }
    }
  };
  
  // Return 503 if any service is down
  const statusCode = overallStatus === 'ok' ? 200 : 503;
  res.status(statusCode).json(response);
});

// Get all payments with caching
app.get('/api/bookings', async (req, res) => {
  try {
    // Try cache first
    const cached = await redisClient.get('payments:all');
    if (cached) {
      console.log('📦 Cache hit: payments');
      return res.json(JSON.parse(cached));
    }

    // Query database
    const [rows] = await pool.query(`
      SELECT * FROM payments 
      ORDER BY created_at DESC
    `);

    // Cache the result
    await redisClient.setEx('payments:all', CACHE_TTL, JSON.stringify(rows));
    console.log('💾 Cache miss: payments (cached for 5min)');

    res.json(rows);
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ error: 'Failed to fetch payments' });
  }
});

// Create new payment
app.post('/api/bookings', async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const tuitionAmount = parseFloat(req.body.amount);
    const randomFactor = 0.8 + (Math.random() * 0.4);
    const amountReceived = Math.round(tuitionAmount * randomFactor * 100) / 100;
    
    // Calculate fee (2-5% based on amount)
    let feePercentage = 2.0;
    if (tuitionAmount > 50000) feePercentage = 5.0;
    else if (tuitionAmount > 30000) feePercentage = 3.0;
    
    const feeAmount = Math.round(tuitionAmount * (feePercentage / 100) * 100) / 100;
    const finalAmount = tuitionAmount + feeAmount;
    
    // Determine status
    let status = 'EXACT';
    if (amountReceived < tuitionAmount) status = 'UNDERPAYMENT';
    else if (amountReceived > tuitionAmount) status = 'OVERPAYMENT';

    const paymentId = uuidv4();
    
    // Get next reference number
    const [refResult] = await connection.query(
      'SELECT COUNT(*) as count FROM payments'
    );
    const refNumber = 'REF' + (refResult[0].count + 1).toString().padStart(3, '0');

    // Insert payment
    await connection.query(`
      INSERT INTO payments (
        id, reference, name, email, amount, amount_received, 
        school, sender_full_name, country_from, sender_address, 
        currency_from, student_id, status, fee_percentage, 
        fee_amount, final_amount
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      paymentId, refNumber, req.body.name, req.body.email,
      tuitionAmount, amountReceived, req.body.school || 'Unknown',
      req.body.name, req.body.country_from || 'Unknown',
      req.body.sender_address || 'Unknown', req.body.currency_from || 'usd',
      req.body.student_id || 'Unknown', status, feePercentage,
      feeAmount, finalAmount
    ]);

    // Insert audit log
    await connection.query(`
      INSERT INTO audit_log (payment_id, action, new_value, user_agent, ip_address)
      VALUES (?, 'CREATE', ?, ?, ?)
    `, [
      paymentId, JSON.stringify(req.body),
      req.headers['user-agent'], req.ip
    ]);

    await connection.commit();

    // Invalidate cache
    await redisClient.del('payments:all');

    const [payment] = await connection.query(
      'SELECT * FROM payments WHERE id = ?', [paymentId]
    );

    res.status(201).json(payment[0]);
  } catch (error) {
    await connection.rollback();
    console.error('Error creating payment:', error);
    res.status(500).json({ error: 'Failed to create payment' });
  } finally {
    connection.release();
  }
});

// Form routes
app.get('/', (req, res) => res.redirect('/payment'));
app.get('/payment', (req, res) => res.sendFile(__dirname + '/public/booking.html'));

app.post('/payment', async (req, res) => {
  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    const tuitionAmount = parseFloat(req.body.amount);
    const randomFactor = 0.8 + (Math.random() * 0.4);
    const amountReceived = Math.round(tuitionAmount * randomFactor * 100) / 100;
    
    let feePercentage = 2.0;
    if (tuitionAmount > 50000) feePercentage = 5.0;
    else if (tuitionAmount > 30000) feePercentage = 3.0;
    
    const feeAmount = Math.round(tuitionAmount * (feePercentage / 100) * 100) / 100;
    const finalAmount = tuitionAmount + feeAmount;
    
    let status = 'EXACT';
    if (amountReceived < tuitionAmount) status = 'UNDERPAYMENT';
    else if (amountReceived > tuitionAmount) status = 'OVERPAYMENT';

    const paymentId = uuidv4();
    
    const [refResult] = await connection.query(
      'SELECT COUNT(*) as count FROM payments'
    );
    const refNumber = 'REF' + (refResult[0].count + 1).toString().padStart(3, '0');

    await connection.query(`
      INSERT INTO payments (
        id, reference, name, email, amount, amount_received, 
        school, sender_full_name, country_from, sender_address, 
        currency_from, student_id, status, fee_percentage, 
        fee_amount, final_amount
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      paymentId, refNumber, req.body.name, req.body.email,
      tuitionAmount, amountReceived, req.body.school || 'Unknown',
      req.body.name, req.body.country_from || 'Unknown',
      req.body.sender_address || 'Unknown', req.body.currency_from || 'usd',
      req.body.student_id || 'Unknown', status, feePercentage,
      feeAmount, finalAmount
    ]);

    await connection.commit();
    await redisClient.del('payments:all');

    res.sendFile(__dirname + '/public/confirmation.html');
  } catch (error) {
    await connection.rollback();
    console.error('Error creating payment:', error);
    res.status(500).send('Error processing payment');
  } finally {
    connection.release();
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
