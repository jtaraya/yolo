const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const upload = multer();
const productRoute = require('./routes/api/productRoute');

// Get MongoDB connection URI from environment (set by docker-compose)
const MONGODB_URI = process.env.MONGO_URI;

console.log('Attempting to connect to MongoDB with URI:', MONGODB_URI);

// Connection options
const mongoOptions = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  retryWrites: true,
};

// Function to connect with retry logic
const connectDB = async (retries = 15, delay = 3000) => {
  for (let i = 0; i < retries; i++) {
    try {
      await mongoose.connect(MONGODB_URI, mongoOptions);
      console.log('Database connected successfully');
      return;
    } catch (error) {
      console.log(`Connection attempt ${i + 1} failed:`, error.message);
      if (i < retries - 1) {
        console.log(`Retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      } else {
        console.log('All connection attempts failed');
        throw error;
      }
    }
  }
};

// Connect to database
connectDB().catch(error => {
  console.error('Failed to connect to database:', error);
  process.exit(1);
});

let db = mongoose.connection;

// Check for DB Errors
db.on('error', (error) => {
  console.log('Database error:', error);
});

// Initializing express
const app = express();

// Body parser middleware
app.use(express.json());

// Multer middleware
app.use(upload.array());

// Cors
app.use(cors());

// Health check endpoint
app.get('/health', (req, res) => {
  if (mongoose.connection.readyState === 1) {
    res.status(200).json({ status: 'OK', database: 'connected' });
  } else {
    res.status(503).json({ status: 'NOT OK', database: 'disconnected' });
  }
});

// Use Route
app.use('/api/products', productRoute);

// Define the PORT
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});