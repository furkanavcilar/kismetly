import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/locale_collator.dart';
import '../data/zodiac_signs.dart';
import '../services.dart';

class ZodiacCompatibilityScreen extends StatefulWidget {
  const ZodiacCompatibilityScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<ZodiacCompatibilityScreen> createState() => _ZodiacCompatibilityScreenState();
}

class _ZodiacCompatibilityScreenState extends State<ZodiacCompatibilityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _firstSign;
  late String _secondSign;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _firstSign = zodiacSigns.first.id;
    _secondSign = zodiacSigns.last.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _swap() {
    setState(() {
      final temp = _firstSign;
      _firstSign = _secondSign;
      _secondSign = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final language = locale.languageCode;
    final collator = const LocaleCollator();
    final sorted = [...zodiacSigns]
      ..sort((a, b) => collator.compare(a.labelFor(language), b.labelFor(language), locale));
    final result = calculateCompatibilityResult(_firstSign, _secondSign);
    final firstLabel = findZodiacById(_firstSign)?.labelFor(language) ?? _firstSign;
    final secondLabel = findZodiacById(_secondSign)?.labelFor(language) ?? _secondSign;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
        title: Text(loc.translate('compatibilityTitle')),
        actions: [
          IconButton(icon: const Icon(Icons.swap_horiz), onPressed: _swap),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.translate('compatibilityLove')),
            Tab(text: loc.translate('compatibilityFamily')),
            Tab(text: loc.translate('compatibilityCareer')),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _SignSelector(
              signs: sorted,
              first: _firstSign,
              second: _secondSign,
              onChanged: (a, b) => setState(() {
                _firstSign = a;
                _secondSign = b;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ScoreRing(
              score: result.overall,
              first: firstLabel,
              second: secondLabel,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CompatibilityTab(
                  label: loc.translate('compatibilityLove'),
                  summary: loc.translate('compatibilityLoveTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'tone': _toneForScore(loc, result.love),
                  }),
                  score: result.love,
                  advice: loc.translate('compatibilityAdviceTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'advice': result.loveAdvice(loc),
                  }),
                ),
                _CompatibilityTab(
                  label: loc.translate('compatibilityFamily'),
                  summary: loc.translate('compatibilityFamilyTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'tone': _toneForScore(loc, result.family),
                  }),
                  score: result.family,
                  advice: loc.translate('compatibilityAdviceTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'advice': result.familyAdvice(loc),
                  }),
                ),
                _CompatibilityTab(
                  label: loc.translate('compatibilityCareer'),
                  summary: loc.translate('compatibilityCareerTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'tone': _toneForScore(loc, result.career),
                  }),
                  score: result.career,
                  advice: loc.translate('compatibilityAdviceTemplate', params: {
                    'first': firstLabel,
                    'second': secondLabel,
                    'advice': result.careerAdvice(loc),
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _toneForScore(AppLocalizations loc, int score) {
  if (score >= 80) return loc.translate('toneHigh');
  if (score >= 60) return loc.translate('toneBalanced');
  if (score >= 40) return loc.translate('toneFlux');
  return loc.translate('toneTransform');
}

class _SignSelector extends StatelessWidget {
  const _SignSelector({
    required this.signs,
    required this.first,
    required this.second,
    required this.onChanged,
  });

  final List<ZodiacSign> signs;
  final String first;
  final String second;
  final void Function(String first, String second) onChanged;

  @override
  Widget build(BuildContext context) {
    final language = LocaleScope.of(context).locale.languageCode;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: first,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              labelText: AppLocalizations.of(context).translate('homeSelectPrompt'),
            ),
            items: signs
                .map(
                  (sign) => DropdownMenuItem(
                    value: sign.id,
                    child: Text(sign.labelFor(language)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(value, second);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: second,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              labelText: AppLocalizations.of(context).translate('homeSelectPrompt'),
            ),
            items: signs
                .map(
                  (sign) => DropdownMenuItem(
                    value: sign.id,
                    child: Text(sign.labelFor(language)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onChanged(first, value);
            },
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.first, required this.second});

  final int score;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$first × $second', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).translate('compatibilitySummary')),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: score / 100),
                duration: const Duration(milliseconds: 400),
                builder: (context, value, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      ),
                      Text('$score', style: theme.textTheme.titleLarge),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityTab extends StatelessWidget {
  const _CompatibilityTab({
    required this.label,
    required this.summary,
    required this.score,
    required this.advice,
  });

  final String label;
  final String summary;
  final int score;
  final String advice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${loc.translate('compatibilityScore')}: $score/100'),
          const SizedBox(height: 12),
          Text(summary, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
          const SizedBox(height: 12),
          Text('${loc.translate('compatibilityAdvice')}: $advice',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

CompatibilityResult calculateCompatibilityResult(String firstId, String secondId) {
  final firstTr = findZodiacById(firstId)?.labelFor('tr') ?? firstId;
  final secondTr = findZodiacById(secondId)?.labelFor('tr') ?? secondId;
  final report = AstroService.compatibility(firstTr, secondTr);
  final baseScore = (report.score * 100).round().clamp(0, 100);

  int derive(String key, int bias) {
    final seed = key.hashCode ^ firstId.hashCode ^ (secondId.hashCode << 1);
    final offset = (seed % 17) - 8;
    return (baseScore + offset + bias).clamp(0, 100);
  }

  return CompatibilityResult(
    love: derive('love', 6),
    family: derive('family', 2),
    career: derive('career', -4),
  );
}

class CompatibilityResult {
  const CompatibilityResult({
    required this.love,
    required this.family,
    required this.career,
  });

  final int love;
  final int family;
  final int career;

  int get overall => ((love + family + career) / 3).round();

  String loveAdvice(AppLocalizations loc) => _adviceFor(loc, love);
  String familyAdvice(AppLocalizations loc) => _adviceFor(loc, family);
  String careerAdvice(AppLocalizations loc) => _adviceFor(loc, career);
}

String _adviceFor(AppLocalizations loc, int score) {
  if (score >= 80) return loc.translate('adviceHigh');
  if (score >= 60) return loc.translate('adviceBalanced');
  if (score >= 40) return loc.translate('adviceFlux');
  return loc.translate('adviceTransform');
}
