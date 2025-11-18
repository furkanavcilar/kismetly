"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const aiRouter_1 = require("../services/aiRouter");
const language_1 = require("../services/language");
const prompts_1 = require("../services/prompts");
const router = (0, express_1.Router)();
router.post('/analyze', async (req, res) => {
    try {
        const { name1, name2, birthDate1, birthDate2, sign1, sign2, birthTime1, birthTime2 } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        // Support both name-based and sign-based compatibility
        if (!sign1 || !sign2) {
            if (!name1 || !name2) {
                const errorMsg = language === 'tr' ? 'İki isim veya iki burç adı gerekli' : 'Two names or two zodiac signs required';
                return res.status(400).json({ error: errorMsg });
            }
        }
        console.log('[AI] Compatibility analysis language =', language);
        // Use sign-based analysis if signs provided, otherwise use names
        const person1 = sign1 ? `${sign1.toUpperCase()} sign` : name1;
        const person2 = sign2 ? `${sign2.toUpperCase()} sign` : name2;
        const systemPrompt = prompts_1.compatibilitySystemPrompts[language];
        const userPrompt = (0, prompts_1.compatibilityUserPrompt)(language, person1, person2, {
            name1,
            name2,
            sign1,
            sign2,
            birthDate1,
            birthDate2
        });
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const analysis = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            person1: name1 || sign1?.toUpperCase(),
            person2: name2 || sign2?.toUpperCase(),
            sign1: sign1?.toUpperCase(),
            sign2: sign2?.toUpperCase(),
            analysis,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Compatibility analysis error:', error);
        res.status(500).json({ error: 'Failed to generate compatibility analysis' });
    }
});
router.post('/soulmate-insight', async (req, res) => {
    try {
        const { name, birthDate, sign, question } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!name) {
            const errorMsg = language === 'tr' ? 'İsim gerekli' : 'Name required';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Soulmate insight language =', language);
        const systemPrompt = prompts_1.compatibilitySystemPrompts[language];
        const userPrompt = language === 'tr'
            ? `${name} için ruh eşi ve romantik rehberlik sağla.
${birthDate ? `Doğum tarihi: ${birthDate}` : ''}
${sign ? `Burç: ${sign}` : ''}
${question ? `Sorusu/endişesi: ${question}` : ''}

Romantik yolları hakkında kişiselleştirilmiş bir ruhsal okuma oluştur:
1. Romantik enerjileri ve doğal olarak çektikleri
2. Ruhlarının aradığı partner türü
3. Mevcut ilişki kalıpları ve karma
4. Aşk için zamanlama ve hazır olma
5. Yakınlık etrafındaki engeller veya korkular
6. Romantik yolculuklarındaki ruhsal dersler
7. Gerçek eşlerinde aramaları gereken işaretler
8. Düşünmeleri gereken sonraki adımlar
9. Aşk yolculukları için güçlü bir onaylama

Bu okumanın derinlemesine kişisel ve ruhsal olarak yönlendirilmiş olduğunu hissettir. Sezgisel, sıcak dil kullan. Bir yansıtıcı soru ekle.`
            : `Provide soulmate and romantic guidance for ${name}.
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
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const insight = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            person: name,
            insight,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Soulmate insight error:', error);
        res.status(500).json({ error: 'Failed to generate soulmate insight' });
    }
});
exports.default = router;
