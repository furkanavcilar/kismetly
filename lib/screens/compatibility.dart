import 'package:flutter/material.dart';

import '../services.dart';

class ZodiacCompatibilityScreen extends StatefulWidget {
  const ZodiacCompatibilityScreen({
    super.key,
    required this.onMenuTap,
  });

  final VoidCallback onMenuTap;

  @override
  State<ZodiacCompatibilityScreen> createState() =>
      _ZodiacCompatibilityScreenState();
}

class _ZodiacCompatibilityScreenState extends State<ZodiacCompatibilityScreen>
    with SingleTickerProviderStateMixin {
  late final List<String> _signs = AstroService.signs;
  late String _firstSign = _signs.first;
  late String _secondSign = _signs[5];
  late CompatibilityReport _report =
      AstroService.compatibility(_firstSign, _secondSign);

  void _updateReport(String first, String second) {
    setState(() {
      _firstSign = first;
      _secondSign = second;
      _report = AstroService.compatibility(first, second);
    });
  }

  void _swapSigns() => _updateReport(_secondSign, _firstSign);

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF111111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onMenuTap,
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Menü',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Zodyak Uyumu', style: th.titleLarge),
                        Text(
                          'Aşk, arkadaşlık ve ekip enerjilerini keşfet',
                          style:
                              th.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _swapSigns,
                    tooltip: 'Burçları değiştir',
                    icon: const Icon(Icons.swap_horiz, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScoreCard(report: _report, first: _firstSign, second: _secondSign),
                    const SizedBox(height: 20),
                    _SignSelector(
                      signs: _signs,
                      first: _firstSign,
                      second: _secondSign,
                      onChanged: _updateReport,
                    ),
                    const SizedBox(height: 24),
                    _AstroGames(
                      onSelect: (a, b) => _updateReport(a, b),
                    ),
                    const SizedBox(height: 24),
                    _InsightPanel(report: _report),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.report,
    required this.first,
    required this.second,
  });

  final CompatibilityReport report;
  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    final percent = (report.score * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$first × $second', style: th.titleMedium),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    report.tone,
                    key: ValueKey(report.tone),
                    style: th.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    report.summary,
                    key: ValueKey(report.summary),
                    style: th.bodySmall?.copyWith(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            height: 94,
            width: 94,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: report.score),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6,
                        color: Colors.amberAccent,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Text('$percent%', style: th.titleLarge),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SignSelector extends StatelessWidget {
  const _SignSelector({
    required this.signs,
    required this.first,
    required this.second,
    required this.onChanged,
  });

  final List<String> signs;
  final String first;
  final String second;
  final void Function(String, String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SignDropdown(
            signs: signs,
            value: first,
            label: 'Sen',
            onChanged: (v) => onChanged(v, second),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SignDropdown(
            signs: signs,
            value: second,
            label: 'Partner',
            onChanged: (v) => onChanged(first, v),
          ),
        ),
      ],
    );
  }
}

class _SignDropdown extends StatelessWidget {
  const _SignDropdown({
    required this.signs,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final List<String> signs;
  final String value;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: th.bodySmall?.copyWith(color: Colors.white60)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
            color: Colors.white.withOpacity(0.05),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.black,
            icon: const Icon(Icons.expand_more, color: Colors.white70),
            underline: const SizedBox.shrink(),
            style: th.titleMedium,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            items: [
              for (final sign in signs)
                DropdownMenuItem(
                  value: sign,
                  child: Text(sign),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AstroGames extends StatelessWidget {
  const _AstroGames({required this.onSelect});

  final void Function(String, String) onSelect;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    final prompts = <({String label, String first, String second})>[
      (label: 'Karşıt burç uyumu', first: 'Koç', second: 'Terazi'),
      (label: 'Element dengesi', first: 'Boğa', second: 'Başak'),
      (label: 'Sürpriz ikili', first: 'Kova', second: 'Yengeç'),
      (label: 'Tutkulu eşleşme', first: 'Aslan', second: 'Akrep'),
      (label: 'Macera dostları', first: 'Yay', second: 'İkizler'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Astroloji oyunları', style: th.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Hızlı kombinasyonlara dokun; ilişkilerin enerjisini keşfet.',
            style: th.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (final prompt in prompts)
                ActionChip(
                  label: Text(prompt.label),
                  labelStyle: th.labelLarge?.copyWith(color: Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.08),
                  onPressed: () => onSelect(prompt.first, prompt.second),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.report});

  final CompatibilityReport report;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uyum öngörüleri', style: th.titleMedium),
          const SizedBox(height: 12),
          for (final highlight in report.highlights)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        highlight,
                        key: ValueKey(highlight),
                        style: th.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
