# ✨ Kismetly - AI-Driven Spiritual Guidance App

A fully AI-powered web application that provides spiritual guidance through dream interpretation, horoscopes, tarot readings, love compatibility analysis, and interactive chat with a spiritual advisor.

## 🌟 Features

### 🔮 Dream Interpretation
- Analyze dreams with psychological and spiritual depth
- Get symbolic meanings and emotional insights
- Multi-paragraph personalized interpretations
- Follow-up questions to deepen understanding

### ♈ Horoscope Reader
- Generate daily, weekly, or monthly horoscopes
- Get unique, never-repeated readings
- Includes love, career, health, and spiritual guidance
- Astrological compatibility analysis between signs

### 🃏 Tarot & Oracle
- Draw single cards or full spreads (Celtic Cross, Horseshoe, etc.)
- AI-generated narrative interpretations
- Personalized spiritual insights based on your question
- Support for reversed card meanings

### 💕 Love Compatibility
- Analyze romantic connection between two people
- Includes birth dates and zodiac signs
- Get relationship energy assessment
- Communication style and growth opportunities analysis

### 💬 Spiritual Chat
- Real-time conversation with Kismet (AI spiritual advisor)
- Multi-turn conversation with memory
- Personalized guidance on any spiritual topic
- Daily wisdom and affirmations

## 🏗️ Architecture

### Backend
- **Express.js** - REST API server
- **TypeScript** - Type-safe development
- **Multi-Provider AI Router** - Automatic failover between providers

### AI Providers (with automatic failover)
1. **OpenAI** - GPT-4o-mini (primary)
2. **Google Gemini** - Gemini Flash
3. **Anthropic Claude** - Claude 3.5 Sonnet
4. **Microsoft Copilot** - Copilot API
5. **Perplexity** - Search-style fallback

### Frontend
- **React 18** - Modern UI framework
- **TypeScript** - Type-safe components
- **Tailwind CSS** - Beautiful styling
- **Vite** - Fast development and bundling
- **Lucide React** - Icon library

## 📋 Requirements

- Node.js 18+
- npm or yarn
- At least one AI provider API key

## 🚀 Installation & Setup

### 1. Clone or navigate to the project
```bash
cd kismetly
```

### 2. Install dependencies
```bash
npm install
```

### 3. Set up environment variables
Create a `.env` file in the root directory:

```env
# OpenAI
OPENAI_API_KEY=sk_your_key_here

# Google Gemini
GOOGLE_GEMINI_API_KEY=your_key_here

# Anthropic Claude
ANTHROPIC_API_KEY=your_key_here

# Microsoft Copilot
COPILOT_API_KEY=your_key_here
COPILOT_ENDPOINT=https://api.copilot.microsoft.com

# Perplexity
PERPLEXITY_API_KEY=your_key_here

# Server
PORT=3000
NODE_ENV=development
```

**How to get API keys:**

- **OpenAI**: https://platform.openai.com/api-keys (free $5 trial)
- **Google Gemini**: https://ai.google.dev (free tier available)
- **Anthropic**: https://console.anthropic.com (free trial available)
- **Microsoft Copilot**: https://copilot.microsoft.com/api
- **Perplexity**: https://www.perplexity.ai/api

### 4. Start development server
```bash
npm run dev
```

This starts:
- **Backend**: http://localhost:3000
- **Frontend**: http://localhost:5173

### 5. Build for production
```bash
npm run build
```

### 6. Run production build
```bash
npm start
```

## 📚 API Endpoints

### Dream Interpretation
- `POST /api/dreams/interpret` - Interpret a dream
- `POST /api/dreams/symbol-analysis` - Analyze dream symbols

### Horoscope
- `POST /api/horoscope/generate` - Generate horoscope
- `POST /api/horoscope/compatibility` - Get zodiac compatibility
- `GET /api/horoscope/all-signs` - List all zodiac signs

### Tarot
- `POST /api/tarot/draw` - Draw tarot cards
- `GET /api/tarot/cards` - List all tarot cards

### Compatibility
- `POST /api/compatibility/analyze` - Analyze love compatibility
- `POST /api/compatibility/soulmate-insight` - Get soulmate guidance

### Chat
- `POST /api/chat/ask` - Ask Kismet a question
- `POST /api/chat/daily-guidance` - Get daily spiritual guidance
- `POST /api/chat/spiritual-advice` - Get spiritual advice

## 🔄 AI Router Failover System

The app automatically rotates between AI providers:

1. **OpenAI** (primary)
2. **Google Gemini** (fallback 1)
3. **Anthropic Claude** (fallback 2)
4. **Microsoft Copilot** (fallback 3)
5. **Perplexity** (fallback 4)

If a provider fails or hits rate limits, the router instantly switches to the next provider. If all fail, it generates intelligent human-like responses locally.

### Features
- ✅ Automatic provider rotation
- ✅ 10-second timeout per provider
- ✅ Free-tier usage prioritization
- ✅ No error messages shown to users
- ✅ Intelligent local fallback generation

