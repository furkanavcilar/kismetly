"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeLanguage = normalizeLanguage;
exports.getLanguageFromRequest = getLanguageFromRequest;
function normalizeLanguage(raw) {
    if (!raw)
        return 'en';
    const v = raw.toString().toLowerCase().trim();
    if (v.startsWith('tr'))
        return 'tr';
    if (v.startsWith('en'))
        return 'en';
    return 'en';
}
// Try to detect language from request:
// 1) body.lang
// 2) query.lang
// 3) header "x-lang"
function getLanguageFromRequest(req) {
    const bodyLang = (req.body && req.body.lang) || undefined;
    const queryLang = (req.query && req.query.lang) || undefined;
    const headerLang = (req.headers && (req.headers['x-lang'] || req.headers['x-language'])) || undefined;
    return normalizeLanguage(bodyLang || queryLang || headerLang);
}
