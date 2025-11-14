import axios from 'axios';

interface AIProvider {
  name: string;
  generateText(prompt: string, context?: string): Promise<string>;
}

// OpenAI Provider
class OpenAIProvider implements AIProvider {
  name = 'OpenAI';
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  async generateText(prompt: string, context?: string): Promise<string> {
    try {
      const response = await axios.post(
        'https://api.openai.com/v1/chat/completions',
        {
          model: 'gpt-4o-mini',
          messages: [
            {
              role: 'system',
              content: 'You are a warm, empathetic spiritual guide. Your responses are deeply personal, emotionally intelligent, conversational, and unique. Always ask follow-up questions. Never use templates. Minimum 3 paragraphs for insights.'
            },
            {
              role: 'user',
              content: context ? `${context}\n\n${prompt}` : prompt
            }
          ],
          temperature: 0.8,
          max_tokens: 1500,
          timeout: 10000
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          },
          timeout: 10000
        }
      );

      return response.data.choices[0].message.content;
    } catch (error: any) {
      console.error(`OpenAI error:`, error.message);
      throw error;
    }
  }
}

// Google Gemini Provider
class GeminiProvider implements AIProvider {
  name = 'Gemini';
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  async generateText(prompt: string, context?: string): Promise<string> {
    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${this.apiKey}`,
        {
          contents: [
            {
              parts: [
                {
                  text: `You are a warm, empathetic spiritual guide. Your responses are deeply personal, emotionally intelligent, conversational, and unique. Always ask follow-up questions. Never use templates. Minimum 3 paragraphs for insights.\n\n${context ? context + '\n\n' : ''}${prompt}`
                }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.8,
            maxOutputTokens: 1500
          }
        },
        { timeout: 10000 }
      );

      return response.data.candidates[0].content.parts[0].text;
    } catch (error: any) {
      console.error(`Gemini error:`, error.message);
      throw error;
    }
  }
}

// Anthropic Claude Provider
class ClaudeProvider implements AIProvider {
  name = 'Claude';
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  async generateText(prompt: string, context?: string): Promise<string> {
    try {
      const response = await axios.post(
        'https://api.anthropic.com/v1/messages',
        {
          model: 'claude-3-5-sonnet-20241022',
          max_tokens: 1500,
          messages: [
            {
              role: 'user',
              content: `You are a warm, empathetic spiritual guide. Your responses are deeply personal, emotionally intelligent, conversational, and unique. Always ask follow-up questions. Never use templates. Minimum 3 paragraphs for insights.\n\n${context ? context + '\n\n' : ''}${prompt}`
            }
          ],
          system: 'You are a warm, empathetic spiritual guide who provides unique, emotionally intelligent guidance.'
        },
        {
          headers: {
            'x-api-key': this.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json'
          },
          timeout: 10000
        }
      );

      return response.data.content[0].text;
    } catch (error: any) {
      console.error(`Claude error:`, error.message);
      throw error;
    }
  }
}

// Perplexity Provider (Fallback)
class PerplexityProvider implements AIProvider {
  name = 'Perplexity';
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  async generateText(prompt: string, context?: string): Promise<string> {
    try {
      const response = await axios.post(
        'https://api.perplexity.ai/chat/completions',
        {
          model: 'llama-2-7b-chat',
          messages: [
            {
              role: 'system',
              content: 'You are a warm, empathetic spiritual guide. Your responses are deeply personal, emotionally intelligent, conversational, and unique. Always ask follow-up questions. Never use templates. Minimum 3 paragraphs for insights.'
            },
            {
              role: 'user',
              content: context ? `${context}\n\n${prompt}` : prompt
            }
          ],
          temperature: 0.8,
          max_tokens: 1500
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          },
          timeout: 10000
        }
      );

      return response.data.choices[0].message.content;
    } catch (error: any) {
      console.error(`Perplexity error:`, error.message);
      throw error;
    }
  }
}

// Fallback local response generator
function generateLocalFallback(prompt: string): string {
  const fallbacks = [
    "I sense something profound in your question. The spiritual energy around this moment suggests you're at a crossroads—would you like to explore what's drawing you toward different paths?",
    "This touches something deep within the cosmic fabric. I'm perceiving layers of meaning here. What emotions have been strongest for you recently?",
    "The universe whispers through many channels. Your inquiry resonates with themes of transformation and clarity. How has your intuition been guiding you lately?",
    "I feel a spiritual current beneath your words. There's wisdom here waiting to unfold. What do you hope to discover or understand better?",
    "This carries the weight of genuine seeking. The forces at play seem to be guiding you toward something meaningful. Can you share what sparked this question?"
  ];

  const baseResponse = fallbacks[Math.floor(Math.random() * fallbacks.length)];
  
  if (prompt.includes('dream')) {
    return `Your dream carries symbolic weight and emotional resonance. ${baseResponse} Dreams often mirror our deepest fears and desires—what stands out most vividly to you?`;
  }
  
  if (prompt.includes('horoscope') || prompt.includes('zodiac')) {
    return `The cosmic alignment speaks to your sign with particular clarity right now. ${baseResponse} How have recent energies been affecting your daily experience?`;
  }
  
  if (prompt.includes('compatible') || prompt.includes('love')) {
    return `The connection you're asking about carries interesting astrological dimensions. ${baseResponse} What qualities in this person draw you most deeply?`;
  }
  
