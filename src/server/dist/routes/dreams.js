"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const aiRouter_1 = require("../services/aiRouter");
const language_1 = require("../services/language");
const prompts_1 = require("../services/prompts");
const router = (0, express_1.Router)();
router.post('/interpret', async (req, res) => {
    try {
        const { description, mood, date } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!description) {
            const errorMsg = language === 'tr' ? 'Rüya açıklaması gerekli' : 'Dream description required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Dream interpretation language =', language);
        const systemPrompt = prompts_1.dreamSystemPrompts[language];
        const userPrompt = (0, prompts_1.dreamUserPrompt)(language, description, mood, date);
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const interpretation = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            interpretation,
            dream: description,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Dream interpretation error:', error);
        res.status(500).json({ error: 'Failed to generate interpretation' });
    }
});
router.post('/symbol-analysis', async (req, res) => {
    try {
        const { symbol, dreamContext } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!symbol) {
            const errorMsg = language === 'tr' ? 'Sembol gerekli' : 'Symbol required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Symbol analysis language =', language);
        const systemPrompt = prompts_1.dreamSystemPrompts[language];
        const userPrompt = language === 'tr'
            ? `"${symbol}" sembolünün rüya yorumlama bağlamındaki sembolik anlamını analiz et.
${dreamContext ? `Rüya Bağlamı: ${dreamContext}` : ''}

Şunları kapsayan bir analiz yap:
1. Evrensel sembolik anlamlar
2. Kişisel psikolojik yorumlar
3. Ruhsal önem
4. Rüya görenin hayatına nasıl uygulanabileceği
5. Daha derin keşif için takip sorusu`
            : `Analyze the symbolic meaning of "${symbol}" in the context of dream interpretation.
${dreamContext ? `Dream Context: ${dreamContext}` : ''}

Provide analysis covering:
1. Universal symbolic meanings
2. Personal psychological interpretations
3. Spiritual significance
4. How it might apply to the dreamer's life
5. Follow-up question for deeper exploration`;
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const analysis = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            symbol,
            analysis,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Symbol analysis error:', error);
        res.status(500).json({ error: 'Failed to analyze symbol' });
    }
});
exports.default = router;
