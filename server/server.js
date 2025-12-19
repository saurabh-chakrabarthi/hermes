const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const { connectDB, getDB } = require('./db/connection');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Initialize MongoDB connection
let dbReady = false;
connectDB().then(() => {
  dbReady = true;
}).catch(err => {
  console.error('Failed to connect to MongoDB:', err);
  process.exit(1);
});

// Health check
app.get('/health', async (req, res) => {
  const estTime = new Date().toLocaleString("sv-SE", {timeZone: "America/New_York"}).replace(' ', 'T') + '-05:00';
  
  let overallStatus = 'ok';
  let mongoStatus = 'disconnected';
  let mongoError = null;
  
  // Test MongoDB connection
  try {
    if (dbReady) {
      const db = getDB();
      await db.admin().ping();
      mongoStatus = 'connected';
    } else {
      mongoStatus = 'initializing';
      overallStatus = 'degraded';
    }
  } catch (err) {
    mongoStatus = 'error';
    mongoError = err.message;
    overallStatus = 'degraded';
    console.error('MongoDB health check failed:', err);
  }
  
  const response = { 
    status: overallStatus,
    timestamp: estTime,
    services: {
      mongodb: {
        status: mongoStatus,
        error: mongoError
      }
    }
  };
  
  const statusCode = overallStatus === 'ok' ? 200 : 503;
  res.status(statusCode).json(response);
});

// Get all payments
app.get('/api/bookings', async (req, res) => {
  try {
    const db = getDB();
    const payments = await db.collection('payments')
      .find()
      .sort({ createdAt: -1 })
      .toArray();

    res.json(payments);
  } catch (error) {
    console.error('Error fetching payments:', error);
    res.status(500).json({ error: 'Failed to fetch payments' });
  }
});

// Create new payment
app.post('/api/bookings', async (req, res) => {
  try {
    const db = getDB();
    
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

    // Get next reference number
    const count = await db.collection('payments').countDocuments();
    const refNumber = 'REF' + (count + 1).toString().padStart(3, '0');

    // Create payment document
    const payment = {
      _id: uuidv4(),
      reference: refNumber,
      name: req.body.name,
      email: req.body.email,
      amount: tuitionAmount,
      amountReceived: amountReceived,
      school: req.body.school || 'Unknown',
      senderFullName: req.body.name,
      countryFrom: req.body.country_from || 'Unknown',
      senderAddress: req.body.sender_address || 'Unknown',
      currencyFrom: req.body.currency_from || 'usd',
      studentId: req.body.student_id || 'Unknown',
      status: status,
      feePercentage: feePercentage,
      feeAmount: feeAmount,
      finalAmount: finalAmount,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await db.collection('payments').insertOne(payment);

    // Insert audit log
    await db.collection('audit_log').insertOne({
      paymentId: payment._id,
      action: 'CREATE',
      newValue: req.body,
      userAgent: req.headers['user-agent'],
      ipAddress: req.ip,
      createdAt: new Date()
    });

    res.status(201).json(payment);
  } catch (error) {
    console.error('Error creating payment:', error);
    res.status(500).json({ error: 'Failed to create payment' });
  }
});

// Form routes
app.get('/', (req, res) => res.redirect('/payment'));
app.get('/payment', (req, res) => res.sendFile(__dirname + '/public/booking.html'));

app.post('/payment', async (req, res) => {
  try {
    const db = getDB();
    
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

    const count = await db.collection('payments').countDocuments();
    const refNumber = 'REF' + (count + 1).toString().padStart(3, '0');

    const payment = {
      _id: uuidv4(),
      reference: refNumber,
      name: req.body.name,
      email: req.body.email,
      amount: tuitionAmount,
      amountReceived: amountReceived,
      school: req.body.school || 'Unknown',
      senderFullName: req.body.name,
      countryFrom: req.body.country_from || 'Unknown',
      senderAddress: req.body.sender_address || 'Unknown',
      currencyFrom: req.body.currency_from || 'usd',
      studentId: req.body.student_id || 'Unknown',
      status: status,
      feePercentage: feePercentage,
      feeAmount: feeAmount,
      finalAmount: finalAmount,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await db.collection('payments').insertOne(payment);

    res.sendFile(__dirname + '/public/confirmation.html');
  } catch (error) {
    console.error('Error creating payment:', error);
    res.status(500).send('Error processing payment');
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
});
