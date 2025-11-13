import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/zodiac_signs.dart';
import '../services/ai_content_service.dart';
import 'horoscope_detail.dart';

class HoroscopesListScreen extends StatefulWidget {
  const HoroscopesListScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<HoroscopesListScreen> createState() => _HoroscopesListScreenState();
}

class _HoroscopesListScreenState extends State<HoroscopesListScreen> {
  final _aiService = AiContentService();
  Map<String, String> _horoscopes = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHoroscopes();
  }

  Future<void> _loadHoroscopes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final locale = LocaleScope.of(context).locale;
      final today = DateTime.now();
      
      // Load horoscopes for all signs
      final horoscopes = <String, String>{};
      for (final sign in zodiacSigns) {
        try {
          final label = sign.labelFor(locale.languageCode);
          // Generate today's horoscope for this sign
          final horoscope = await _aiService.fetchDailyHoroscope(
            sign: label,
            locale: locale,
            date: today,
          );
          horoscopes[sign.id] = horoscope;
        } catch (e) {
          // If generation fails, use a fallback
          horoscopes[sign.id] = _getFallbackHoroscope(sign.id, locale.languageCode);
        }
      }

      if (mounted) {
        setState(() {
          _horoscopes = horoscopes;
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

  String _getFallbackHoroscope(String signId, String language) {
    // Simple fallback - in production, these would be more varied
    if (language == 'tr') {
      return 'Bugün kozmik enerjiler senin lehine çalışıyor. İç sesine güven ve adımlarını cesaretle at.';
    }
    return 'Today cosmic energies are working in your favor. Trust your inner voice and take steps with courage.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formattedDate = DateFormat.yMMMMd(locale.languageCode).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('menuHoroscopes')),
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
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadHoroscopes,
                        child: Text(loc.translate('actionRetry')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHoroscopes,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        formattedDate,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ...zodiacSigns.map((sign) {
                        final signLabel = sign.labelFor(locale.languageCode);
                        final horoscope = _horoscopes[sign.id] ?? '';
                        return _HoroscopeListItem(
                          sign: sign,
                          signLabel: signLabel,
                          horoscope: horoscope,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HoroscopeDetailScreen(signId: sign.id),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}

class _HoroscopeListItem extends StatelessWidget {
  const _HoroscopeListItem({
    required this.sign,
    required this.signLabel,
    required this.horoscope,
    required this.onTap,
  });

  final ZodiacSign sign;
  final String signLabel;
  final String horoscope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  sign.emoji ?? '✨',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    signLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              horoscope,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