## 🎨 Design Philosophy

Every response is designed to:
- ✨ Feel human, emotional, and warm
- 🗣️ Be conversational and guided
- ❓ Include follow-up questions
- 🧠 Maintain psychological and spiritual depth
- 🔄 Avoid repetition (unique every time)
- 💝 Build personal connection

**Minimum Requirements:**
- 3+ paragraphs for insights
- Professional spiritual guide tone
- Genuine curiosity and empathy
- No generic or templated responses

## 🔀 Automatic Merge System

This project includes an intelligent automatic merge system for handling conflicts when multiple AI agents modify the same file.

### Quick Start

```bash
# Process all conflicted files automatically
npm run merge:auto

# Process a specific file
npx tsx scripts/auto-merge.ts path/to/file.ts
```

### Features

- ✅ **Zero Manual Intervention**: All conflicts resolved automatically
- ✅ **Intelligent Merging**: Combines complementary changes
- ✅ **Quality-Aware**: Prefers optimized, well-integrated code
- ✅ **Syntax Validation**: Auto-fixes syntax errors
- ✅ **Multi-Language**: Supports TypeScript, Dart, React, JSON, and more

The merge system:
- Merges complementary functionality from different agents
- Combines formatting with logic changes
- Prefers versions that integrate better with the codebase
- Automatically fixes syntax errors
- Never leaves files in a broken state

See [MERGE_SYSTEM.md](./MERGE_SYSTEM.md) for detailed documentation.

### Setup Git Hooks (Optional)

```bash
# Make setup script executable (Unix/Mac)
chmod +x scripts/setup-merge-hooks.sh
./scripts/setup-merge-hooks.sh

# Or manually on Windows
npm run merge:auto
```

## 🛠️ Development

### Project Structure
```
kismetly/
├── src/
│   ├── server/
│   │   ├── services/
│   │   │   └── aiRouter.ts       # Multi-provider AI router
│   │   ├── routes/
│   │   │   ├── dreams.ts         # Dream interpretation routes
│   │   │   ├── horoscope.ts      # Horoscope routes
│   │   │   ├── tarot.ts          # Tarot reading routes
│   │   │   ├── compatibility.ts  # Love compatibility routes
│   │   │   └── chat.ts           # Chat routes
│   │   └── index.ts              # Express server
│   └── client/
│       ├── components/
│       │   ├── DreamInterpreter.tsx
│       │   ├── HoroscopeReader.tsx
│       │   ├── TarotReader.tsx
│       │   ├── LoveCompatibility.tsx
│       │   └── ChatAdvisor.tsx
│       ├── App.tsx               # Main app component
│       ├── main.tsx              # React entry point
│       └── index.css             # Tailwind styles
├── index.html                    # HTML entry point
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

### Key Technologies
- **TypeScript** - Type safety across full stack
- **Express** - Lightweight REST API
- **React** - Modern UI components
- **Vite** - Lightning-fast development
- **Tailwind CSS** - Utility-first styling
- **Axios** - API requests

## 🔐 Security Considerations

- All API keys are stored in `.env` (not tracked in git)
- API responses are not exposed to frontend (sensitive calls handled on backend)
- Error messages are sanitized before user display
- CORS is configured for local development

## 📦 Dependencies

### Backend
```json
{
  "express": "^4.18.2",
  "axios": "^1.6.0",
  "dotenv": "^16.3.1",
  "cors": "^2.8.5"
}
```

### Frontend
```json
{
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "lucide-react": "^0.263.1",
  "zustand": "^4.4.1"
}
```

### DevDependencies
```json
{
  "typescript": "^5.2.2",
  "tsx": "^4.0.0",
  "vite": "^5.0.0",
  "@vitejs/plugin-react": "^4.1.0",
  "tailwindcss": "^3.3.3",
  "concurrently": "^8.2.2"
}
```

## 🎯 Future Enhancements

- [ ] User authentication and profiles
- [ ] Conversation history storage
- [ ] Personalized user insights over time
- [ ] Push notifications for daily guidance
- [ ] Mobile app (React Native)
- [ ] Voice input/output
- [ ] Multi-language support
- [ ] Premium features and subscriptions
- [ ] Integration with calendar for predictions
- [ ] Community features and sharing

## 📞 Support

For issues or questions:
1. Check that all API keys are valid
2. Ensure Node.js version is 18+
3. Try clearing cache: `npm run build` and restart
4. Check console for detailed error messages

## 📄 License

This project is provided as-is for personal and commercial use.

## ✨ About Kismetly

Kismetly is built on the belief that AI can provide authentic, personalized spiritual guidance while maintaining warmth, empathy, and genuine connection. Every reading is unique, generated in real-time, and designed to make you feel truly seen and understood.

**Every moment is cosmically significant. Every answer is divinely timed. Every conversation matters.**

---

Made with 💜 and ✨ for your spiritual journey
