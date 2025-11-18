"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiRouter = exports.AIRouter = void 0;
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const axios_1 = __importDefault(require("axios"));
const prompts_1 = require("./prompts");
// OpenAI Provider
class OpenAIProvider {
    constructor(apiKey) {
        this.name = 'OpenAI';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const response = await axios_1.default.post('https://api.openai.com/v1/chat/completions', {
                model: 'gpt-4o-mini',
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt
                    },
                    {
                        role: 'user',
                        content: fullPrompt
                    }
                ],
                temperature: 0.8,
                max_tokens: 1500
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            return response.data.choices[0].message.content;
        }
        catch (error) {
            console.error(`OpenAI error:`, error.message);
            if (error.response) {
                console.error(`OpenAI response status:`, error.response.status);
                console.error(`OpenAI response data:`, error.response.data);
            }
            throw error;
        }
    }
}
// Google Gemini Provider
class GeminiProvider {
    constructor(apiKey) {
        this.name = 'Gemini';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const response = await axios_1.default.post(`https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${this.apiKey}`, {
                contents: [
                    {
                        parts: [
                            {
                                text: `${systemPrompt}\n\n${fullPrompt}`
                            }
                        ]
                    }
                ],
                generationConfig: {
                    temperature: 0.8,
                    maxOutputTokens: 1500
                }
            }, {
                timeout: 10000,
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            if (!response.data.candidates || !response.data.candidates[0] || !response.data.candidates[0].content) {
                throw new Error('Invalid Gemini response structure');
            }
            return response.data.candidates[0].content.parts[0].text;
        }
        catch (error) {
            console.error(`Gemini error:`, error.message);
            if (error.response) {
                console.error(`Gemini response status:`, error.response.status);
                console.error(`Gemini response data:`, error.response.data);
            }
            throw error;
        }
    }
}
// Anthropic Claude Provider
class ClaudeProvider {
    constructor(apiKey) {
        this.name = 'Claude';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const response = await axios_1.default.post('https://api.anthropic.com/v1/messages', {
                model: 'claude-3-5-sonnet-20241022',
                max_tokens: 1500,
                messages: [
                    {
                        role: 'user',
                        content: `${systemPrompt}\n\n${fullPrompt}`
                    }
                ],
                system: systemPrompt
            }, {
                headers: {
                    'x-api-key': this.apiKey,
                    'anthropic-version': '2023-06-01',
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            return response.data.content[0].text;
        }
        catch (error) {
            console.error(`Claude error:`, error.message);
            throw error;
        }
    }
}
// DeepSeek Provider
class DeepSeekProvider {
    constructor(apiKey) {
        this.name = 'DeepSeek';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const response = await axios_1.default.post('https://api.deepseek.com/v1/chat/completions', {
                model: 'deepseek-chat',
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt
                    },
                    {
                        role: 'user',
                        content: fullPrompt
                    }
                ],
                temperature: 0.8,
                max_tokens: 1500
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            return response.data.choices[0].message.content;
        }
        catch (error) {
            console.error(`DeepSeek error:`, error.message);
            throw error;
        }
    }
}
// Grok Provider (xAI)
class GrokProvider {
    constructor(apiKey) {
        this.name = 'Grok';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const response = await axios_1.default.post('https://api.x.ai/v1/chat/completions', {
                model: 'grok-beta',
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt
                    },
                    {
                        role: 'user',
                        content: fullPrompt
                    }
                ],
                temperature: 0.8,
                max_tokens: 1500
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            return response.data.choices[0].message.content;
        }
        catch (error) {
            console.error(`Grok error:`, error.message);
            throw error;
        }
    }
}
// Microsoft Copilot Provider
class CopilotProvider {
    constructor(apiKey) {
        this.name = 'Copilot';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            // Copilot uses Azure OpenAI endpoint format
            const endpoint = process.env.COPILOT_ENDPOINT || 'https://api.copilot.microsoft.com/v1/chat/completions';
            const response = await axios_1.default.post(endpoint, {
                model: 'gpt-4',
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt
                    },
                    {
                        role: 'user',
                        content: fullPrompt
                    }
                ],
                temperature: 0.8,
                max_tokens: 1500
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            return response.data.choices[0].message.content;
        }
        catch (error) {
            console.error(`Copilot error:`, error.message);
            throw error;
        }
    }
}
// Perplexity Provider (Fallback)
class PerplexityProvider {
    constructor(apiKey) {
        this.name = 'Perplexity';
        this.apiKey = apiKey;
    }
    async generateText(prompt, context, language = 'en') {
        try {
            const fullPrompt = context ? `${context}\n\n${prompt}` : prompt;
            const systemPrompt = prompts_1.baseSystemPrompts[language];
            const response = await axios_1.default.post('https://api.perplexity.ai/chat/completions', {
                model: 'sonar-small-chat',
                messages: [
                    {
                        role: 'user',
                        content: `${systemPrompt}\n\n${fullPrompt}`
                    }
                ],
                temperature: 0.8
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 10000
            });
            if (!response.data.choices || !response.data.choices[0] || !response.data.choices[0].message) {
                throw new Error('Invalid Perplexity response structure');
            }
            return response.data.choices[0].message.content;
        }
        catch (error) {
            console.error(`Perplexity error:`, error.message);
            if (error.response) {
                console.error(`Perplexity response status:`, error.response.status);
                console.error(`Perplexity response data:`, error.response.data);
            }
            throw error;
        }
    }
}
// Fallback local response generator
function generateLocalFallback(prompt, language = 'en') {
    if (language === 'tr') {
        const fallbacks = [
            "Soruşunda derin bir şeyler seziyorum. Bu anın etrafındaki ruhsal enerji, bir yol ayrımında olduğunu gösteriyor—seni farklı yollara çeken şeyleri keşfetmek ister misin?",
            "Bu kozmik dokunun derinliklerine dokunuyor. Burada anlam katmanları algılıyorum. Son zamanlarda en güçlü duyguların neler oldu?",
            "Evren birçok kanaldan fısıldıyor. Sorgun dönüşüm ve netlik temalarıyla rezonans yapıyor. Sezgilerin son zamanlarda seni nasıl yönlendiriyor?",
            "Kelimelerinin altında ruhsal bir akım hissediyorum. Burada açılmak için bekleyen bir bilgelik var. Daha iyi keşfetmeyi veya anlamayı ne umuyorsun?",
            "Bu gerçek bir arayışın ağırlığını taşıyor. Devredeki güçler seni anlamlı bir şeye yönlendiriyor gibi görünüyor. Bu soruyu tetikleyen şeyi paylaşabilir misin?"
        ];
        const baseResponse = fallbacks[Math.floor(Math.random() * fallbacks.length)];
        if (prompt.includes('dream') || prompt.includes('rüya')) {
            return `Rüyan sembolik ağırlık ve duygusal rezonans taşıyor. ${baseResponse} Rüyalar genellikle en derin korkularımızı ve arzularımızı yansıtır—sana en canlı görünen şey nedir?`;
        }
        if (prompt.includes('horoscope') || prompt.includes('zodiac') || prompt.includes('burç')) {
            return `Kozmik hizalama şu anda burcunla özellikle net konuşuyor. ${baseResponse} Son enerjiler günlük deneyimini nasıl etkiliyor?`;
        }
        if (prompt.includes('compatible') || prompt.includes('love') || prompt.includes('aşk') || prompt.includes('uyumluluk')) {
            return `Sorduğun bağlantı ilginç astrolojik boyutlar taşıyor. ${baseResponse} Bu kişide seni en derinden çeken nitelikler neler?`;
        }
        if (prompt.includes('tarot') || prompt.includes('card') || prompt.includes('kart')) {
            return `Kartlar durumuna özgü anlam katmanları ortaya koyuyor. ${baseResponse} Şu anda en çok hangi rehberliği umuyorsun?`;
        }
        return baseResponse;
    }
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
class AIRouter {
    constructor() {
        // Initialize providers in order of preference
        // Priority: OpenAI → Gemini → Perplexity
        // DeepSeek, Grok, Copilot, and Claude are disabled by default (require paid accounts)
        this.providers = [];
        this.providerIndex = 0;
        // Only include providers with non-empty API keys
        if (process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY.trim() !== '') {
            this.providers.push(new OpenAIProvider(process.env.OPENAI_API_KEY));
        }
        if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY.trim() !== '') {
            this.providers.push(new GeminiProvider(process.env.GEMINI_API_KEY));
        }
        if (process.env.PERPLEXITY_API_KEY && process.env.PERPLEXITY_API_KEY.trim() !== '') {
            this.providers.push(new PerplexityProvider(process.env.PERPLEXITY_API_KEY));
        }
        // Optional paid providers (only if explicitly configured)
        if (process.env.ANTHROPIC_API_KEY && process.env.ANTHROPIC_API_KEY.trim() !== '') {
            this.providers.push(new ClaudeProvider(process.env.ANTHROPIC_API_KEY));
        }
        if (process.env.DEEPSEEK_API_KEY && process.env.DEEPSEEK_API_KEY.trim() !== '') {
            this.providers.push(new DeepSeekProvider(process.env.DEEPSEEK_API_KEY));
        }
        if (process.env.GROK_API_KEY && process.env.GROK_API_KEY.trim() !== '') {
            this.providers.push(new GrokProvider(process.env.GROK_API_KEY));
        }
        if (process.env.COPILOT_API_KEY && process.env.COPILOT_API_KEY.trim() !== '') {
            this.providers.push(new CopilotProvider(process.env.COPILOT_API_KEY));
        }
        console.log(`✨ Kismetly AI Router initialized with ${this.providers.length} provider(s)`);
        if (this.providers.length > 0) {
            console.log(`   Active providers: ${this.providers.map(p => p.name).join(', ')}`);
        }
        else {
            console.warn('⚠️  No AI providers configured. Only local fallback will be used.');
        }
    }
    async generate(prompt, context, language = 'en') {
        if (this.providers.length === 0) {
            console.warn('⚠️ No AI providers configured, using local fallback');
            return generateLocalFallback(prompt, language);
        }
        // Try each provider in order: OpenAI → Gemini → Perplexity → (others if configured)
        for (let i = 0; i < this.providers.length; i++) {
            const provider = this.providers[i];
            try {
                console.log(`🔄 Attempting with ${provider.name}...`);
                const result = await provider.generateText(prompt, context, language);
                console.log(`✅ Success with ${provider.name}`);
                // Rotate provider index for next request (round-robin)
                this.providerIndex = (this.providerIndex + 1) % this.providers.length;
                return result;
            }
            catch (error) {
                console.error(`❌ ${provider.name} failed:`, error.message);
                if (error.response) {
                    console.error(`   Status: ${error.response.status}, Data:`, error.response.data);
                }
                // Continue to next provider
                continue;
            }
        }
        // All providers failed, use local fallback
        console.warn(`⚠️ All ${this.providers.length} AI provider(s) failed. Using intelligent local fallback.`);
        return generateLocalFallback(prompt, language);
    }
    async generateWithMultiple(prompt, context, language = 'en', count = 1) {
        const results = [];
        for (let i = 0; i < count && i < this.providers.length; i++) {
            try {
                const result = await this.generate(prompt, context, language);
                results.push(result);
            }
            catch (error) {
                console.error(`Failed to generate result ${i + 1}`);
            }
        }
        return results.length > 0 ? results : [generateLocalFallback(prompt, language)];
    }
}
exports.AIRouter = AIRouter;
exports.aiRouter = new AIRouter();