  if (prompt.includes('tarot') || prompt.includes('card')) {
    return `The cards reveal layers of meaning specific to your situation. ${baseResponse} What guidance are you most hoping to find right now?`;
  }

  return baseResponse;
}

export class AIRouter {
  private providers: AIProvider[] = [];
  private providerIndex = 0;

  constructor() {
    // Initialize providers in order of preference
    if (process.env.OPENAI_API_KEY) {
      this.providers.push(new OpenAIProvider(process.env.OPENAI_API_KEY));
    }
    if (process.env.GOOGLE_GEMINI_API_KEY) {
      this.providers.push(new GeminiProvider(process.env.GOOGLE_GEMINI_API_KEY));
    }
    if (process.env.ANTHROPIC_API_KEY) {
      this.providers.push(new ClaudeProvider(process.env.ANTHROPIC_API_KEY));
    }
    if (process.env.PERPLEXITY_API_KEY) {
      this.providers.push(new PerplexityProvider(process.env.PERPLEXITY_API_KEY));
    }

    console.log(`✨ Kismetly AI Router initialized with ${this.providers.length} provider(s)`);
  }

  async generate(prompt: string, context?: string): Promise<string> {
    if (this.providers.length === 0) {
      console.warn('⚠️ No AI providers configured, using local fallback');
      return generateLocalFallback(prompt);
    }

    let lastError: Error | null = null;
    const maxAttempts = this.providers.length;
    let attempts = 0;

    while (attempts < maxAttempts) {
      const provider = this.providers[this.providerIndex % this.providers.length];
      
      try {
        console.log(`🔄 Attempting with ${provider.name}...`);
        const result = await provider.generateText(prompt, context);
        console.log(`✅ Success with ${provider.name}`);
        
        // Rotate to next provider for next request
        this.providerIndex = (this.providerIndex + 1) % this.providers.length;
        
        return result;
      } catch (error: any) {
        lastError = error;
        console.error(`❌ ${provider.name} failed:`, error.message);
        
        // Move to next provider
        this.providerIndex = (this.providerIndex + 1) % this.providers.length;
        attempts++;
      }
    }

    // All providers failed, use local fallback
    console.warn(`⚠️ All AI providers failed. Using intelligent local fallback.`);
    return generateLocalFallback(prompt);
  }

  async generateWithMultiple(prompt: string, context?: string, count: number = 1): Promise<string[]> {
    const results: string[] = [];
    
    for (let i = 0; i < count && i < this.providers.length; i++) {
      try {
        const result = await this.generate(prompt, context);
        results.push(result);
      } catch (error) {
        console.error(`Failed to generate result ${i + 1}`);
      }
    }

    return results.length > 0 ? results : [generateLocalFallback(prompt)];
  }
}

export const aiRouter = new AIRouter();

