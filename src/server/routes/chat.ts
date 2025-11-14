import { Router, Request, Response } from 'express';
import { aiRouter } from '../services/aiRouter';

const router = Router();

/* ----------------------------------------------
   TEST ENDPOINT — Check if AI Router works
---------------------------------------------- */
router.get('/test', async (req: Request, res: Response) => {
  try {
    const result = await aiRouter.generate("Hello! Test message.");
    res.json({
      ok: true,
      providerCount: (aiRouter as any).providers.length,
      message: result
    });
  } catch (err) {
    res.status(500).json({ error: 'AI test failed', details: err });
  }
});

/* ----------------------------------------------
   MAIN CHAT — Kismet Spiritual Chat
---------------------------------------------- */
router.post('/ask', async (req: Request, res: Response) => {
  try {
    const { message, conversationHistory = [], context } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message required' });
    }

    // Base context
    let fullContext = `
You are Kismet, a warm, empathetic spiritual guide and advisor.
Your responses are emotionally intelligent, deeply personal, poetic, and conversational.
Always ask a follow-up question.
Never use templates.
Minimum 2–3 paragraphs.
You specialize in:
- Dream interpretation
- Astrology
- Tarot
- Love guidance
- Spiritual counseling
- Energetic alignment
`;

    // Add custom user context
    if (context) {
      fullContext += `\nUser Context: ${context}`;
    }

    // Add conversation history
    if (conversationHistory.length > 0) {
      fullContext += `\nRecent conversation:\n`;
      conversationHistory.slice(-6).forEach(msg => {
        fullContext += `${msg.role === 'user' ? 'User' : 'Kismet'}: ${msg.content}\n`;
      });
    }

    const response = await aiRouter.generate(
      `Respond to the user with spiritual warmth, insight, and curiosity.`,
      fullContext + `\n\nUser says: "${message}"`
    );

    res.json({
      message: response,
      timestamp: Date.now(),
      conversationUpdated: true,
    });
  } catch (error) {
    console.error("Chat error:", error);
    res.status(500).json({ error: 'Failed to generate response' });
  }
});

/* ----------------------------------------------
   DAILY GUIDANCE
---------------------------------------------- */
router.post('/daily-guidance', async (req: Request, res: Response) => {
  try {
    const { sign, name, focus } = req.body;

    const context = `
Generate personalized daily spiritual guidance${sign ? ` for ${sign}` : ''}${name ? ` for ${name}` : ''}.
Focus: ${focus || 'General focus'}

Include:
1. Spiritual reflection
2. Intention for the day
3. Practical grounding suggestion
4. Energetic insight
5. One warm follow-up question
`;

    const guidance = await aiRouter.generate(
      'Create a beautifully personal, uplifting, spiritually aligned message.',
      context
    );

    res.json({ guidance, date: new Date().toISOString() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate daily guidance' });
  }
});

/* ----------------------------------------------
   SPIRITUAL ADVICE
---------------------------------------------- */
router.post('/spiritual-advice', async (req: Request, res: Response) => {
  try {
    const { situation, question, context: userContext } = req.body;

    if (!situation && !question) {
      return res.status(400).json({ error: 'Situation or question required' });
    }

    const context = `
A person seeks guidance about: ${question || situation}
${userContext ? `More context: ${userContext}` : ''}

Provide advice that:
- Acknowledges emotional/spiritual state
- Offers multi-tradition spiritual perspectives
- Suggests rituals or practices
- Connects to cosmic/energetic patterns
- Encourages intuition
- Asks one gentle follow-up question
`;

    const advice = await aiRouter.generate(
      'Provide deeply personal, spiritually grounded advice that feels like divine mentorship.',
      context
    );

    res.json({ advice, timestamp: new Date().toISOString() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate advice' });
  }
});

export default router;
