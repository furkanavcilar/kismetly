import express, { Express } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import routes
import dreamRoutes from './routes/dreams';
import horoscopeRoutes from './routes/horoscope';
import tarotRoutes from './routes/tarot';
import compatibilityRoutes from './routes/compatibility';
import chatRoutes from './routes/chat';

const app: Express = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

// Middleware - CORS configured
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'Kismetly is running ✨' });
});

// API Routes
app.use('/api/dreams', dreamRoutes);
app.use('/api/horoscope', horoscopeRoutes);
app.use('/api/tarot', tarotRoutes);
app.use('/api/compatibility', compatibilityRoutes);
app.use('/api/chat', chatRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err: any, req: any, res: any, next: any) => {
  console.error('Server error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✨ Kismetly server running on port ${PORT}`);
  console.log(`🔮 Dream Interpretation: /api/dreams`);
  console.log(`♈ Horoscopes: /api/horoscope`);
  console.log(`🃏 Tarot Readings: /api/tarot`);
  console.log(`💕 Love Compatibility: /api/compatibility`);
  console.log(`💬 Chat & Guidance: /api/chat`);
  console.log(`❤️  Health Check: /health`);
});

export default app;
