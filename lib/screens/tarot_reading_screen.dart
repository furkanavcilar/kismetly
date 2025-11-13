import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';

class TarotReadingScreen extends StatelessWidget {
  const TarotReadingScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
        title: Text(loc.translate('menuTarot')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.style,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                loc.translate('tarotTitle') ?? 'Tarot Falı',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.translate('tarotDescription') ??
                    'Kartlarını seç ve kozmik rehberliğini keşfet.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement tarot card selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.translate('tarotComingSoon') ??
                          'Yakında gelecek...'),
                    ),
                  );
                },
                child: Text(loc.translate('tarotDrawCards') ?? 'Kartlarını Seç'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

