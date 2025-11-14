import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../../services/monetization/monetization_service.dart';

/// Premium dialog shown when usage limit is exceeded
/// 
/// Displays localized message and options to upgrade or dismiss
class PremiumDialog extends StatelessWidget {
  const PremiumDialog({
    super.key,
    this.onUpgrade,
    this.onDismiss,
  });

  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        loc.translate('usageLimitExceeded') ?? 'Daily Limit Reached',
        style: theme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('usageLimitMessage') ??
                'You\'ve reached your daily free limit. Upgrade to Pro for unlimited access.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('usageLimitBenefits') ??
                'Pro features:\n• Unlimited AI readings\n• Detailed reports\n• Ad-free experience',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (onDismiss != null) {
              onDismiss!();
            }
            Navigator.of(context).pop();
          },
          child: Text(loc.translate('actionDismiss') ?? 'Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            if (onUpgrade != null) {
              onUpgrade!();
            } else {
              // Default: Navigate to paywall or settings
              Navigator.of(context).pop();
              // TODO: Navigate to paywall screen
            }
            Navigator.of(context).pop();
          },
          child: Text(loc.translate('actionUpgrade') ?? 'Upgrade to Pro'),
        ),
      ],
    );
  }

  /// Show premium dialog
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onUpgrade,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PremiumDialog(
        onUpgrade: onUpgrade,
        onDismiss: onDismiss,
      ),
    );
  }
}

