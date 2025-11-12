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
    if (mounted) setState(() => _loading = true);
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

  double _focusValue(String key, double offset) {
    final seed = '${_sunSignId ?? 'sun'}-${_risingSignId ?? 'rise'}-$key'.hashCode;
    final normalized = ((seed & 0x7fffffff) % 51) / 100;
    final base = 0.35 + normalized + offset;
    return base.clamp(0.35, 0.95);
  }

  List<_EnergyFocusData> _energyFocuses(AppLocalizations loc) {
    return [
      _EnergyFocusData(label: loc.translate('homeEnergyFocusLove'), strength: _focusValue('love', 0.12), icon: Icons.favorite_outline),
      _EnergyFocusData(label: loc.translate('homeEnergyFocusCareer'), strength: _focusValue('career', 0.06), icon: Icons.work_outline),
      _EnergyFocusData(label: loc.translate('homeEnergyFocusSpirit'), strength: _focusValue('spirit', 0.1), icon: Icons.self_improvement),
      _EnergyFocusData(label: loc.translate('homeEnergyFocusSocial'), strength: _focusValue('social', 0.04), icon: Icons.groups_2),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final language = locale.languageCode;
    final collator = const LocaleCollator();
    final sortedSigns = [...zodiacSigns]..sort((a, b) => collator.compare(a.labelFor(language), b.labelFor(language), locale));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
        title: Text(loc.translate('menuHome')),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_outline), onPressed: widget.onOpenCompatibility),
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
                children: [
                  if (_loadingQuote)
                    const _LoaderLine()
                  else if (_quoteError != null)
                    _ErrLine(message: loc.translate('homeQuoteError'), onRetry: _loadQuote)
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _quote ?? loc.translate('homeQuoteEmpty'),
                        key: ValueKey(_quote),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _energyFocuses(loc).map((e) => _EnergyFocus(data: e)).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EnergyFocusData {
  final String label;
  final double strength;
  final IconData icon;
  const _EnergyFocusData({required this.label, required this.strength, required this.icon});
}

class _EnergyFocus extends StatelessWidget {
  final _EnergyFocusData data;
  const _EnergyFocus({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(data.label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: data.strength, minHeight: 6),
          const SizedBox(height: 8),
          Text('${(data.strength * 100).round()}%', style: theme.textTheme.bodySmall),
        ],
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
      child: LinearProgressIndicator(minHeight: 6),
    );
  }
}

class _ErrLine extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrLine({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))),
        if (onRetry != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRetry,
          ),
      ],
    );
  }
}
