"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const aiRouter_1 = require("../services/aiRouter");
const language_1 = require("../services/language");
const prompts_1 = require("../services/prompts");
const router = (0, express_1.Router)();
const tarotCards = [
    // Major Arcana
    { id: 0, name: 'The Fool', arcana: 'major' },
    { id: 1, name: 'The Magician', arcana: 'major' },
    { id: 2, name: 'The High Priestess', arcana: 'major' },
    { id: 3, name: 'The Empress', arcana: 'major' },
    { id: 4, name: 'The Emperor', arcana: 'major' },
    { id: 5, name: 'The Hierophant', arcana: 'major' },
    { id: 6, name: 'The Lovers', arcana: 'major' },
    { id: 7, name: 'The Chariot', arcana: 'major' },
    { id: 8, name: 'Strength', arcana: 'major' },
    { id: 9, name: 'The Hermit', arcana: 'major' },
    { id: 10, name: 'Wheel of Fortune', arcana: 'major' },
    { id: 11, name: 'Justice', arcana: 'major' },
    { id: 12, name: 'The Hanged Man', arcana: 'major' },
    { id: 13, name: 'Death', arcana: 'major' },
    { id: 14, name: 'Temperance', arcana: 'major' },
    { id: 15, name: 'The Devil', arcana: 'major' },
    { id: 16, name: 'The Tower', arcana: 'major' },
    { id: 17, name: 'The Star', arcana: 'major' },
    { id: 18, name: 'The Moon', arcana: 'major' },
    { id: 19, name: 'The Sun', arcana: 'major' },
    { id: 20, name: 'Judgement', arcana: 'major' },
    { id: 21, name: 'The World', arcana: 'major' },
];
function drawCards(count) {
    const drawn = [];
    const available = [...tarotCards];
    for (let i = 0; i < count && available.length > 0; i++) {
        const index = Math.floor(Math.random() * available.length);
        drawn.push(available[index]);
        available.splice(index, 1);
    }
    return drawn;
}
router.post('/draw', async (req, res) => {
    try {
        const { question, spreadType = 'single' } = req.body;
        const language = (0, language_1.getLanguageFromRequest)(req);
        if (!question) {
            const errorMsg = language === 'tr' ? 'Tarot okuması için soru gerekli' : 'Question required for tarot reading';
            return res.status(400).json({ error: errorMsg });
        }
        console.log('[AI] Tarot reading language =', language);
        let cardCount = 1;
        let spreadName = language === 'tr' ? 'Tek Kart' : 'Single Card';
        if (spreadType === 'threesome') {
            cardCount = 3;
            spreadName = language === 'tr' ? 'Geçmiş-Şimdi-Gelecek' : 'Past-Present-Future';
        }
        else if (spreadType === 'celtic_cross') {
            cardCount = 10;
            spreadName = language === 'tr' ? 'Kelt Haçı' : 'Celtic Cross';
        }
        else if (spreadType === 'horseshoe') {
            cardCount = 7;
            spreadName = language === 'tr' ? 'At Nalı' : 'Horseshoe';
        }
        const drawnCards = drawCards(cardCount);
        const cardNames = drawnCards.map(c => c.name).join(', ');
        const reversed = drawnCards.map(() => Math.random() > 0.5).map((r, i) => r ? `${drawnCards[i].name} (Reversed)` : drawnCards[i].name);
        const systemPrompt = prompts_1.tarotSystemPrompts[language];
        const userPrompt = (0, prompts_1.tarotUserPrompt)(language, question, spreadName, cardNames, reversed);
        const fullPrompt = `${systemPrompt}\n\n${userPrompt}`;
        const reading = await aiRouter_1.aiRouter.generate(fullPrompt, undefined, language);
        res.json({
            question,
            spreadType,
            spreadName,
            cards: drawnCards,
            reversedCards: reversed,
            reading,
            timestamp: new Date().toISOString()
        });
    }
    catch (error) {
        console.error('Tarot reading error:', error);
        res.status(500).json({ error: 'Failed to generate tarot reading' });
    }
});
router.get('/cards', (req, res) => {
    res.json({ cards: tarotCards });
});
exports.default = router;
