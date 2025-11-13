import 'dart:math';

import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/tarot_cards.dart';
import '../services/ai_service.dart';
import '../services/daily_limits_service.dart';
import '../services/monetization/monetization_service.dart';
import '../features/paywall/upgrade_screen.dart';
import '../features/profile/user_profile_scope.dart';
import '../data/zodiac_signs.dart';

class TarotReadingScreen extends StatefulWidget {
  const TarotReadingScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> {
  final AiService _aiService = AiService();
  final DailyLimitsService _dailyLimits = DailyLimitsService();
  final Random _random = Random();
  List<_DrawnCard>? _drawnCards;
  String? _result;
  bool _loading = false;
  String? _error;
  bool _canUseFree = true;

  @override
  void initState() {
    super.initState();
    _checkDailyLimit();
  }

  Future<void> _checkDailyLimit() async {
    final canUse = await _dailyLimits.canUseFeature('tarot');
    if (mounted) {
      setState(() => _canUseFree = canUse);
    }
  }

  void _drawCards() {
    final selected = <_DrawnCard>[];
    final available = List<TarotCard>.from(majorArcana);
    
    // Draw 3 cards randomly
    for (int i = 0; i < 3 && available.isNotEmpty; i++) {
      final index = _random.nextInt(available.length);
      final card = available.removeAt(index);
      final isReversed = _random.nextBool();
      selected.add(_DrawnCard(card: card, reversed: isReversed));
    }
    
    setState(() {
      _drawnCards = selected;
      _result = null;
      _error = null;
    });
  }

  Future<void> _interpret() async {
    final loc = AppLocalizations.of(context);
    final monetization = MonetizationService.instance;

    if (_drawnCards == null || _drawnCards!.isEmpty) {
      setState(() {
        _error = loc.translate('tarotNoCards') ?? 'Please draw cards first';
      });
      return;
    }

    // Check daily free limit
    if (!_canUseFree && !monetization.isPremium) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Record usage if free
    if (_canUseFree && !monetization.isPremium) {
      await _dailyLimits.recordFeatureUse('tarot');
      setState(() => _canUseFree = false);
    }

    try {
      final locale = LocaleScope.of(context).locale;
      final profile = UserProfileScope.of(context).profile;
      final userSign = profile?.sunSign != null
          ? findZodiacById(profile!.sunSign!)?.labelFor(locale.languageCode) ?? ''
          : '';

      final cardNames = _drawnCards!.map((dc) {
        final label = dc.card.labelFor(locale.languageCode);
        return dc.reversed ? '$label (Reversed)' : label;
      }).join(', ');

      final reading = await _aiService.interpretTarot(
        cardNames: cardNames,
        userSign: userSign,
        locale: locale,
      );

      if (mounted) {
        setState(() {
          _result = reading;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('menuTarot')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('tarotDescription') ??
                  'Kartlarını seç ve kozmik rehberliğini keşfet.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_drawnCards != null && _drawnCards!.isNotEmpty) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _drawnCards!.map((dc) {
                  final label = dc.card.labelFor(locale.languageCode);
                  return _TarotCardWidget(
                    label: label,
                    reversed: dc.reversed,
                    emoji: dc.card.emoji,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (!_canUseFree && !MonetizationService.instance.isPremium) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.translate('tarotDailyLimit') ??
                            'Daily free limit reached. Upgrade to Pro for unlimited access.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _drawCards,
                    child: Text(loc.translate('tarotDrawCards') ?? 'Draw Cards'),
                  ),
                ),
                if (_drawnCards != null && _drawnCards!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _interpret,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(loc.translate('tarotInterpret') ?? 'Interpret'),
                    ),
                  ),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              Text(
                loc.translate('tarotReading') ?? 'Your Tarot Reading',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                _result!,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawnCard {
  const _DrawnCard({
    required this.card,
    required this.reversed,
  });

  final TarotCard card;
  final bool reversed;
}

class _TarotCardWidget extends StatelessWidget {
  const _TarotCardWidget({
    required this.label,
    required this.reversed,
    this.emoji,
  });

  final String label;
  final bool reversed;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emoji != null)
            Text(
              emoji!,
              style: const TextStyle(fontSize: 32),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (reversed)
            Text(
              '↻',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}


