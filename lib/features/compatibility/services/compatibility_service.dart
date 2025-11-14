import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../services/monetization/monetization_service.dart';

/// Service for zodiac compatibility analysis
/// 
/// Uses featureKey: "zodiac_ai_query" with compatibility context
/// Generates detailed analysis for sign pairs
/// Limited by usage.
class CompatibilityService {
  CompatibilityService({
    AiOrchestrator? orchestrator,
    UsageLimiter? usageLimiter,
    SharedPreferences? prefs,
    MonetizationService? monetizationService,
  })  : _orchestrator = orchestrator ?? AiServiceLocator.instance,
        _usageLimiter = usageLimiter ?? UsageLimiter(monetizationService: monetizationService),
        _prefsFuture = prefs != null
            ? Future.value(prefs)
            : SharedPreferences.getInstance(),
        _monetizationService = monetizationService;

  final AiOrchestrator _orchestrator;
  final UsageLimiter _usageLimiter;
  final Future<SharedPreferences> _prefsFuture;
  final MonetizationService? _monetizationService;

  static const String _featureKey = UsageLimiter.featureZodiacAiQuery;
  static const int _cacheMinutes = 60 * 12; // 12 hours

  /// Compatibility result structure
  class CompatibilityResult {
    final String summary;
    final String love;
    final String family;
    final String career;
    final String strengths;
    final String challenges;
    final String communication;
    final String longTerm;

    CompatibilityResult({
      required this.summary,
      required this.love,
      required this.family,
      required this.career,
      required this.strengths,
      required this.challenges,
      required this.communication,
      required this.longTerm,
    });

    Map<String, String> toMap() {
      return {
        'summary': summary,
        'love': love,
        'family': family,
        'career': career,
        'strengths': strengths,
        'challenges': challenges,
        'communication': communication,
        'longTerm': longTerm,
      };
    }

    static CompatibilityResult fromMap(Map<String, dynamic> map) {
      return CompatibilityResult(
        summary: map['summary'] as String? ?? '',
        love: map['love'] as String? ?? '',
        family: map['family'] as String? ?? '',
        career: map['career'] as String? ?? '',
        strengths: map['strengths'] as String? ?? '',
        challenges: map['challenges'] as String? ?? '',
        communication: map['communication'] as String? ?? '',
        longTerm: map['longTerm'] as String? ?? '',
      );
    }
  }

