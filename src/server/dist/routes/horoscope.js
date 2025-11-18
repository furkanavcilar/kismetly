"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const aiRouter_1 = require("../services/aiRouter");
const language_1 = require("../services/language");
const prompts_1 = require("../services/prompts");
const router = (0, express_1.Router)();
const zodiacSigns = [
    'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
    'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
];
router.post('/generate', async (req, res) => {
    try {
        const { sign, timeframe = 'daily' } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!sign || !zodiacSigns.includes(sign.toLowerCase())) {
            const errorMsg = language === 'tr' ? 'Geçerli bir burç adı gerekli' : 'Valid zodiac sign required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Horoscope generation language =', language);
        const systemPrompt = prompts_1.horoscopeSystemPrompts[language];
        const userPrompt = (0, prompts_1.horoscopeUserPrompt)(language, sign, timeframe);
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const horoscope = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            sign: sign.toUpperCase(),
            timeframe,
            horoscope,
            date: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Horoscope generation error:', error);
        res.status(500).json({ error: 'Failed to generate horoscope' });
    }
});
router.post('/compatibility', async (req, res) => {
    try {
        const { sign1, sign2 } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!sign1 || !sign2 || !zodiacSigns.includes(sign1.toLowerCase()) || !zodiacSigns.includes(sign2.toLowerCase())) {
            const errorMsg = language === 'tr' ? 'İki geçerli burç adı gerekli' : 'Two valid zodiac signs required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Horoscope compatibility language =', language);
        const systemPrompt = prompts_1.horoscopeSystemPrompts[language];
        const userPrompt = language === 'tr'
            ? `${sign1.toUpperCase()} ve ${sign2.toUpperCase()} arasındaki astrolojik uyumluluğu analiz et.

Şunları içeren benzersiz bir okuma yap:
1. Elemental Uyumluluk
2. Aşk ve Romantik Potansiyel
3. Arkadaşlık Dinamikleri
4. İletişim Tarzı
5. Yönlendirilecek Zorluklar
6. Çift Olarak Güçlü Yönler
7. Büyüme Fırsatları
8. Uyumluluk Skoru (nüanslı açıklama ile)

Bu okumanın kişisel olduğunu hissettir, genel değil. Bu dinamikleri nasıl deneyimledikleri hakkında bir takip sorusu sor.`
            : `Analyze the astrological compatibility between ${sign1.toUpperCase()} and ${sign2.toUpperCase()}.

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
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const compatibility = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            sign1: sign1.toUpperCase(),
            sign2: sign2.toUpperCase(),
            compatibility,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Compatibility generation error:', error);
        res.status(500).json({ error: 'Failed to generate compatibility' });
    }
});
router.get('/all-signs', (req, res) => {
    res.json({
        signs: zodiacSigns.map(s => ({
            name: s.charAt(0).toUpperCase() + s.slice(1),
            value: s
        }))
    });
});
exports.default = router;
