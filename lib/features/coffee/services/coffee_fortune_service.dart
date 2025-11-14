import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../services/monetization/monetization_service.dart';

/// Coffee fortune reading result
class CoffeeFortuneReading {
  final String general;
  final String love;
  final String career;
  final String warnings;
  final DateTime createdAt;

  CoffeeFortuneReading({
    required this.general,
    required this.love,
    required this.career,
    required this.warnings,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'love': love,
      'career': career,
      'warnings': warnings,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CoffeeFortuneReading fromJson(Map<String, dynamic> json) {
    return CoffeeFortuneReading(
      general: json['general'] as String? ?? '',
      love: json['love'] as String? ?? '',
      career: json['career'] as String? ?? '',
      warnings: json['warnings'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Service for coffee fortune reading (AI-powered, long)
/// 
/// Uses featureKey: "coffee_fortune"
/// Input: user description + (future) image analysis placeholder
/// AI generates 4-6 paragraph reading with sections.
/// Save history entries.
/// Limited by usage.
class CoffeeFortuneService {
  CoffeeFortuneService({
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

  static const String _featureKey = UsageLimiter.featureCoffeeFortune;
  static const String _historyKey = 'coffee_fortune_history';

  /// Generate coffee fortune reading (limited by usage)
  /// 
  /// Returns null if limit exceeded. Show premium dialog if needed.
  Future<CoffeeFortuneReading?> generateReading({
    required String description,
    required String language,
    List<String>? imageBase64,
    BuildContext? context,
  }) async {
    if (description.trim().isEmpty && (imageBase64 == null || imageBase64.isEmpty)) {
      return null;
    }

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

    // Generate reading
    CoffeeFortuneReading reading;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      // Use image-based reading (placeholder for future)
      reading = await _generateReadingWithImage(
        description: description,
        imageBase64: imageBase64,
        language: language,
      );
    } else {
      // Use description-only reading
      reading = await _generateReadingFromDescription(
        description: description,
        language: language,
      );
    }

    // Save to history
    await _saveToHistory(reading);

    // Record usage (only if not premium)
    await _usageLimiter.recordUsage(_featureKey);

    return reading;
  }

  /// Generate reading from description using AI orchestrator
  Future<CoffeeFortuneReading> _generateReadingFromDescription({
    required String description,
    required String language,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen profesyonel bir kahve falı okuyucusu ve kozmik rehbersin. Kahve telvesi desenlerini yorumlarsın. Her bölüm için 1-2 paragraf, toplam 4-6 paragraf yaz. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yorumlar sembolik anlamlar, duygusal derinlik ve ruhsal mesajlar içermeli. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a professional coffee reader and cosmic guide. You interpret coffee grounds patterns. Write 1-2 paragraphs per section, 4-6 paragraphs total. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Interpretations should include symbolic meanings, emotional depth, and spiritual messages. Never mention AI, models, or technology.''';

    final userPrompt = language == 'tr'
        ? '''Aşağıdaki kahve falı açıklamasını yorumla:

$description

Şu bölümleri yaz:
Genel: 1-2 paragraf
Aşk: 1-2 paragraf
Kariyer: 1-2 paragraf
Uyarılar: 1 paragraf

Her bölümü ayrı başlıklarla yaz.'''
        : '''Interpret the following coffee fortune description:

$description

Write these sections:
General: 1-2 paragraphs
Love: 1-2 paragraphs
Career: 1-2 paragraphs
Warnings: 1 paragraph

Write each section with separate headers.''';

    try {
      // Generate unique seed based on description + timestamp
      final descHash = description.hashCode;
      final seed = (descHash ^ DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;
      
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        date: DateTime.now(),
        explicitSeed: seed,
        context: {
          'hasImage': imageBase64 != null && imageBase64.isNotEmpty,
          'descriptionLength': description.length,
          'hasMultipleSymbols': description.split(RegExp(r'[,\s]+')).length > 3,
        },
      );

      return _parseReading(result, language);
    } catch (e) {
      debugPrint('CoffeeFortuneService: Error generating reading: $e');
      // Fallback reading (error message, not static text)
      return _getFallbackReading(language);
    }
  }

  /// Generate reading with image (placeholder for future image analysis)
  Future<CoffeeFortuneReading> _generateReadingWithImage({
    required String description,
    required List<String> imageBase64,
    required String language,
  }) async {
    // TODO: Implement image analysis when available
    // For now, use description-based reading
    debugPrint('CoffeeFortuneService: Image analysis not yet implemented, using description');
    return _generateReadingFromDescription(
      description: description,
      language: language,
    );
  }

  CoffeeFortuneReading _parseReading(String text, String language) {
    // Parse reading sections
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final Map<String, StringBuffer> sections = {
      'general': StringBuffer(),
      'love': StringBuffer(),
      'career': StringBuffer(),
      'warnings': StringBuffer(),
    };

    String? currentSection;
    
    for (final line in lines) {
      final lower = line.toLowerCase();
      
      if (lower.contains('genel') || lower.contains('general')) {
        currentSection = 'general';
        continue;
      } else if (lower.contains('aşk') || lower.contains('love')) {
        currentSection = 'love';
        continue;
      } else if (lower.contains('kariyer') || lower.contains('career')) {
        currentSection = 'career';
        continue;
      } else if (lower.contains('uyarı') || lower.contains('warning')) {
        currentSection = 'warnings';
        continue;
      }

      if (currentSection != null && sections.containsKey(currentSection)) {
        if (sections[currentSection]!.isNotEmpty) {
          sections[currentSection]!.write(' ');
        }
        sections[currentSection]!.write(line);
      }
    }

    return CoffeeFortuneReading(
      general: sections['general']!.isEmpty 
          ? (language == 'tr' ? 'Genel olarak pozitif enerjiler var.' : 'Generally positive energies present.') 
          : sections['general']!.toString().trim(),
      love: sections['love']!.isEmpty 
          ? (language == 'tr' ? 'Aşk alanında yeni fırsatlar var.' : 'New opportunities in love.') 
          : sections['love']!.toString().trim(),
      career: sections['career']!.isEmpty 
          ? (language == 'tr' ? 'Kariyer alanında ilerleme görünüyor.' : 'Progress visible in career.') 
          : sections['career']!.toString().trim(),
      warnings: sections['warnings']!.isEmpty 
          ? (language == 'tr' ? 'Dikkatli ol ve sezgilerine güven.' : 'Be careful and trust your intuition.') 
          : sections['warnings']!.toString().trim(),
      createdAt: DateTime.now(),
    );
  }

  CoffeeFortuneReading _getFallbackReading(String language) {
    // DO NOT return static coffee reading text
    if (language == 'tr') {
      return CoffeeFortuneReading(
        general: 'Kahve falı okuması üretilemiyor. Lütfen tekrar deneyin.',
        love: 'Şu anda aşk yorumu üretilemiyor.',
        career: 'Şu anda kariyer yorumu üretilemiyor.',
        warnings: 'Şu anda uyarılar üretilemiyor.',
        createdAt: DateTime.now(),
      );
    } else {
      return CoffeeFortuneReading(
        general: 'Cannot generate coffee fortune reading. Please try again.',
        love: 'Cannot generate love reading right now.',
        career: 'Cannot generate career reading right now.',
        warnings: 'Cannot generate warnings right now.',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Save reading to history
  Future<void> _saveToHistory(CoffeeFortuneReading reading) async {
    final prefs = await _prefsFuture;
    final historyJson = prefs.getString(_historyKey);
    
    List<Map<String, dynamic>> history = [];
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(historyJson) as List<dynamic>;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        debugPrint('CoffeeFortuneService: Error parsing history: $e');
      }
    }

    // Add new reading at the beginning
    history.insert(0, reading.toJson());

    // Keep only last 50 readings
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  /// Get reading history
  Future<List<CoffeeFortuneReading>> getHistory() async {
    final prefs = await _prefsFuture;
    final historyJson = prefs.getString(_historyKey);
    
    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(historyJson) as List<dynamic>;
      return decoded
          .map((item) => CoffeeFortuneReading.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CoffeeFortuneService: Error parsing history: $e');
      return [];
    }
  }
}

