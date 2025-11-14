import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/services/ai/ai_orchestrator.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/premium_dialog.dart';
import '../../../services/monetization/monetization_service.dart';
import '../../../data/tarot_cards.dart';

/// Service for tarot reading
/// 
/// Uses featureKey: "tarot_reading"
/// User selects 5-7 cards.
/// AI generates:
/// - per card meaning (1-2 paragraphs)
/// - final combined reading (2-3 paragraphs)
/// 
/// Limited by usage.
class TarotReadingService {
  TarotReadingService({
    AiOrchestrator? orchestrator,
    UsageLimiter? usageLimiter,
    MonetizationService? monetizationService,
  })  : _orchestrator = orchestrator ?? AiServiceLocator.instance,
        _usageLimiter = usageLimiter ?? UsageLimiter(monetizationService: monetizationService),
        _monetizationService = monetizationService;

  final AiOrchestrator _orchestrator;
  final UsageLimiter _usageLimiter;
  final MonetizationService? _monetizationService;

  static const String _featureKey = UsageLimiter.featureTarotReading;
}

/// Selected card with orientation
class SelectedTarotCard {
  final TarotCard card;
  final bool isReversed;

  SelectedTarotCard({
    required this.card,
    this.isReversed = false,
  });
}

/// Per-card meaning
class CardMeaning {
  final String cardId;
  final String meaning;
  final bool isReversed;

  CardMeaning({
    required this.cardId,
    required this.meaning,
    this.isReversed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'meaning': meaning,
      'isReversed': isReversed,
    };
  }

  static CardMeaning fromJson(Map<String, dynamic> json) {
    return CardMeaning(
      cardId: json['cardId'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      isReversed: json['isReversed'] as bool? ?? false,
    );
  }
}

/// Tarot reading result
class TarotReading {
    final List<CardMeaning> cardMeanings;
    final String combinedReading;

    TarotReading({
      required this.cardMeanings,
      required this.combinedReading,
    });

    Map<String, dynamic> toJson() {
      return {
        'cardMeanings': cardMeanings.map((m) => m.toJson()).toList(),
        'combinedReading': combinedReading,
      };
    }

    static TarotReading fromJson(Map<String, dynamic> json) {
      final cardMeanings = (json['cardMeanings'] as List<dynamic>?)
              ?.map((m) => CardMeaning.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
      return TarotReading(
        cardMeanings: cardMeanings,
        combinedReading: json['combinedReading'] as String? ?? '',
      );
    }
  }

  /// Generate tarot reading (limited by usage)
  /// 
  /// Returns null if limit exceeded. Show premium dialog if needed.
  Future<TarotReading?> generateReading({
    required List<SelectedTarotCard> selectedCards,
    required String language,
    BuildContext? context,
  }) async {
    if (selectedCards.isEmpty || selectedCards.length < 5 || selectedCards.length > 7) {
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
    final reading = await _generateReading(
      selectedCards: selectedCards,
      language: language,
    );

    // Record usage (only if not premium)
    await _usageLimiter.recordUsage(_featureKey);

    return reading;
  }

  /// Generate tarot reading using AI orchestrator
  Future<TarotReading> _generateReading({
    required List<SelectedTarotCard> selectedCards,
    required String language,
  }) async {
    final systemPrompt = language == 'tr'
        ? '''Sen profesyonel bir tarot okuyucusu ve kozmik rehbersin. Tarot kartları için derin yorumlar yazarsın. Her kart için 1-2 paragraf, son olarak birleşik okuma için 2-3 paragraf yaz. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yorumlar sembolik anlamlar, duygusal derinlik ve ruhsal mesajlar içermeli. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a professional tarot reader and cosmic guide. You write deep interpretations for tarot cards. Write 1-2 paragraphs per card, and 2-3 paragraphs for the combined reading. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Interpretations should include symbolic meanings, emotional depth, and spiritual messages. Never mention AI, models, or technology.''';

    final cardsList = selectedCards.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final selected = entry.value;
      final orientation = selected.isReversed
          ? (language == 'tr' ? 'ters' : 'reversed')
          : (language == 'tr' ? 'düz' : 'upright');
      final cardLabel = selected.card.labelFor(language);
      return '$index. $cardLabel ($orientation)';
    }).join('\n');

