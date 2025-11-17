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
const PORT = process.env.PORT || 3000;

// Middleware - CORS configured for Flutter emulator
app.use(cors({
  origin: '*', // Allow all origins (for development)
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

// Listen on 0.0.0.0 to allow connections from Android emulator (10.0.2.2)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔═══════════════════════════════════════════╗
║         ✨ KISMETLY ✨ LAUNCHED            ║
║    AI-Driven Spiritual Guidance App       ║
║                                           ║
║  Server running on: http://0.0.0.0:${PORT}      ║
║  Accessible from: http://localhost:${PORT}     ║
║  Android emulator: http://10.0.2.2:${PORT}     ║
║                                           ║
║  🔮 Dream Interpretation: /api/dreams     ║
║  ♈ Horoscopes: /api/horoscope             ║
║  🃏 Tarot Readings: /api/tarot             ║
║  💕 Love Compatibility: /api/compatibility ║
║  💬 Chat & Guidance: /api/chat             ║
║  ❤️  Health Check: /health                 ║
╚═══════════════════════════════════════════╝
  `);
});

export default app;

