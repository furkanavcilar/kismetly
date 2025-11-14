import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../services/monetization/monetization_service.dart';

/// Service for generating home insights (Love, Career, Spiritual, Social)
/// 
/// Uses featureKey: "home_energy_insights"
/// AI generates 2-3 sentences per category
/// Single combined call with structured parsing
/// Daily cached, limited by usage
class HomeInsightsService {
  HomeInsightsService({
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

  static const String _featureKey = UsageLimiter.featureHomeEnergyInsights;

  /// Get date stamp for today (YYYY-MM-DD)
  String _dayStamp(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }


  /// Get home insights (cached, limited)
  /// 
  /// Returns null if limit exceeded. Show premium dialog if needed.
  Future<HomeInsightsData?> getInsights({
    required String sunSign,
    required String? risingSign,
    required DateTime date,
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

    final today = date;
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;

    // Create cache key
    final cacheKey = 'home_insights_${sunSign}_${risingSign ?? 'unknown'}_${language}_$dayKey';

    // Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = prefs.getString(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        try {
          final json = jsonDecode(cached) as Map<String, dynamic>;
          debugPrint('HomeInsightsService: Using cached insights');
          return HomeInsightsData.fromJson(json);
        } catch (e) {
          debugPrint('HomeInsightsService: Error parsing cached insights: $e');
        }
      }
    }

    // Generate new insights
    final insights = await _generateInsights(
      sunSign: sunSign,
      risingSign: risingSign,
      date: today,
      language: language,
    );

    // Record usage (only if not premium)
    await _usageLimiter.recordUsage(_featureKey);

    // Cache the result
    await prefs.setString(cacheKey, jsonEncode(insights.toJson()));

    return insights;
  }

  /// Generate insights using AI orchestrator
  Future<HomeInsightsData> _generateInsights({
    required String sunSign,
    required String? risingSign,
    required DateTime date,
    required String language,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen duygusal zekası yüksek bir kozmik rehbersin. Aşk, kariyer, ruhsal ve sosyal alanlar için günlük içgörüler sağlarsın. Her kategori için 2-3 cümle yaz. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. İçgörüler benzersiz ve kişisel olmalı. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a cosmic guide with high emotional intelligence. You provide daily insights for love, career, spiritual, and social areas. Write 2-3 sentences per category. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Insights must be unique and personal. Never mention AI, models, or technology.''';

    final dateStr = '${date.day}/${date.month}/${date.year}';
    final risingText = risingSign != null ? ' ve $risingSign yükselen burcu' : '';
    
    final userPrompt = language == 'tr'
        ? '''$sunSign güneş burcu$risingText için bugünün ($dateStr) içgörülerini yaz:
        
Aşk: 2-3 cümle
Kariyer: 2-3 cümle
Ruhsal: 2-3 cümle
Sosyal: 2-3 cümle

Her kategoriyi ayrı satırlarda yaz ve başlıkları kullan.'''
        : '''Write today's ($dateStr) insights for $sunSign sun sign$risingText:

Love: 2-3 sentences
Career: 2-3 sentences
Spiritual: 2-3 sentences
Social: 2-3 sentences

Write each category on separate lines with headers.''';

    try {
      // Generate unique seed for this sun sign + rising sign + date combination
      final seed = (sunSign.hashCode ^ (risingSign?.hashCode ?? 0) ^ date.millisecondsSinceEpoch) & 0x7FFFFFFF;
      
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        date: date,
        explicitSeed: seed,
        context: {
          'sunSign': sunSign,
          if (risingSign != null) 'risingSign': risingSign,
          'date': dateStr,
          'dayOfWeek': date.weekday,
          'dayOfYear': date.difference(DateTime(date.year, 1, 1)).inDays,
        },
      );

      return _parseInsights(result, language);
    } catch (e) {
      debugPrint('HomeInsightsService: Error generating insights: $e');
      // Fallback insights (error message, not static text)
      return _getFallbackInsights(language);
    }
  }

  HomeInsightsData _parseInsights(String text, String language) {
    // Parse insights sections
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final Map<String, String> insights = {
      'love': '',
      'career': '',
      'spiritual': '',
      'social': '',
    };

    String? currentCategory;
    final buffer = StringBuffer();

    for (final line in lines) {
      final lower = line.toLowerCase();
      
      if (lower.contains('aşk') || lower.contains('love')) {
        if (currentCategory != null && buffer.isNotEmpty) {
          insights[currentCategory] = buffer.toString().trim();
        }
        currentCategory = 'love';
        buffer.clear();
        continue;
      } else if (lower.contains('kariyer') || lower.contains('career')) {
        if (currentCategory != null && buffer.isNotEmpty) {
          insights[currentCategory] = buffer.toString().trim();
        }
        currentCategory = 'career';
        buffer.clear();
        continue;
      } else if (lower.contains('ruhsal') || lower.contains('spiritual')) {
        if (currentCategory != null && buffer.isNotEmpty) {
          insights[currentCategory] = buffer.toString().trim();
        }
        currentCategory = 'spiritual';
        buffer.clear();
        continue;
      } else if (lower.contains('sosyal') || lower.contains('social')) {
        if (currentCategory != null && buffer.isNotEmpty) {
          insights[currentCategory] = buffer.toString().trim();
        }
        currentCategory = 'social';
        buffer.clear();
        continue;
      }

      if (currentCategory != null) {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(line);
      }
    }

    // Set final category
    if (currentCategory != null && buffer.isNotEmpty) {
      insights[currentCategory] = buffer.toString().trim();
    }

    // If parsing failed, use fallback
    if (insights['love']!.isEmpty && insights['career']!.isEmpty && insights['spiritual']!.isEmpty && insights['social']!.isEmpty) {
      return _getFallbackInsights(language);
    }

    return HomeInsightsData(
      love: insights['love']!.isEmpty ? (language == 'tr' ? 'Bugün aşk alanında dengeli enerjiler var.' : 'Today brings balanced energies in love.') : insights['love']!,
      career: insights['career']!.isEmpty ? (language == 'tr' ? 'Kariyer alanında ilerleme fırsatları var.' : 'Opportunities for progress in career.') : insights['career']!,
      spiritual: insights['spiritual']!.isEmpty ? (language == 'tr' ? 'Ruhsal gelişim için uygun bir gün.' : 'A good day for spiritual growth.') : insights['spiritual']!,
      social: insights['social']!.isEmpty ? (language == 'tr' ? 'Sosyal bağlantılar güçleniyor.' : 'Social connections are strengthening.') : insights['social']!,
    );
  }

  HomeInsightsData _getFallbackInsights(String language) {
    if (language == 'tr') {
      return HomeInsightsData(
        love: 'Bugün aşk alanında dengeli enerjiler var. Bağlantılarını güçlendirme zamanı.',
        career: 'Kariyer alanında ilerleme fırsatları var. Yeni projeler için uygun bir gün.',
        spiritual: 'Ruhsal gelişim için uygun bir gün. İç sesini dinlemeye zaman ayır.',
        social: 'Sosyal bağlantılar güçleniyor. Arkadaşlarınla vakit geçirmek faydalı olacak.',
      );
    } else {
      return HomeInsightsData(
        love: 'Today brings balanced energies in love. Time to strengthen connections.',
        career: 'Opportunities for progress in career. A good day for new projects.',
        spiritual: 'A good day for spiritual growth. Take time to listen to your inner voice.',
        social: 'Social connections are strengthening. Spending time with friends will be beneficial.',
      );
    }
  }