    final userPrompt = language == 'tr'
        ? '''Aşağıdaki tarot kartlarını yorumla:

$cardsList

Her kart için 1-2 paragraf yaz, sonra tüm kartlar için birleşik bir okuma yap (2-3 paragraf). Her kartın anlamını ve birbirleriyle nasıl etkileşime girdiklerini açıkla.'''
        : '''Interpret the following tarot cards:

$cardsList

Write 1-2 paragraphs per card, then provide a combined reading for all cards (2-3 paragraphs). Explain each card's meaning and how they interact with each other.''';

    try {
      // Generate unique seed based on card selection + timestamp
      final cardsHash = selectedCards.map((c) => c.card.id.hashCode ^ (c.isReversed ? 1 : 0)).reduce((a, b) => a ^ b);
      final seed = (cardsHash ^ DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;
      
      final result = await _orchestrator.generate(
        featureKey: _featureKey,
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        languageCode: language,
        date: DateTime.now(),
        explicitSeed: seed,
        context: {
          'cardCount': selectedCards.length,
          'cards': selectedCards.map((c) => {
            'id': c.card.id,
            'reversed': c.isReversed,
            'name': c.card.labelFor(language),
          }).toList(),
        },
      );

      return _parseReading(result, selectedCards, language);
    } catch (e) {
      debugPrint('TarotReadingService: Error generating reading: $e');
      // Fallback reading (error message, not static text)
      return _getFallbackReading(selectedCards, language);
    }
  }

  TarotReading _parseReading(String text, List<SelectedTarotCard> selectedCards, String language) {
    // Simple parsing: split by card numbers and extract meanings
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    final cardMeanings = <CardMeaning>[];
    final combinedReadingBuffer = StringBuffer();

    // Try to parse card meanings (look for card numbers)
    for (int i = 0; i < selectedCards.length; i++) {
      final card = selectedCards[i];
      final cardLabel = card.card.labelFor(language);
      final cardNumber = i + 1;
      
      // Find section for this card
      String? cardMeaning;
      for (int j = 0; j < lines.length; j++) {
        final line = lines[j].toLowerCase();
        if (line.contains('$cardNumber') || line.contains(cardLabel.toLowerCase())) {
          // Collect paragraphs for this card
          final meaningBuffer = StringBuffer();
          for (int k = j + 1; k < lines.length; k++) {
            final nextLine = lines[k];
            if (nextLine.startsWith('${cardNumber + 1}.') || 
                (cardNumber < selectedCards.length && nextLine.toLowerCase().contains(selectedCards[cardNumber].card.labelFor(language).toLowerCase()))) {
              break;
            }
            if (meaningBuffer.isNotEmpty) meaningBuffer.write(' ');
            meaningBuffer.write(nextLine);
          }
          cardMeaning = meaningBuffer.toString().trim();
          break;
        }
      }

      cardMeanings.add(CardMeaning(
        cardId: card.card.id,
        meaning: cardMeaning ?? _getCardFallback(card, language),
        isReversed: card.isReversed,
      ));
    }

    // Extract combined reading (usually at the end)
    // For simplicity, use last 2-3 paragraphs as combined reading
    final combinedLines = lines.length > 10 ? lines.sublist(lines.length - 5) : lines.sublist((lines.length / 2).floor());
    for (final line in combinedLines) {
      if (combinedReadingBuffer.isNotEmpty) combinedReadingBuffer.write(' ');
      combinedReadingBuffer.write(line);
    }

    return TarotReading(
      cardMeanings: cardMeanings,
      combinedReading: combinedReadingBuffer.toString().trim().isEmpty
          ? _getCombinedFallback(language)
          : combinedReadingBuffer.toString().trim(),
    );
  }

  String _getCardFallback(SelectedTarotCard card, String language) {
    // DO NOT return static tarot text
    final cardLabel = card.card.labelFor(language);
    return language == 'tr'
        ? '$cardLabel kartı için yorum üretilemiyor. Lütfen tekrar deneyin.'
        : 'Cannot generate interpretation for $cardLabel card. Please try again.';
  }

  String _getCombinedFallback(String language) {
    // DO NOT return static tarot text
    return language == 'tr'
        ? 'Birleşik okuma üretilemiyor. Lütfen tekrar deneyin.'
        : 'Cannot generate combined reading. Please try again.';
  }

  TarotReading _getFallbackReading(List<SelectedTarotCard> selectedCards, String language) {
    return TarotReading(
      cardMeanings: selectedCards.map((card) => CardMeaning(
        cardId: card.card.id,
        meaning: _getCardFallback(card, language),
        isReversed: card.isReversed,
      )).toList(),
      combinedReading: _getCombinedFallback(language),
    );
  }
}

