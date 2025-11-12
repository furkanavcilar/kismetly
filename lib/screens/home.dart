import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/locale_collator.dart';
import '../data/horoscope_insights_en.dart';
import '../data/horoscope_insights_tr.dart';
import '../data/zodiac_signs.dart';
import '../features/coffee/coffee_reading_screen.dart';
import '../features/dreams/dream_interpreter_screen.dart';
import '../services.dart';
import 'horoscope_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onMenuTap,
    required this.onOpenCompatibility,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onOpenCompatibility;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _sunKey = 'sun_sign';
  static const _risingKey = 'rising_sign';

  String? _sunSignId;
  String? _risingSignId;
  bool _loading = true;
  String? _matchLeft;
  String? _matchRight;
  HoroscopeBundle? _horoscope;
  bool _loadingHoroscope = false;
  String? _horoscopeError;
  int _selectedHoroscopeIndex = 0;
  String? _quote;
  bool _loadingQuote = false;
  String? _quoteError;

  @override
  void initState() {
    super.initState();
    _loadSigns();
    _loadQuote();
  }

  Future<void> _loadSigns() async {
    if (mounted) {
      setState(() => _loading = true);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final sun = prefs.getString(_sunKey);
    final rising = prefs.getString(_risingKey);
    setState(() {
      _sunSignId = sun;
      _risingSignId = rising;
      _matchLeft = sun ?? zodiacSigns.first.id;
      _matchRight = rising ?? zodiacSigns.last.id;
      _loading = false;
    });
    if (sun != null) {
      _fetchHoroscopeFor(sun);
    } else {
      setState(() {
        _horoscope = null;
        _horoscopeError = null;
        _loadingHoroscope = false;
      });
    }
  }

  Future<void> _updateSun(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sunKey, id);
    setState(() {
      _sunSignId = id;
      _matchLeft = id;
      _selectedHoroscopeIndex = 0;
    });
    _fetchHoroscopeFor(id);
  }

  Future<void> _updateRising(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_risingKey, id);
    setState(() {
      _risingSignId = id;
      _matchRight = id;
    });
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loadingQuote = true;
      _quoteError = null;
    });
    try {
      final value = await AstroService.fetchDailyQuote();
      if (!mounted) return;
      setState(() {
        _quote = value;
        _loadingQuote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQuote = false;
        _quoteError = e.toString();
      });
    }
  }

  Future<void> _fetchHoroscopeFor(String sunId) async {
    setState(() {
      _loadingHoroscope = true;
      _horoscopeError = null;
    });
    final turkishLabel = findZodiacById(sunId)?.labelFor('tr') ?? sunId;
    try {
      final bundle = await AstroService.fetchHoroscopeBundle(turkishLabel);
      if (!mounted) return;
      setState(() {
        _horoscope = bundle;
        _loadingHoroscope = false;
        _selectedHoroscopeIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingHoroscope = false;
        _horoscopeError = e.toString();
      });
    }
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HoroscopeDetailScreen(signId: id)),
    );
  }

  List<_EnergyFocusData> _energyFocuses(AppLocalizations loc) {
    return [
      _EnergyFocusData(
        label: loc.translate('homeEnergyFocusLove'),
        strength: _focusValue('love', 0.12),
        icon: Icons.favorite_outline,
      ),
      _EnergyFocusData(
        label: loc.translate('homeEnergyFocusCareer'),
        strength: _focusValue('career', 0.06),
        icon: Icons.work_outline,
      ),
      _EnergyFocusData(
        label: loc.translate('homeEnergyFocusSpirit'),
        strength: _focusValue('spirit', 0.1),
        icon: Icons.self_improvement,
      ),
      _EnergyFocusData(
        label: loc.translate('homeEnergyFocusSocial'),
        strength: _focusValue('social', 0.04),
        icon: Icons.groups_2,
      ),
    ];
  }

  double _focusValue(String key, double offset) {
    final seed = '${_sunSignId ?? 'sun'}-${_risingSignId ?? 'rise'}-$key'.hashCode;
    final normalized = ((seed & 0x7fffffff) % 51) / 100;
    final base = 0.35 + normalized + offset;
    return base.clamp(0.35, 0.95);
  }

  String? _interactionDescription(AppLocalizations loc, String language) {
    if (_sunSignId == null || _risingSignId == null) return null;
    final firstLabel = _labelFor(_sunSignId!, language);
    final secondLabel = _labelFor(_risingSignId!, language);
    final report = AstroService.compatibility(
      _labelFor(_sunSignId!, 'tr'),
      _labelFor(_risingSignId!, 'tr'),
    );
    final score = (report.score * 100).round().clamp(0, 100);
    final tone = loc.translate(_toneKeyForScore(score));
    return loc.translate('homeInteractionsDescription', params: {
      'first': firstLabel,
      'second': secondLabel,
      'tone': tone,
      'score': score.toString(),
    });
  }

  String _toneKeyForScore(int score) {
    if (score >= 80) return 'toneHigh';
    if (score >= 60) return 'toneBalanced';
    if (score >= 40) return 'toneFlux';
    return 'toneTransform';
  }

  String _labelFor(String id, String language) {
    return findZodiacById(id)?.labelFor(language) ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final provider = LocaleScope.of(context);
    final locale = provider.locale;
    final language = locale.languageCode;
    final collator = const LocaleCollator();
    final sortedSigns = [...zodiacSigns]
      ..sort((a, b) => collator.compare(a.labelFor(language), b.labelFor(language), locale));
    final now = DateTime.now();
    final sunInsight = _sunSignId == null
        ? null
        : language == 'en'
            ? sunInsightForEn(_sunSignId!, now)
            : sunInsightForTr(_sunSignId!, now);
    final risingInsight = _risingSignId == null
        ? null
        : language == 'en'
            ? risingInsightForEn(_risingSignId!, now)
            : risingInsightForTr(_risingSignId!, now);
    final formatter = DateFormat.yMMMMd(language);
    final energyFocuses = _energyFocuses(loc);
    final interactionDescription = _interactionDescription(loc, language);
    final horoscopeTitle = _sunSignId == null
        ? null
        : loc.translate('homeHoroscopeTitle',
            params: {'sign': _labelFor(_sunSignId!, language)});
    final horoscopeTabs = [
      loc.translate('homeHoroscopeTabsDaily'),
      loc.translate('homeHoroscopeTabsMonthly'),
      loc.translate('homeHoroscopeTabsYearly'),
    ];
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
        title: Text(loc.translate('menuHome')),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: widget.onOpenCompatibility,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadSigns();
                await _loadQuote();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                children: [
                  Text(
                    loc.translate('homeDailyTitle'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(now),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  _InsightSection(
                    title: loc.translate('homeDailyCardTitle'),
                    sunId: _sunSignId,
                    risingId: _risingSignId,
                    sunInsight: sunInsight,
                    risingInsight: risingInsight,
                    onSelectSun: (id) => _updateSun(id),
                    onSelectRising: (id) => _updateRising(id),
                    signs: sortedSigns,
                    locale: locale,
                  ),
                  const SizedBox(height: 20),
                  _ShortcutRow(
                    onDream: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DreamInterpreterScreen(
                          onMenuTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ),
                    onCoffee: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CoffeeReadingScreen(
                          onMenuTap: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ),
                    onCompatibility: widget.onOpenCompatibility,
                  ),
                  const SizedBox(height: 24),
                  _CompatibilityPreview(
                    left: _matchLeft ?? sortedSigns.first.id,
                    right: _matchRight ?? sortedSigns.last.id,
                    onLeftChanged: (value) => setState(() => _matchLeft = value),
                    onRightChanged: (value) => setState(() => _matchRight = value),
                    signs: sortedSigns,
                    locale: locale,
                    onOpenFull: widget.onOpenCompatibility,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.translate('homeDailyQuote'),
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          if (_loadingQuote)
                            const _LoaderLine()
                          else if (_quoteError != null)
                            _ErrLine(
                              message: loc.translate('homeQuoteError'),
                              onRetry: _loadQuote,
                            )
                          else
                            Text(
                              (_quote == null || _quote!.isEmpty)
                                  ? loc.translate('homeQuoteEmpty')
                                  : _quote!,
                              style:
                                  theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(loc.translate('homeTrending'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FeatureChip(
                        label: loc.translate('homeShortcutDream'),
                        icon: Icons.bedtime,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DreamInterpreterScreen(
                              onMenuTap: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ),
                      ),
                      _FeatureChip(
                        label: loc.translate('homeShortcutCoffee'),
                        icon: Icons.local_cafe,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CoffeeReadingScreen(
                              onMenuTap: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ),
                      ),
                      _FeatureChip(
                        label: loc.translate('homeShortcutCompatibility'),
                        icon: Icons.favorite,
                        onTap: widget.onOpenCompatibility,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(loc.translate('homeDailyEnergy'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        energyFocuses.map((focus) => _EnergyFocus(data: focus)).toList(),
                  ),
                  if (interactionDescription != null) ...[
                    const SizedBox(height: 24),
                    _InteractionPreview(
                      title: loc.translate('homeInteractionsTitle'),
                      description: interactionDescription!,
                      hint: loc.translate('homeInteractionsHint'),
                      onTap: widget.onOpenCompatibility,
                    ),
                  ],
                  if (horoscopeTitle != null) ...[
                    const SizedBox(height: 24),
                    _HoroscopePreview(
                      title: horoscopeTitle!,
                      tabs: horoscopeTabs,
                      loading: _loadingHoroscope,
                      bundle: _horoscope,
                      hasError: _horoscopeError != null,
                      selectedIndex: _selectedHoroscopeIndex,
                      onSelect: (index) => setState(() => _selectedHoroscopeIndex = index),
                      emptyText: loc.translate('homeHoroscopeEmpty'),
                      errorText: loc.translate('homeHoroscopeError'),
                      onRetry: _sunSignId == null
                          ? null
                          : () => _fetchHoroscopeFor(_sunSignId!),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(loc.translate('homePickSign'), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedSigns.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final sign = sortedSigns[index];
                      final label = sign.labelFor(language);
                      return _SignCard(
                        label: label,
                        onTap: () => _openDetail(sign.id),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _InsightSection extends StatelessWidget {
  const _InsightSection({
    super.key,
    required this.title,
    required this.sunId,
    required this.risingId,
    required this.sunInsight,
    required this.risingInsight,
    required this.onSelectSun,
    required this.onSelectRising,
    required this.signs,
    required this.locale,
  });

  final String title;
  final String? sunId;
  final String? risingId;
  final String? sunInsight;
  final String? risingInsight;
  final ValueChanged<String?> onSelectSun;
  final ValueChanged<String?> onSelectRising;
  final List<ZodiacSign> signs;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = locale.languageCode;
    final sunLabel = sunId == null
        ? ''
        : findZodiacById(sunId!)?.labelFor(language) ?? sunId!;
    final risingLabel = risingId == null
        ? ''
        : findZodiacById(risingId!)?.labelFor(language) ?? risingId!;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: sunId,
              items: signs
                  .map(
                    (sign) => DropdownMenuItem(
                      value: sign.id,
                      child: Text(sign.labelFor(language)),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: loc.translate('pickerSun'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: onSelectSun,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: risingId,
              items: signs
                  .map(
                    (sign) => DropdownMenuItem(
                      value: sign.id,
                      child: Text(sign.labelFor(language)),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: loc.translate('pickerRising'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: onSelectRising,
            ),
            const SizedBox(height: 16),
            if (sunInsight != null)
              Text(
                loc.translate('homeSunInsight', params: {
                  'sign': sunLabel,
                  'message': sunInsight!.isEmpty
                      ? loc.translate('insightSunDefault')
                      : sunInsight!,
                }),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              )
            else
              Text(loc.translate('homeNoSelection')),
            const SizedBox(height: 12),
            if (risingInsight != null)
              Text(
                loc.translate('homeRisingInsight', params: {
                  'sign': risingLabel,
                  'message': risingInsight!.isEmpty
                      ? loc.translate('insightRisingDefault')
                      : risingInsight!,
                }),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    super.key,
    required this.onDream,
    required this.onCoffee,
    required this.onCompatibility,
  });

  final VoidCallback onDream;
  final VoidCallback onCoffee;
  final VoidCallback onCompatibility;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ShortcutCard(
          icon: Icons.bedtime,
          label: loc.translate('homeShortcutDream'),
          onTap: onDream,
        ),
        _ShortcutCard(
          icon: Icons.local_cafe,
          label: loc.translate('homeShortcutCoffee'),
          onTap: onCoffee,
        ),
        _ShortcutCard(
          icon: Icons.favorite,
          label: loc.translate('homeShortcutCompatibility'),
          onTap: onCompatibility,
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompatibilityPreview extends StatelessWidget {
  const _CompatibilityPreview({
    super.key,
    required this.left,
    required this.right,
    required this.onLeftChanged,
    required this.onRightChanged,
    required this.signs,
    required this.locale,
    required this.onOpenFull,
  });

  final String left;
  final String right;
  final ValueChanged<String> onLeftChanged;
  final ValueChanged<String> onRightChanged;
  final List<ZodiacSign> signs;
  final Locale locale;
  final VoidCallback onOpenFull;

  int _score(String a, String b) {
    final base = a.codeUnitAt(0) + b.codeUnitAt(0);
    return 50 + (base % 51);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final language = locale.languageCode;
    final score = _score(left, right);
    final loveScore = (score * 0.9).round();
    final friendScore = (score * 0.8).round();
    final workScore = (score * 0.7).round();
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.translate('homeLoveMatch'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: left,
                    decoration: InputDecoration(
                      labelText: loc.translate('homeSelectPrompt'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                      if (value != null) onLeftChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: right,
                    decoration: InputDecoration(
                      labelText: loc.translate('homeSelectPrompt'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                      if (value != null) onRightChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ScoreRow(label: loc.translate('homeLoveMatch'), score: loveScore),
            _ScoreRow(label: loc.translate('homeFriendMatch'), score: friendScore),
            _ScoreRow(label: loc.translate('homeWorkMatch'), score: workScore),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOpenFull,
                child: Text(loc.translate('homeOpenCompatibility')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({super.key, required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$score/100'),
        ],
      ),
    );
  }
}

class _SignCard extends StatelessWidget {
  const _SignCard({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Icon(Icons.auto_awesome, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyFocusData {
  const _EnergyFocusData({
    required this.label,
    required this.strength,
    required this.icon,
  });

  final String label;
  final double strength;
  final IconData icon;
}

class _EnergyFocus extends StatelessWidget {
  const _EnergyFocus({super.key, required this.data});

  final _EnergyFocusData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(data.label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: data.strength,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(data.strength * 100).round()}%',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InteractionPreview extends StatelessWidget {
  const _InteractionPreview({
    super.key,
    required this.title,
    required this.description,
    required this.hint,
    required this.onTap,
  });

  final String title;
  final String description;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoaderLine extends StatelessWidget {
  const _LoaderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 6,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }
}

class _ErrLine extends StatelessWidget {
  const _ErrLine({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        if (onRetry != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            onPressed: onRetry,
          ),
      ],
    );
  }
}

class _HoroscopePreview extends StatelessWidget {
  const _HoroscopePreview({
    super.key,
    required this.title,
    required this.tabs,
    required this.loading,
    required this.bundle,
    required this.hasError,
    required this.selectedIndex,
    required this.onSelect,
    required this.emptyText,
    required this.errorText,
    this.onRetry,
  });

  final String title;
  final List<String> tabs;
  final bool loading;
  final HoroscopeBundle? bundle;
  final bool hasError;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String emptyText;
  final String errorText;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = [bundle?.daily, bundle?.monthly, bundle?.yearly];
    Widget body;
    if (loading) {
      body = const _LoaderLine();
    } else if (hasError) {
      body = _ErrLine(message: errorText, onRetry: onRetry);
    } else {
      final content = entries[selectedIndex];
      if (content != null && content.trim().isNotEmpty) {
        body = Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        );
      } else {
        body = Text(
          emptyText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }
    }

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(tabs.length, (index) {
                final selected = selectedIndex == index;
                return ChoiceChip(
                  label: Text(tabs[index]),
                  selected: selected,
                  onSelected: (_) => onSelect(index),
                );
              }),
            ),
            const SizedBox(height: 16),
            body,
          ],
        ),
      ),
    );
  }
}