  /// Get compatibility analysis (cached, limited)
  /// 
  /// Returns null if limit exceeded. Show premium dialog if needed.
  Future<CompatibilityResult?> getCompatibility({
    required String firstSign,
    required String secondSign,
    required String language,
    BuildContext? context,
    bool forceRefresh = false,
  }) async {
    // Check usage limit
    final canUse = await _usageLimiter.canUseFeature(_featureKey);
    if (!canUse) {
      // Show premium dialog if context provided
      if (context != null && context.mounted) {
        await PremiumDialog.show(
          context,
          onUpgrade: () {
            // TODO: Navigate to premium screen
          },
        );
      }
      return null;
    }

    final prefs = await _prefsFuture;
    final cacheKey = 'compatibility_${firstSign}_${secondSign}_$language';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(cached);
          final timestamp = data['timestamp'] as int?;
          final result = data['result'] as Map<String, dynamic>?;
          
          if (timestamp != null && result != null) {
            final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final now = DateTime.now();
            final diff = now.difference(cachedTime);
            
            if (diff.inMinutes < _cacheMinutes) {
              debugPrint('CompatibilityService: Using cached result');
              return CompatibilityResult.fromMap(result.cast<String, dynamic>());
            }
          }
        } catch (e) {
          debugPrint('CompatibilityService: Error parsing cached result: $e');
        }
      }
    }

    // Generate new compatibility
    final result = await _generateCompatibility(
      firstSign: firstSign,
      secondSign: secondSign,
      language: language,
    );

    // Record usage (only if not premium)
    await _usageLimiter.recordUsage(_featureKey);

    // Cache the result
    await prefs.setString(
      cacheKey,
      jsonEncode({
        'result': result.toMap(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    return result;
  }

  /// Generate compatibility using AI orchestrator
  Future<CompatibilityResult> _generateCompatibility({
    required String firstSign,
    required String secondSign,
    required String language,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir astroloji ve ilişki danışmanısın. Burç uyumluluğunu derinlemesine analiz edersin. Kişisel, empatik, şiirsel ve derinden insani bir ton kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Her burç çifti için benzersiz, tekrar etmeyen içerik üret.'''
        : '''You are an experienced astrology and relationship counselor. You analyze sign compatibility in depth. Use a personal, empathetic, poetic, and deeply human tone. Never mention AI, models, or technology. Speak directly to the person using "you". Generate unique, non-repetitive content for each sign pair.''';

    // Generate unique seed for this sign pair combination
    final signHash = (firstSign.hashCode ^ secondSign.hashCode) & 0x7FFFFFFF;
    final seed = (signHash ^ DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;
    
    final userPrompt = language == 'tr'
        ? '''$firstSign ve $secondSign burçlarının uyumluluğunu derinlemesine analiz et. JSON formatında döndür: {"summary":string,"love":string,"family":string,"career":string,"strengths":string,"challenges":string,"communication":string,"longTerm":string}. 

Her bölüm için 3-4 paragraf yaz. Her bölüm detaylı, özgün ve bu özel burç çiftine özgü olmalı. Aynı metni kopyalama - her burç çifti için tamamen farklı içerik üret.

- summary: Genel uyum özeti (3-4 paragraf)
- love: Aşk ve romantik ilişkiler (3-4 paragraf)
- family: Aile ve yakın ilişkiler (3-4 paragraf)
- career: İş ve kariyer uyumu (3-4 paragraf)
- strengths: Bu çiftin güçlü yönleri ve uyumlu alanları (3-4 paragraf)
- challenges: Zorluklar ve dikkat edilmesi gerekenler (3-4 paragraf)
- communication: İletişim önerileri ve nasıl daha iyi anlaşabilecekleri (3-4 paragraf)
- longTerm: Uzun vadeli potansiyel ve ilişki geleceği (3-4 paragraf)

Seed: $seed kullanarak içeriği çeşitlendir. Türkçe yanıt ver.'''
        : '''Analyze the compatibility between $firstSign and $secondSign signs in depth. Return in JSON format: {"summary":string,"love":string,"family":string,"career":string,"strengths":string,"challenges":string,"communication":string,"longTerm":string}.

Write 3-4 paragraphs for each section. Each section must be detailed, unique, and specific to this particular sign pair. Do not copy the same text - generate completely different content for each sign pair.

- summary: Overall compatibility summary (3-4 paragraphs)
- love: Love and romantic relationships (3-4 paragraphs)
- family: Family and close relationships (3-4 paragraphs)
- career: Work and career compatibility (3-4 paragraphs)
- strengths: This pair's strengths and harmonious areas (3-4 paragraphs)
- challenges: Challenges and areas to be mindful of (3-4 paragraphs)
- communication: Communication tips and how they can better understand each other (3-4 paragraphs)
- longTerm: Long-term potential and relationship future (3-4 paragraphs)

Use seed: $seed to diversify content. Respond in English.''';

    try {
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        date: DateTime.now(),
        explicitSeed: seed,
        context: {
          'firstSign': firstSign,
          'secondSign': secondSign,
          'type': 'compatibility',
        },
      );

      return _parseCompatibility(result, language);
    } catch (e) {
      debugPrint('CompatibilityService: Error generating compatibility: $e');
      // Fallback (error message, not static text)
      return _getFallbackResult(language);
    }
  }

  CompatibilityResult _parseCompatibility(String text, String language) {
    // Try to parse JSON first
    try {
      // Extract JSON from text (might have markdown or other formatting)
      final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0);
        if (jsonStr != null) {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          return CompatibilityResult.fromMap(json.cast<String, dynamic>());
        }
      }
    } catch (e) {
      debugPrint('CompatibilityService: Error parsing JSON: $e');
    }

    // If JSON parsing fails, try to parse sections from text
    return _parseCompatibilityFromText(text, language);
  }

  CompatibilityResult _parseCompatibilityFromText(String text, String language) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final sections = <String, StringBuffer>{
      'summary': StringBuffer(),
      'love': StringBuffer(),
      'family': StringBuffer(),
      'career': StringBuffer(),
      'strengths': StringBuffer(),
      'challenges': StringBuffer(),
      'communication': StringBuffer(),
      'longTerm': StringBuffer(),
    };

    String? currentSection;
    
    for (final line in lines) {
      final lower = line.toLowerCase();
      
      // Detect section headers
      if (lower.contains('summary') || lower.contains('özet') || lower.contains('genel')) {
        currentSection = 'summary';
        continue;
      } else if (lower.contains('love') || lower.contains('aşk') || lower.contains('romantik')) {
        currentSection = 'love';
        continue;
      } else if (lower.contains('family') || lower.contains('aile')) {
        currentSection = 'family';
        continue;
      } else if (lower.contains('career') || lower.contains('kariyer') || lower.contains('iş')) {
        currentSection = 'career';
        continue;
      } else if (lower.contains('strength') || lower.contains('güçlü') || lower.contains('uyumlu')) {
        currentSection = 'strengths';
        continue;
      } else if (lower.contains('challenge') || lower.contains('zorluk') || lower.contains('dikkat')) {
        currentSection = 'challenges';
        continue;
      } else if (lower.contains('communication') || lower.contains('iletişim')) {
        currentSection = 'communication';
        continue;
      } else if (lower.contains('long') || lower.contains('uzun') || lower.contains('gelecek')) {
        currentSection = 'longTerm';
        continue;
      }

      if (currentSection != null && sections.containsKey(currentSection)) {
        if (sections[currentSection]!.isNotEmpty) {
          sections[currentSection]!.write(' ');
        }
        sections[currentSection]!.write(line);
      }
    }

    // Use fallback if parsing completely failed
    final hasContent = sections.values.any((buf) => buf.toString().trim().isNotEmpty);
    if (!hasContent) {
      return _getFallbackResult(language);
    }

    return CompatibilityResult(
      summary: sections['summary']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Uyumluluk analizi üretilemiyor.' : 'Cannot generate compatibility analysis.') 
          : sections['summary']!.toString().trim(),
      love: sections['love']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Aşk analizi üretilemiyor.' : 'Cannot generate love analysis.') 
          : sections['love']!.toString().trim(),
      family: sections['family']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Aile analizi üretilemiyor.' : 'Cannot generate family analysis.') 
          : sections['family']!.toString().trim(),
      career: sections['career']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Kariyer analizi üretilemiyor.' : 'Cannot generate career analysis.') 
          : sections['career']!.toString().trim(),
      strengths: sections['strengths']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Güçlü yönler analizi üretilemiyor.' : 'Cannot generate strengths analysis.') 
          : sections['strengths']!.toString().trim(),
      challenges: sections['challenges']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Zorluklar analizi üretilemiyor.' : 'Cannot generate challenges analysis.') 
          : sections['challenges']!.toString().trim(),
      communication: sections['communication']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'İletişim analizi üretilemiyor.' : 'Cannot generate communication analysis.') 
          : sections['communication']!.toString().trim(),
      longTerm: sections['longTerm']!.toString().trim().isEmpty 
          ? (language == 'tr' ? 'Uzun vade analizi üretilemiyor.' : 'Cannot generate long-term analysis.') 
          : sections['longTerm']!.toString().trim(),
    );
  }

  CompatibilityResult _getFallbackResult(String language) {
    // DO NOT return static compatibility text
    if (language == 'tr') {
      return CompatibilityResult(
        summary: 'Uyumluluk analizi üretilemiyor. Lütfen tekrar deneyin.',
        love: 'Aşk analizi üretilemiyor.',
        family: 'Aile analizi üretilemiyor.',
        career: 'Kariyer analizi üretilemiyor.',
        strengths: 'Güçlü yönler analizi üretilemiyor.',
        challenges: 'Zorluklar analizi üretilemiyor.',
        communication: 'İletişim analizi üretilemiyor.',
        longTerm: 'Uzun vade analizi üretilemiyor.',
      );
    } else {
      return CompatibilityResult(
        summary: 'Cannot generate compatibility analysis. Please try again.',
        love: 'Cannot generate love analysis.',
        family: 'Cannot generate family analysis.',
        career: 'Cannot generate career analysis.',
        strengths: 'Cannot generate strengths analysis.',
        challenges: 'Cannot generate challenges analysis.',
        communication: 'Cannot generate communication analysis.',
        longTerm: 'Cannot generate long-term analysis.',
      );
    }
  }
}

