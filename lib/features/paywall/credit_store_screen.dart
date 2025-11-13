import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../services/monetization/monetization_service.dart';
import 'upgrade_screen.dart';

class CreditStoreScreen extends StatefulWidget {
  const CreditStoreScreen({super.key});

  @override
  State<CreditStoreScreen> createState() => _CreditStoreScreenState();
}

class _CreditStoreScreenState extends State<CreditStoreScreen> {
  final MonetizationService _monetization = MonetizationService.instance;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.translate('creditsTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: theme.colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    loc.translate(
                      'creditsBalance',
                      params: {'credits': _monetization.credits.toString()},
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _CreditPack(
              amount: 20,
              price: loc.translate('creditsPrice20'),
              onPurchase: () => _handlePurchase(20),
              loading: _loading,
              theme: theme,
              loc: loc,
            ),
            const SizedBox(height: 16),
            _CreditPack(
              amount: 50,
              price: loc.translate('creditsPrice50'),
              onPurchase: () => _handlePurchase(50),
              loading: _loading,
              theme: theme,
              loc: loc,
              popular: true,
            ),
            const SizedBox(height: 16),
            _CreditPack(
              amount: 100,
              price: loc.translate('creditsPrice100'),
              onPurchase: () => _handlePurchase(100),
              loading: _loading,
              theme: theme,
              loc: loc,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UpgradeScreen()),
              ),
              icon: const Icon(Icons.star),
              label: Text(loc.translate('creditsUpgrade')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(int amount) async {
    setState(() => _loading = true);
    final loc = AppLocalizations.of(context);

    try {
      final success = await _monetization.purchaseCredits(amount);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('purchaseSuccess'))),
        );
        setState(() {});
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
}

class _CreditPack extends StatelessWidget {
  const _CreditPack({
    required this.amount,
    required this.price,
    required this.onPurchase,
    required this.loading,
    required this.theme,
    required this.loc,
    this.popular = false,
  });

  final int amount;
  final String price;
  final VoidCallback onPurchase;
  final bool loading;
  final ThemeData theme;
  final AppLocalizations loc;
  final bool popular;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: popular ? theme.colorScheme.primary : theme.dividerColor,
          width: popular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (popular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'POPULAR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (popular) const SizedBox(height: 8),
                      Text(
                        loc.translate('creditsPack$amount'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: loading ? null : onPurchase,
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(loc.translate('creditsBuy')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

