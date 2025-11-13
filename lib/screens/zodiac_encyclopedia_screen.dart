import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/zodiac_signs.dart';
import 'zodiac_sign_detail_screen.dart';

class ZodiacEncyclopediaScreen extends StatelessWidget {
  const ZodiacEncyclopediaScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
        title: Text(loc.translate('menuZodiac')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...zodiacSigns.map((sign) {
            final signLabel = sign.labelFor(locale.languageCode);
            return _ZodiacListItem(
              sign: sign,
              signLabel: signLabel,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ZodiacSignDetailScreen(signId: sign.id),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _ZodiacListItem extends StatelessWidget {
  const _ZodiacListItem({
    required this.sign,
    required this.signLabel,
    required this.onTap,
  });

  final ZodiacSign sign;
  final String signLabel;
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
        child: Row(
          children: [
            Text(
              sign.emoji ?? '✨',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (sign.dateRange != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      sign.dateRange!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

