import 'package:flutter/foundation.dart';

import '../../../core/ai_engine/ai_orchestrator.dart';

/// Zodiac Service - Uses new AI Engine
/// Generates 100% AI-generated content for all 9 sections per sign
class ZodiacService {
  ZodiacService({
    AIOrchestrator? orchestrator,
  }) : _orchestrator = orchestrator ?? AIOrchestrator();

  final AIOrchestrator _orchestrator;

  /// Get zodiac sign details (all 9 sections: traits, strengths, challenges, love, career, emotional, spiritual, monthly, yearly)
  /// Cached for 12 hours
  Future<Map<String, String>> getZodiacDetails({
    required String sign,
    required String language,
    bool forceRefresh = false,
  }) async {
    try {
      return await _orchestrator.generateZodiacDetails(
        sign: sign,
        language: language,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('ZodiacService: Error - $e');
      return {
        'traits': language == 'tr'
            ? 'Özellikler yükleniyor...'
            : 'Loading traits...',
        'strengths': language == 'tr'
            ? 'Güçlü yönler yükleniyor...'
            : 'Loading strengths...',
        'challenges': language == 'tr'
            ? 'Zorluklar yükleniyor...'
            : 'Loading challenges...',
        'love': language == 'tr'
            ? 'Aşk analizi yükleniyor...'
            : 'Loading love analysis...',
        'career': language == 'tr'
            ? 'Kariyer analizi yükleniyor...'
            : 'Loading career analysis...',
        'emotional': language == 'tr'
            ? 'Duygusal manzara yükleniyor...'
            : 'Loading emotional landscape...',
        'spiritual': language == 'tr'
            ? 'Ruhsal yolculuk yükleniyor...'
            : 'Loading spiritual journey...',
        'monthly': language == 'tr'
            ? 'Aylık görünüm yükleniyor...'
            : 'Loading monthly outlook...',
        'yearly': language == 'tr'
            ? 'Yıllık gelişim yükleniyor...'
            : 'Loading yearly evolution...',
      };
    }
  }
}

