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

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sunSignId = prefs.getString(_sunKey);
      _risingSignId = prefs.getString(_risingKey);
      _matchLeft = _sunSignId ?? zodiacSigns.first.id;
      _matchRight = _risingSignId ?? zodiacSigns.last.id;
      _loading = false;
    });
  }

  Future<void> _updateSun(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sunKey, id);
    setState(() => _sunSignId = id);
  }

  Future<void> _updateRising(String? id) async {
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_risingKey, id);
    setState(() => _risingSignId = id);
  }

  void _openDetail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HoroscopeDetailScreen(signId: id)),
    );
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
              onRefresh: _loadSigns,
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
  const _ShortcutCard({required this.icon, required this.label, required this.onTap});

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
  const _ScoreRow({required this.label, required this.score});

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
  const _SignCard({required this.label, required this.onTap});

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
