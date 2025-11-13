import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/horoscope_insights_en.dart';
import '../data/horoscope_insights_tr.dart';
import '../data/zodiac_signs.dart';
import '../features/comments/comments_section.dart';

class HoroscopeDetailScreen extends StatelessWidget {
  const HoroscopeDetailScreen({super.key, required this.signId});

  final String signId;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final sign = findZodiacById(signId);
    final language = locale.languageCode;
    final label = sign?.labelFor(language) ?? signId;
    final date = DateTime.now();
    final sunMessage = language == 'en'
        ? sunInsightForEn(signId, date)
        : sunInsightForTr(signId, date);
    final risingMessage = language == 'en'
        ? risingInsightForEn(signId, date)
        : risingInsightForTr(signId, date);
    final safeSun =
        sunMessage.isEmpty ? loc.translate('insightSunDefault') : sunMessage;
    final safeRising = risingMessage.isEmpty
        ? loc.translate('insightRisingDefault')
        : risingMessage;
    final formattedDate = DateFormat.yMMMMd(language).format(date);
    return Scaffold(
      appBar: AppBar(
          title: Text(
              loc.translate('horoscopeDetailTitle', params: {'sign': label}))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(formattedDate, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 12),
          _InsightCard(
            title: loc.translate('homeDailyEnergy'),
            message: safeSun,
          ),
          _InsightCard(
            title: loc.translate('homeDailyCardTitle'),
            message: safeRising,
          ),
          const SizedBox(height: 20),
          CommentsSection(signId: signId, signLabel: label),
        ],
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
