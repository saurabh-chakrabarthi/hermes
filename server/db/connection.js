const { MongoClient } = require('mongodb');

// Build MongoDB URI from components
const MONGODB_USER = process.env.MONGODB_USER || 'hermes_db_user';
const MONGODB_PASSWORD = process.env.MONGODB_PASSWORD;
const MONGODB_CLUSTER = process.env.MONGODB_CLUSTER || 'hermescluster.mf0xovo.mongodb.net';
const MONGODB_DATABASE = process.env.MONGODB_DATABASE || 'hermes_payments';

const uri = `mongodb+srv://${MONGODB_USER}:${MONGODB_PASSWORD}@${MONGODB_CLUSTER}/?appName=HermesCluster`;
const client = new MongoClient(uri);

let db;

async function connectDB() {
  try {
    await client.connect();
    db = client.db(MONGODB_DATABASE);
    console.log('✅ MongoDB connected successfully');
    
    // Create indexes for better performance
    await db.collection('payments').createIndex({ reference: 1 }, { unique: true });
    await db.collection('payments').createIndex({ email: 1 });
    await db.collection('payments').createIndex({ createdAt: -1 });
    
    return db;
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    throw error;
  }
}

function getDB() {
  if (!db) {
    throw new Error('Database not initialized. Call connectDB first.');
  }
  return db;
}

process.on('SIGINT', async () => {
  await client.close();
  process.exit(0);
});

module.exports = { connectDB, getDB };
