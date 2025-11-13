import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/monetization/monetization_service.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final MonetizationService _monetization = MonetizationService.instance;
  bool _loading = false;
  bool _selectedAnnual = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.translate('premiumTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              loc.translate('premiumSubtitle'),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _FeatureList(loc: loc, theme: theme),
            const SizedBox(height: 32),
            _SubscriptionToggle(
              selectedAnnual: _selectedAnnual,
              onChanged: (value) => setState(() => _selectedAnnual = value),
              loc: loc,
              theme: theme,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : () => _handlePurchase(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      loc.translate('premiumUpgrade'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _handleRestore,
              child: Text(loc.translate('premiumRestore')),
            ),
            const SizedBox(height: 24),
            if (_monetization.isPremium && _monetization.premiumUntil != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.translate(
                          'premiumExpires',
                          params: {
                            'date': DateFormat.yMMMMd(locale.languageCode)
                                .format(_monetization.premiumUntil!),
                          },
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              loc.translate('paywallTerms'),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _loading = true);
    final loc = AppLocalizations.of(context);

    try {
      final success = _selectedAnnual
          ? await _monetization.purchaseProAnnual()
          : await _monetization.purchaseProMonthly();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('purchaseSuccess'))),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('purchaseError'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('purchaseError'))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _loading = true);
    final loc = AppLocalizations.of(context);

    try {
      await _monetization.refreshUserStatus();
      if (!mounted) return;

      if (_monetization.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('purchaseRestoreSuccess'))),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('purchaseRestoreError'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('purchaseRestoreError'))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({required this.loc, required this.theme});

  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final features = [
      loc.translate('premiumFeatureUnlimited'),
      loc.translate('premiumFeatureReports'),
      loc.translate('premiumFeatureCompatibility'),
      loc.translate('premiumFeatureAdFree'),
    ];

    return Column(
      children: features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(feature, style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          )).toList(),
    );
  }
}

class _SubscriptionToggle extends StatelessWidget {
  const _SubscriptionToggle({
    required this.selectedAnnual,
    required this.onChanged,
    required this.loc,
    required this.theme,
  });

  final bool selectedAnnual;
  final ValueChanged<bool> onChanged;
  final AppLocalizations loc;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !selectedAnnual
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.translate('premiumMonthly'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: !selectedAnnual ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('premiumPriceMonthly'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selectedAnnual
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.translate('premiumAnnual'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: selectedAnnual ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('premiumPriceAnnual'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

