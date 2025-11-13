import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/zodiac_signs.dart';
import '../features/profile/user_profile_controller.dart';
import '../features/profile/user_profile_scope.dart';
import '../models/daily_ai_insights.dart';
import '../models/weather_report.dart';
import '../services/ai_content_service.dart';
import '../services/weather_service.dart';
import '../services/greeting_service.dart';

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
  final _aiService = AiContentService();
  final _weatherService = WeatherService();
  final _greetingService = GreetingService();
  DailyAiInsights? _insights;
  WeatherReport? _weather;
  bool _loading = true;
  bool _weatherLoading = false;
  String? _error;
  String? _weatherError;
  late UserProfileController _profileController;
  bool _initialized = false;
  String? _greeting;
  
  // Cache formatters to avoid recreating on every build
  DateFormat? _cachedDateFormatter;
  DateFormat? _cachedTimeFormatter;
  String? _cachedLocaleTag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _profileController = UserProfileScope.of(context);
      _profileController.addListener(_onProfileChanged);
      _loadGreeting();
      _loadAll();
      _initialized = true;
    }
  }

  Future<void> _loadGreeting() async {
    final profile = _profileController.profile;
    if (profile == null) return;
    
    final locale = LocaleScope.of(context).locale;
    final greeting = await _greetingService.getGreeting(
      now: DateTime.now(),
      name: profile.name,
      language: locale.languageCode,
    );
    
    if (mounted) {
      setState(() => _greeting = greeting);
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _profileController.removeListener(_onProfileChanged);
    }
    super.dispose();
  }

  void _onProfileChanged() => _loadAll();

  Future<void> _loadAll() async {
    final profile = _profileController.profile;
    if (profile == null) return;
    final locale = LocaleScope.of(context).locale;
    setState(() {
      _loading = true;
      _error = null;
    });

    String describe(String? id) {
      if (id == null) return profile.name;
      final sign = findZodiacById(id);
      return sign?.labelFor(locale.languageCode) ?? id;
    }

    try {
      final insights = await _aiService.fetchDailyInsights(
        sunSign: describe(profile.sunSign),
        risingSign: describe(profile.risingSign),
        locale: locale,
      );
      if (!mounted) return;
      setState(() {
        _insights = insights;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    final profile = _profileController.profile;
    if (profile == null) return;
    final locale = LocaleScope.of(context).locale;
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
    });
    try {
      final report = await _weatherService.fetchWeather(
        city: profile.birthCity,
        latitude: profile.birthLatitude,
        longitude: profile.birthLongitude,
        localeCode: locale.languageCode,
      );
      if (!mounted) return;
      setState(() {
        _weather = report;
        _weatherLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherLoading = false;
        _weatherError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final profile = _profileController.profile;

    if (profile == null) return const SizedBox();

    final locale = LocaleScope.of(context).locale;
    final localeTag = locale.toLanguageTag();
    final now = DateTime.now();
    
    // Cache formatters to avoid recreating on every build
    if (_cachedLocaleTag != localeTag) {
      _cachedLocaleTag = localeTag;
      _cachedDateFormatter = DateFormat.yMMMMEEEEd(localeTag);
      _cachedTimeFormatter = DateFormat.Hm(localeTag);
    }
    final dateFormatter = _cachedDateFormatter!;
    final timeFormatter = _cachedTimeFormatter!;
    final greeting = _greeting ?? loc.translate('onboardingGreeting');
    final sun = profile.sunSign != null
        ? findZodiacById(profile.sunSign!)?.labelFor(locale.languageCode)
        : null;
    final rising = profile.risingSign != null
        ? findZodiacById(profile.risingSign!)?.labelFor(locale.languageCode)
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.translate('homeTitle')),
        leading: IconButton(
            icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: widget.onOpenCompatibility,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _GreetingHeader(
              greeting: greeting,
              date: dateFormatter.format(now),
              time: timeFormatter.format(now),
            ),
            const SizedBox(height: 18),
            _WeatherCard(
              loading: _weatherLoading,
              error: _weatherError,
              report: _weather,
              onRetry: _loadWeather,
              loc: loc,
            ),
            const SizedBox(height: 18),
            _DailyZodiacCard(
              loading: _loading,
              error: _error,
              insights: _insights,
              sun: sun ?? '—',
              rising: rising ?? '—',
              onRetry: _loadAll,
            ),
            const SizedBox(height: 18),
            _EnergyFocusRow(
              insights: _insights,
              loading: _loading,
              locale: locale.languageCode,
            ),
            const SizedBox(height: 18),
            _CosmicGuideCard(
              insights: _insights,
              loading: _loading,
              loc: loc,
            ),
          ],
        ),
      ),
    );
  }

}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.greeting,
    required this.date,
    required this.time,
  });

  final String greeting;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: theme.textTheme.displayLarge),
          const SizedBox(height: 8),
          Text(date, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(time, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.loading,
    required this.error,
    required this.report,
    required this.onRetry,
    required this.loc,
  });

  final bool loading;
  final String? error;
  final WeatherReport? report;
  final Future<void> Function() onRetry;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return _BlurCard(
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                loc.translate('loading'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _BlurCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('homeWeatherErrorTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(loc.translate('actionRetry')),
            ),
          ],
        ),
      );
    }

    final weather = report;
    if (weather == null) {
      return const SizedBox.shrink();
    }

    return _BlurCard(
      child: Row(
        children: [
          Text(
            weather.icon,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.toStringAsFixed(0)}°',
                  style: theme.textTheme.titleLarge,
                ),
                Text(weather.condition, style: theme.textTheme.bodyMedium),
                Text(weather.city, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyZodiacCard extends StatelessWidget {
  const _DailyZodiacCard({
    required this.loading,
    required this.error,
    required this.insights,
    required this.sun,
    required this.rising,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final DailyAiInsights? insights;
  final String sun;
  final String rising;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _BlurCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(loc.translate('homeDailyZodiac'),
                  style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('homeSunRising', params: {
              'sun': sun,
              'rising': rising,
            }),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (loading)
            const LinearProgressIndicator(minHeight: 3)
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('homeInsightError'),
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onRetry,
                  child: Text(loc.translate('actionRetry')),
                ),
              ],
            )
          else if (insights != null)
            Text(insights!.summary, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _EnergyFocusRow extends StatelessWidget {
  const _EnergyFocusRow({
    required this.insights,
    required this.loading,
    required this.locale,
  });

  final DailyAiInsights? insights;
  final bool loading;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final focusLabels = {
      'love': loc.translate('homeEnergyLove'),
      'career': loc.translate('homeEnergyCareer'),
      'spiritual': loc.translate('homeEnergySpiritual'),
      'social': loc.translate('homeEnergySocial'),
    };
    final items = focusLabels.keys.toList();
    return _BlurCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('homeEnergyFocusTitle'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (loading)
            const LinearProgressIndicator(minHeight: 3)
          else if (insights == null)
            Text(loc.translate('homeInsightEmpty'),
                style: theme.textTheme.bodyMedium)
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final key in items)
                  _EnergyChip(
                    label: focusLabels[key]!,
                    value: insights!.energyFocus[key] ?? '',
                    detail: insights!.sections[key] ?? '',
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EnergyChip extends StatelessWidget {
  const _EnergyChip({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        constraints: const BoxConstraints(minWidth: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(value.isNotEmpty ? value : '-',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Text(detail.isNotEmpty ? detail : '-',
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CosmicGuideCard extends StatelessWidget {
  const _CosmicGuideCard({
    required this.insights,
    required this.loading,
    required this.loc,
  });

  final DailyAiInsights? insights;
  final bool loading;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _BlurCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('homeCosmicGuideTitle'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (loading)
            const LinearProgressIndicator(minHeight: 3)
          else if (insights == null)
            Text(loc.translate('homeInsightEmpty'),
                style: theme.textTheme.bodyMedium)
          else
            Text(insights!.cosmicGuide, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _BlurCard extends StatelessWidget {
  const _BlurCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}
