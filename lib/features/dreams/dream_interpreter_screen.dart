import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/ai_service.dart';

class DreamInterpreterScreen extends StatefulWidget {
  const DreamInterpreterScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<DreamInterpreterScreen> createState() => _DreamInterpreterScreenState();
}

class _DreamInterpreterScreenState extends State<DreamInterpreterScreen> {
  final _controller = TextEditingController();
  final _aiService = AiService();
  String? _result;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final loc = AppLocalizations.of(context);
    if (text.isEmpty) {
      setState(() => _error = loc.translate('dreamEmpty'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final locale = LocaleScope.of(context).locale;
    final response = await _aiService.interpretDream(
      prompt: text,
      locale: locale,
    );
    setState(() {
      _loading = false;
      _result = response;
      if (response.isEmpty) {
        _error = loc.translate('dreamError');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formatted = DateFormat.yMMMMd(locale.languageCode).format(DateTime.now());
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('dreamTitle')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatted,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 8,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: loc.translate('dreamHint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(loc.translate('dreamLoading')),
                        ],
                      )
                    : Text(loc.translate('dreamSubmit')),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _result == null
                    ? Center(
                        child: Text(
                          loc.translate('dreamEmpty'),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SingleChildScrollView(
                        key: ValueKey(_result),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            _result!,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
