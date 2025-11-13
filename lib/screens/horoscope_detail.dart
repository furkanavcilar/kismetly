import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/zodiac_signs.dart';
import '../features/comments/comments_section.dart';
import '../services/ai_content_service.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  const HoroscopeDetailScreen({super.key, required this.signId});

  final String signId;

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  final _aiService = AiContentService();
  String? _horoscope;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _horoscope == null) {
      _loadHoroscope();
    }
  }

  Future<void> _loadHoroscope() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final locale = LocaleScope.of(context).locale;
      final sign = findZodiacById(widget.signId);
      if (sign == null) {
        setState(() {
          _error = 'Sign not found';
          _loading = false;
        });
        return;
      }

      final signLabel = sign.labelFor(locale.languageCode);
      final today = DateTime.now();
      final horoscope = await _aiService.fetchDailyHoroscope(
        sign: signLabel,
        locale: locale,
        date: today,
        forceRefresh: true, // Always refresh for detail view
      );

      if (mounted) {
        setState(() {
          _horoscope = horoscope;
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
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final sign = findZodiacById(widget.signId);
    final language = locale.languageCode;
    final label = sign?.labelFor(language) ?? widget.signId;
    final formattedDate = DateFormat.yMMMMd(language).format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.translate('horoscopeDetailTitle', params: {'sign': label}) ?? label,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('errorConnection') ?? 'Connection error',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHoroscope,
                        child: Text(loc.translate('actionRetry')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHoroscope,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      if (_horoscope != null)
                        _InsightCard(
                          title: loc.translate('homeDailyEnergy') ?? 'Daily Horoscope',
                          message: _horoscope!,
                        ),
                      const SizedBox(height: 20),
                      CommentsSection(signId: widget.signId, signLabel: label),
                    ],
                  ),
                ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
