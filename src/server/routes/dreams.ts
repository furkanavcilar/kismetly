import { Router, Request, Response } from 'express';
import { aiRouter } from '../services/aiRouter';

const router = Router();

interface DreamRequest {
  description: string;
  mood?: string;
  date?: string;
}

router.post('/interpret', async (req: Request, res: Response) => {
  try {
    const { description, mood, date } = req.body as DreamRequest;

    if (!description) {
      return res.status(400).json({ error: 'Dream description required' });
    }

    const context = `You are interpreting a dream in a spiritually sensitive and psychologically aware manner.
    
Dream Description: ${description}
${mood ? `Mood/Emotion upon waking: ${mood}` : ''}
${date ? `Date of dream: ${date}` : ''}

Provide a rich, multi-layered interpretation that includes:
1. Symbolic meanings and archetypes
2. Psychological insights
3. Emotional undertones
4. Spiritual guidance
5. One or two follow-up questions to deepen understanding

Keep it deeply personal and conversational. Never use templates or generic interpretations.`;

    const interpretation = await aiRouter.generate(
      'Provide a spiritually-guided dream interpretation that feels human and uniquely tailored to this person.',
      context
    );

    res.json({
      interpretation,
      dream: description,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Dream interpretation error:', error);
    res.status(500).json({ error: 'Failed to generate interpretation' });
  }
});

router.post('/symbol-analysis', async (req: Request, res: Response) => {
  try {
    const { symbol, dreamContext } = req.body;

    if (!symbol) {
      return res.status(400).json({ error: 'Symbol required' });
    }

    const context = `Analyze the symbolic meaning of "${symbol}" in the context of dream interpretation.
${dreamContext ? `Dream Context: ${dreamContext}` : ''}

Provide analysis covering:
1. Universal symbolic meanings
2. Personal psychological interpretations
3. Spiritual significance
4. How it might apply to the dreamer's life
5. Follow-up question for deeper exploration`;

    const analysis = await aiRouter.generate(
      'Provide a unique, personalized symbolic analysis that feels like guidance from a spiritual advisor.',
      context
    );

    res.json({
      symbol,
      analysis,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    console.error('Symbol analysis error:', error);
    res.status(500).json({ error: 'Failed to analyze symbol' });
  }
});

export default router;

