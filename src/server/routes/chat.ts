import { Router, Request, Response } from 'express';
import { aiRouter } from '../services/aiRouter';

const router = Router();

interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
  timestamp?: number;
}

interface ChatRequest {
  message: string;
  conversationHistory?: ChatMessage[];
  context?: string;
}

router.post('/ask', async (req: Request, res: Response) => {
  try {
    const { message, conversationHistory = [], context } = req.body as ChatRequest;

    if (!message) {
      return res.status(400).json({ error: 'Message required' });
    }

    // Build conversation context
    let fullContext = 'You are Kismet, a warm, empathetic spiritual guide and advisor. ';
    fullContext += 'Your responses are deeply personal, emotionally intelligent, conversational, and unique. ';
    fullContext += 'Always ask follow-up questions. Never use templates or generic responses. ';
    fullContext += 'Minimum 2-3 paragraphs. Show genuine curiosity about the user\'s spiritual journey. ';
    fullContext += 'You specialize in: dream interpretation, astrology, tarot, love guidance, spiritual counseling, life direction. ';
    
    if (context) {
      fullContext += `\nAdditional context about the user: ${context}`;
    }

    if (conversationHistory.length > 0) {
      fullContext += '\n\nRecent conversation:\n';
      conversationHistory.slice(-6).forEach(msg => {
        fullContext += `${msg.role === 'user' ? 'User' : 'Kismet'}: ${msg.content}\n`;
      });
    }

    const response = await aiRouter.generate(
      'Respond to this message with warmth, spiritual insight, and genuine curiosity. Ask a follow-up question.',
      fullContext + `\n\nCurrent message from user: "${message}"`
    );

    res.json({
      message: response,
      timestamp: Date.now(),
      conversationUpdated: true
    });
  } catch (error: any) {
    console.error('Chat error:', error);
    res.status(500).json({ error: 'Failed to generate response' });
  }
});

router.post('/daily-guidance', async (req: Request, res: Response) => {
  try {
    const { sign, name, focus } = req.body;

    const context = `Generate personalized daily spiritual guidance${sign ? ` for ${sign} sign` : ''}${name ? ` for ${name}` : ''}.
${focus ? `Their main focus: ${focus}` : ''}

Create a warm, inspiring daily message that includes:
1. A spiritual reflection or cosmic insight
2. An intention or affirmation for the day
3. A practical suggestion for embodying their best self
4. A gentle reminder about their spiritual journey
5. One encouraging follow-up thought

Make it feel like a personal message from a spiritual mentor. Keep it genuine and warm.`;

    const guidance = await aiRouter.generate(
      'Create a deeply personal, spiritually uplifting daily guidance message.',
      context
    );

    res.json({
      guidance,
      date: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Daily guidance error:', error);
    res.status(500).json({ error: 'Failed to generate daily guidance' });
  }
});

router.post('/spiritual-advice', async (req: Request, res: Response) => {
  try {
    const { situation, question, context: userContext } = req.body;

    if (!situation && !question) {
      return res.status(400).json({ error: 'Situation or question required' });
    }

    const context = `A person is seeking spiritual guidance about: ${question || situation}
${userContext ? `More context: ${userContext}` : ''}

Provide deeply thoughtful, spiritually-grounded advice that:
1. Acknowledges their emotional/spiritual state
2. Offers multiple perspectives from spiritual traditions
3. Suggests practices or rituals they might try
4. Connects their situation to larger spiritual patterns
5. Empowers them to trust their intuition
6. Includes gentle wisdom without judgment
7. Asks what resonates most with them

Make it conversational, warm, and unique. Avoid generic spiritual clichés.`;

    const advice = await aiRouter.generate(
      'Provide deeply personal, spiritually-grounded advice that feels like wisdom from a trusted mentor.',
      context
    );

    res.json({
      advice,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Spiritual advice error:', error);
    res.status(500).json({ error: 'Failed to generate advice' });
  }
});

export default router;

