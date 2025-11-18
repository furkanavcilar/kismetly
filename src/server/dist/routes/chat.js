"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const aiRouter_1 = require("../services/aiRouter");
const language_1 = require("../services/language");
const prompts_1 = require("../services/prompts");
const router = (0, express_1.Router)();
/* ----------------------------------------------
   TEST ENDPOINT — Check if AI Router works
---------------------------------------------- */
router.get('/test', async (req, res) => {
    try {
        const result = await aiRouter_1.aiRouter.generate("Hello! Test message.");
        res.json({
            ok: true,
            providerCount: aiRouter_1.aiRouter.providers.length,
            message: result
        });
    }
    catch (err) {
        res.status(500).json({ error: 'AI test failed', details: err });
    }
});
/* ----------------------------------------------
   MAIN CHAT — Kismet Spiritual Chat
---------------------------------------------- */
router.post('/ask', async (req, res) => {
    try {
        const { message, conversationHistory = [], context } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!message) {
            const errorMsg = language === 'tr' ? 'Mesaj gerekli' : 'Message required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Chat ask language =', language);
        // Base context
        const systemContext = language === 'tr'
            ? `Sen Kismet'sin, sıcak ve empatik bir ruhsal rehber ve danışmansın.
Yanıtların duygusal olarak zeki, derinlemesine kişisel, şiirsel ve sohbet eder gibi.
Her zaman bir takip sorusu sor.
Asla şablon kullanma.
En az 2–3 paragraf.
Şunlarda uzmanlaşmışsın:
- Rüya yorumlama
- Astroloji
- Tarot
- Aşk rehberliği
- Ruhsal danışmanlık
- Enerjik hizalama`
            : `You are Kismet, a warm, empathetic spiritual guide and advisor.
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
- Energetic alignment`;
        let fullContext = systemContext;
        // Add custom user context
        if (context) {
            const contextLabel = language === 'tr' ? 'Kullanıcı Bağlamı' : 'User Context';
            fullContext += `\n${contextLabel}: ${context}`;
        }
        // Add conversation history
        if (conversationHistory.length > 0) {
            const historyLabel = language === 'tr' ? 'Son konuşma' : 'Recent conversation';
            fullContext += `\n${historyLabel}:\n`;
            conversationHistory.slice(-6).forEach(msg => {
                fullContext += `${msg.role === 'user' ? (language === 'tr' ? 'Kullanıcı' : 'User') : 'Kismet'}: ${msg.content}\n`;
            });
        }
        const userPrompt = language === 'tr'
            ? `Kullanıcıya ruhsal sıcaklık, içgörü ve merakla yanıt ver.\n\n${language === 'tr' ? 'Kullanıcı diyor' : 'User says'}: "${message}"`
            : `Respond to the user with spiritual warmth, insight, and curiosity.\n\nUser says: "${message}"`;
        const response = await aiRouter_1.aiRouter.generate(userPrompt, fullContext, language);
        res.json({
            message: response,
            timestamp: Date.now(),
            conversationUpdated: true,
        });
    }
    catch (error) {
        console.error("Chat error:", error);
        res.status(500).json({ error: 'Failed to generate response' });
    }
});
/* ----------------------------------------------
   DAILY GUIDANCE
---------------------------------------------- */
router.post('/daily-guidance', async (req, res) => {
    try {
        const { sign, name, focus } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        console.log('[AI] Daily guidance language =', language);
        const systemPrompt = prompts_1.chatSystemPrompts[language];
        const userPrompt = (0, prompts_1.dailyGuidanceUserPrompt)(language, sign, name, focus);
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const guidance = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({ guidance, date: new Date().toISOString() });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to generate daily guidance' });
    }
});
/* ----------------------------------------------
   SPIRITUAL ADVICE
---------------------------------------------- */
router.post('/spiritual-advice', async (req, res) => {
    try {
        const { situation, question, context: userContext } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!situation && !question) {
            const errorMsg = language === 'tr' ? 'Durum veya soru gerekli' : 'Situation or question required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Spiritual advice language =', language);
        const systemPrompt = prompts_1.chatSystemPrompts[language];
        const userPrompt = (0, prompts_1.spiritualAdviceUserPrompt)(language, situation, question, userContext);
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const advice = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({ advice, timestamp: new Date().toISOString() });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to generate advice' });
    }
});
exports.default = router;
