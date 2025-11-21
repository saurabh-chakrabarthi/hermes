const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// In-memory storage for local testing
let payments = [
  { id: '1', reference: 'REF001', name: 'John Doe', email: 'john@mit.edu', amount: 25000, amountReceived: 24800, school: 'MIT', senderFullName: 'John Doe', countryFrom: 'USA', senderAddress: '123 Main St', currencyFrom: 'usd', studentId: 'MIT001', created_at: new Date() },
  { id: '2', reference: 'REF002', name: 'Jane Smith', email: 'jane@stanford.edu', amount: 30000, amountReceived: 31500, school: 'Stanford', senderFullName: 'Jane Smith', countryFrom: 'USA', senderAddress: '456 Oak Ave', currencyFrom: 'usd', studentId: 'STF002', created_at: new Date() }
];

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/bookings', (req, res) => {
  res.json(payments);
});

app.post('/api/bookings', (req, res) => {
  // Generate random amount received (80% to 120% of tuition amount)
  const tuitionAmount = parseFloat(req.body.amount);
  const randomFactor = 0.8 + (Math.random() * 0.4); // 0.8 to 1.2
  const amountReceived = Math.round(tuitionAmount * randomFactor * 100) / 100;
  
  const payment = {
    id: uuidv4(),
    reference: 'REF' + (payments.length + 1).toString().padStart(3, '0'),
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
    created_at: new Date()
  };
  payments.push(payment);
  res.status(201).json(payment);
});

app.get('/', (req, res) => res.redirect('/payment'));
app.get('/payment', (req, res) => res.sendFile(__dirname + '/public/booking.html'));

app.post('/payment', (req, res) => {
  // Generate random amount received (80% to 120% of tuition amount)
  const tuitionAmount = parseFloat(req.body.amount);
  const randomFactor = 0.8 + (Math.random() * 0.4); // 0.8 to 1.2
  const amountReceived = Math.round(tuitionAmount * randomFactor * 100) / 100;
  
  const payment = {
    id: uuidv4(),
    reference: 'REF' + (payments.length + 1).toString().padStart(3, '0'),
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
    created_at: new Date()
  };
  payments.push(payment);
  res.sendFile(__dirname + '/public/confirmation.html');
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Simple server running on http://0.0.0.0:${PORT}`);
});