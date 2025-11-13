import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../services/monetization/monetization_service.dart';
import 'credit_store_screen.dart';
import 'upgrade_screen.dart';

class PremiumLockWidget extends StatelessWidget {
  const PremiumLockWidget({
    super.key,
    required this.child,
    this.message,
    this.creditCost,
  });

  final Widget child;
  final String? message;
  final int? creditCost;

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationService.instance;
    final loc = AppLocalizations.of(context);

    if (creditCost != null) {
      final canAfford = monetization.canAfford(creditCost!);
      if (canAfford) {
        return child;
      }
      return _LockedContent(
        message: message ?? loc.translate('lockCredits', params: {'amount': creditCost.toString()}),
        onUnlock: () => _showCreditModal(context, creditCost!),
        child: child,
      );
    }

    if (monetization.isPremium) {
      return child;
    }

    return _LockedContent(
      message: message ?? loc.translate('lockPremium'),
      onUnlock: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UpgradeScreen()),
      ),
      child: child,
    );
  }

  void _showCreditModal(BuildContext context, int cost) {
    final monetization = MonetizationService.instance;
    final loc = AppLocalizations.of(context);
    final credits = monetization.credits;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('creditsInsufficient'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              loc.translate('creditsNeeded', params: {'amount': cost.toString()}),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('creditsBalance', params: {'credits': credits.toString()}),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreditStoreScreen()),
                      );
                    },
                    child: Text(loc.translate('creditsBuy')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                      );
                    },
                    child: Text(loc.translate('creditsUpgrade')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedContent extends StatelessWidget {
  const _LockedContent({
    required this.message,
    required this.onUnlock,
    required this.child,
  });

  final String message;
  final VoidCallback onUnlock;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: child,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.star),
                  label: Text(AppLocalizations.of(context).translate('lockUpgrade')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

