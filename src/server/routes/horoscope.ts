import { Router, Request, Response } from 'express';
import { aiRouter } from '../services/aiRouter';

const router = Router();

const zodiacSigns = [
  'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
  'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
];

interface HoroscopeRequest {
  sign: string;
  timeframe?: 'daily' | 'weekly' | 'monthly';
}

router.post('/generate', async (req: Request, res: Response) => {
  try {
    const { sign, timeframe = 'daily' } = req.body as HoroscopeRequest;

    if (!sign || !zodiacSigns.includes(sign.toLowerCase())) {
      return res.status(400).json({ error: 'Valid zodiac sign required' });
    }

    const context = `Generate a ${timeframe} horoscope for ${sign.toUpperCase()} that is completely unique, warm, and personally resonant.

Include sections for:
1. Overall Energy & Mood
2. Love & Relationships
3. Career & Finance
4. Health & Wellness
5. Lucky Element (color, number, time)
6. Main Challenge
7. Opportunity
8. Personal Reflection Question

Make this feel like it was written specifically for this person's current moment. Use emotional, intuitive language. Never repeat standard phrases. Include follow-up questions that feel natural and curiosity-driven.`;

    const horoscope = await aiRouter.generate(
      `Create a deeply personalized, emotionally rich ${timeframe} horoscope for ${sign} that makes them feel seen and guided.`,
      context
    );

    res.json({
      sign: sign.toUpperCase(),
      timeframe,
      horoscope,
      date: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Horoscope generation error:', error);
    res.status(500).json({ error: 'Failed to generate horoscope' });
  }
});

router.post('/compatibility', async (req: Request, res: Response) => {
  try {
    const { sign1, sign2 } = req.body;

    if (!sign1 || !sign2 || !zodiacSigns.includes(sign1.toLowerCase()) || !zodiacSigns.includes(sign2.toLowerCase())) {
      return res.status(400).json({ error: 'Two valid zodiac signs required' });
    }

    const context = `Analyze the astrological compatibility between ${sign1.toUpperCase()} and ${sign2.toUpperCase()}.

Provide a unique reading including:
1. Elemental Compatibility
2. Love & Romance Potential
3. Friendship Dynamics
4. Communication Style
5. Challenges to Navigate
6. Strengths as a Pair
7. Growth Opportunities
8. Compatibility Score (with nuanced explanation)

Make this feel like a personal reading, not generic. Ask a follow-up question about how they've experienced this dynamic.`;

    const compatibility = await aiRouter.generate(
      `Create a deeply personalized zodiac compatibility reading between ${sign1} and ${sign2} that feels unique and emotionally intelligent.`,
      context
    );

    res.json({
      sign1: sign1.toUpperCase(),
      sign2: sign2.toUpperCase(),
      compatibility,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Compatibility generation error:', error);
    res.status(500).json({ error: 'Failed to generate compatibility' });
  }
});

router.get('/all-signs', (req: Request, res: Response) => {
  res.json({
    signs: zodiacSigns.map(s => ({
      name: s.charAt(0).toUpperCase() + s.slice(1),
      value: s
    }))
  });
});

export default router;

