import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/locale_collator.dart';
import '../data/zodiac_signs.dart';
import '../services/ai_content_service.dart';

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
  final _aiService = AiContentService();
  Map<String, String>? _insights;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _firstSign = zodiacSigns.first.id;
    _secondSign = zodiacSigns.last.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
    _load(forceRefresh: true);
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final locale = LocaleScope.of(context).locale;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      String label(String id) {
        final sign = findZodiacById(id);
        return sign.labelFor(locale.languageCode);
      }

      final result = await _aiService.fetchCompatibility(
        firstSign: label(_firstSign),
        secondSign: label(_secondSign),
        locale: locale,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _insights = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final language = locale.languageCode;
    final collator = const LocaleCollator();
    final sorted = [...zodiacSigns]
      ..sort((a, b) => collator.compare(a.labelFor(language), b.labelFor(language), locale));
    final firstLabel = findZodiacById(_firstSign)?.labelFor(language) ?? _firstSign;
    final secondLabel = findZodiacById(_secondSign)?.labelFor(language) ?? _secondSign;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
        title: Text(loc.translate('compatibilityTitle')),
        actions: [
          IconButton(icon: const Icon(Icons.swap_horiz), onPressed: _swap),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: locale.languageCode == 'tr' ? 'Yeni yorum' : 'New reading',
            onPressed: () => _load(forceRefresh: true),
          ),
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
              onChanged: (a, b) {
                setState(() {
                  _firstSign = a;
                  _secondSign = b;
                });
                _load(forceRefresh: true);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _InsightSummary(
              loading: _loading,
              error: _error,
              summary: _insights?['summary'],
              first: firstLabel,
              second: secondLabel,
              onRetry: _load,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CompatibilityTab(
                  label: loc.translate('compatibilityLove'),
                  summary: _insights?['love'] ?? '',
                  loading: _loading,
                ),
                _CompatibilityTab(
                  label: loc.translate('compatibilityFamily'),
                  summary: _insights?['family'] ?? '',
                  loading: _loading,
                ),
                _CompatibilityTab(
                  label: loc.translate('compatibilityCareer'),
                  summary: _insights?['career'] ?? '',
                  loading: _loading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignSelector extends StatelessWidget {
  const _SignSelector({
    super.key,
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

class _InsightSummary extends StatelessWidget {
  const _InsightSummary({
    required this.loading,
    required this.error,
    required this.summary,
    required this.first,
    required this.second,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final String? summary;
  final String first;
  final String second;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(loc.translate('compatibilityErrorTitle'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(loc.translate('actionRetry'))),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Chip(label: Text(first)),
            Chip(label: Text(second)),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: summary != null && summary!.isNotEmpty
              ? Text(
                  summary!,
                  key: ValueKey(summary),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                )
              : Text(
                  loc.translate('compatibilityEmpty'),
                  key: const ValueKey('empty'),
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ],
    );
  }
}

class _CompatibilityTab extends StatelessWidget {
  const _CompatibilityTab({
    required this.label,
    required this.summary,
    required this.loading,
  });

  final String label;
  final String summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: summary.trim().isNotEmpty
                      ? Text(
                          summary,
                          key: ValueKey(summary),
                          style: theme.textTheme.bodyLarge,
                        )
                      : Text(
                          loc.translate('compatibilityEmpty'),
                          key: const ValueKey('tab-empty'),
                          style: theme.textTheme.bodyMedium,
                        ),
                ),
              ],
            ),
    );
  }
}
