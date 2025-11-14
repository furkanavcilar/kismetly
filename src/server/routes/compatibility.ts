import { Router, Request, Response } from 'express';
import { aiRouter } from '../services/aiRouter';

const router = Router();

interface CompatibilityRequest {
  name1: string;
  name2: string;
  birthDate1?: string;
  birthDate2?: string;
  sign1?: string;
  sign2?: string;
  birthTime1?: string;
  birthTime2?: string;
}

router.post('/analyze', async (req: Request, res: Response) => {
  try {
    const {
      name1,
      name2,
      birthDate1,
      birthDate2,
      sign1,
      sign2,
      birthTime1,
      birthTime2
    } = req.body as CompatibilityRequest;

    if (!name1 || !name2) {
      return res.status(400).json({ error: 'Two names required' });
    }

    const context = `Analyze the love compatibility between ${name1} and ${name2}.
${birthDate1 ? `${name1}'s birthdate: ${birthDate1}` : ''}
${birthDate2 ? `${name2}'s birthdate: ${birthDate2}` : ''}
${sign1 ? `${name1}'s zodiac sign: ${sign1}` : ''}
${sign2 ? `${name2}'s zodiac sign: ${sign2}` : ''}
${birthTime1 ? `${name1}'s birth time: ${birthTime1}` : ''}
${birthTime2 ? `${name2}'s birth time: ${birthTime2}` : ''}

Create a deeply personal, emotionally intelligent compatibility reading that includes:

1. **Relationship Energy**: Describe the overall energetic dynamic between these two
2. **Love Compatibility**: Physical, emotional, and spiritual attraction potential
3. **Communication Dynamics**: How they likely understand each other
4. **Emotional Connection**: Depth and authenticity potential
5. **Shared Values**: What might bind them together
6. **Potential Challenges**: Honest obstacles they may face
7. **Growth Together**: How they could help each other evolve
8. **Intimacy Potential**: Physical and emotional closeness
9. **Long-term Viability**: Sustainability of the relationship
10. **Compatibility Insight**: A personalized, thought-provoking observation unique to their connection

Make this reading feel like it was written specifically for these two individuals. Use vivid, poetic language. Never use templates. End with a reflective question about their feelings for each other.`;

    const analysis = await aiRouter.generate(
      `Create a uniquely personalized love compatibility reading between ${name1} and ${name2} that feels emotionally intelligent and spiritually guided.`,
      context
    );

    res.json({
      person1: name1,
      person2: name2,
      analysis,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Compatibility analysis error:', error);
    res.status(500).json({ error: 'Failed to generate compatibility analysis' });
  }
});

router.post('/soulmate-insight', async (req: Request, res: Response) => {
  try {
    const { name, birthDate, sign, question } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Name required' });
    }

    const context = `Provide soulmate and romantic guidance for ${name}.
${birthDate ? `Birthdate: ${birthDate}` : ''}
${sign ? `Zodiac sign: ${sign}` : ''}
${question ? `Their question/concern: ${question}` : ''}

Create a personalized spiritual reading about their romantic path that includes:
1. Their romantic energy and what they naturally attract
2. The kind of partner their soul seeks
3. Current relationship patterns and karma
4. Timing and readiness for love
5. Blocks or fears around intimacy
6. Spiritual lessons in their romantic journey
7. Signs to look for in their true match
8. Next steps they should consider
9. A powerful affirmation for their love journey

Make this feel deeply personal and spiritually guided. Use intuitive, warm language. Include one reflective question.`;

    const insight = await aiRouter.generate(
      `Provide a deeply personal, spiritually-guided soulmate and romantic insight for ${name}.`,
      context
    );

    res.json({
      person: name,
      insight,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Soulmate insight error:', error);
    res.status(500).json({ error: 'Failed to generate soulmate insight' });
  }
});

export default router;

