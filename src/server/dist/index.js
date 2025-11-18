"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
// Load environment variables
dotenv_1.default.config();
// Import routes
const dreams_1 = __importDefault(require("./routes/dreams"));
const horoscope_1 = __importDefault(require("./routes/horoscope"));
const tarot_1 = __importDefault(require("./routes/tarot"));
const compatibility_1 = __importDefault(require("./routes/compatibility"));
const chat_1 = __importDefault(require("./routes/chat"));
const app = (0, express_1.default)();
const PORT = parseInt(process.env.PORT || '3000', 10);
// Middleware - CORS configured
app.use((0, cors_1.default)({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: false
}));
app.use(express_1.default.json());
// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'Kismetly is running ✨' });
});
// API Routes
app.use('/api/dreams', dreams_1.default);
app.use('/api/horoscope', horoscope_1.default);
app.use('/api/tarot', tarot_1.default);
app.use('/api/compatibility', compatibility_1.default);
app.use('/api/chat', chat_1.default);
// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});
// Error handler
app.use((err, req, res, next) => {
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
exports.default = app;
