import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../core/utils/locale_collator.dart';
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
    // Don't call context-dependent code in initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _horoscopes.isEmpty) {
      _loadHoroscopes();
    }
  }

  Future<void> _loadHoroscopes() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null; // Clear error immediately when retrying
    });

    try {
      final locale = LocaleScope.of(context).locale;
      final today = DateTime.now();
      
      // Load horoscopes for all signs - always fetch fresh from AI
      final horoscopes = <String, String>{};
      final sortedSigns = _getSortedSigns(locale);
      
      // Load in parallel for better performance
      final futures = sortedSigns.map((sign) async {
        try {
          final label = sign.labelFor(locale.languageCode);
          // Always fetch fresh from AI - no cache for list view
          final horoscope = await _aiService.fetchDailyHoroscope(
            sign: label,
            locale: locale,
            date: today,
            forceRefresh: true, // Always refresh for the list
          );
          return MapEntry(sign.id, horoscope.isNotEmpty 
              ? horoscope 
              : _getFallbackHoroscope(sign.id, locale.languageCode));
        } catch (e) {
          debugPrint('Error loading horoscope for ${sign.id}: $e');
          // If generation fails, use a fallback
          return MapEntry(sign.id, _getFallbackHoroscope(sign.id, locale.languageCode));
        }
      });
      
      final results = await Future.wait(futures);
      for (final entry in results) {
        horoscopes[entry.key] = entry.value;
      }

      if (mounted) {
        setState(() {
          _horoscopes = horoscopes;
          _loading = false;
          _error = null; // Ensure error is cleared on success
        });
      }
    } catch (e) {
      debugPrint('Error in _loadHoroscopes: $e');
      if (mounted) {
        setState(() {
          _error = null; // Don't show technical error, just show retry option
          _loading = false;
        });
      }
    }
  }

  List<ZodiacSign> _getSortedSigns(Locale locale) {
    final collator = const LocaleCollator();
    final sorted = [...zodiacSigns];
    sorted.sort((a, b) {
      final labelA = a.labelFor(locale.languageCode);
      final labelB = b.labelFor(locale.languageCode);
      return collator.compare(labelA, labelB, locale);
    });
    return sorted;
  }

  String _extractPreview(String fullText) {
    if (fullText.isEmpty) return '';
    // Extract first 2-3 sentences
    final sentences = fullText.split(RegExp(r'[.!?]\s+'));
    if (sentences.length <= 2) return fullText;
    return sentences.take(2).join('. ') + '.';
  }

  String _getFallbackHoroscope(String signId, String language) {
    // DO NOT return static astrology text - show loading/error message instead
    if (language == 'tr') {
      return 'Şu anda $signId burcu için yorum yükleniyor...';
    }
    return 'Loading horoscope for $signId sign...';
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
          : _horoscopes.isEmpty && !_loading
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
                      onRefresh: () async {
                        // Clear existing horoscopes to force fresh load
                        setState(() {
                          _horoscopes = {};
                        });
                        await _loadHoroscopes();
                      },
                      child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        formattedDate,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ..._getSortedSigns(locale).map((sign) {
                        final signLabel = sign.labelFor(locale.languageCode);
                        final horoscope = _horoscopes[sign.id] ?? '';
                        // Extract first 2-3 sentences for preview
                        final preview = _extractPreview(horoscope);
                        return _HoroscopeListItem(
                          sign: sign,
                          signLabel: signLabel,
                          horoscope: preview,
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

