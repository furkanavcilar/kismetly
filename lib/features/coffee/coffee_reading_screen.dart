import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/ai_service.dart';

class CoffeeReadingScreen extends StatefulWidget {
  const CoffeeReadingScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<CoffeeReadingScreen> createState() => _CoffeeReadingScreenState();
}

class _CoffeeReadingScreenState extends State<CoffeeReadingScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();
  final List<XFile> _files = [];
  Map<String, String>? _result;
  bool _loading = false;
  String? _message;
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('coffee_history') ?? [];
    setState(() {
      _history = stored
          .map((entry) => Map<String, String>.from(jsonDecode(entry)))
          .toList();
    });
  }

  Future<void> _saveHistory(Map<String, String> result) async {
    final prefs = await SharedPreferences.getInstance();
    _history.insert(0, result);
    if (_history.length > 3) {
      _history = _history.sublist(0, 3);
    }
    final payload = _history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('coffee_history', payload);
  }

  Future<void> _pickImages() async {
    final loc = AppLocalizations.of(context);
    if (_files.length >= 3) {
      setState(() {
        _message = loc.translate('coffeeLimit');
      });
      return;
    }
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isEmpty) return;
    setState(() {
      _files
        ..addAll(picked.take(3 - _files.length))
        ..toList();
    });
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (_files.isEmpty) {
      setState(() {
        _message = loc.translate('coffeeEmpty');
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    final locale = LocaleScope.of(context).locale;
    final base64Images = <String>[];
    for (final file in _files) {
      final bytes = await file.readAsBytes();
      base64Images.add(base64Encode(bytes));
    }
    final result = await _aiService.interpretCoffee(
      imageBase64: base64Images,
      locale: locale,
    );
    setState(() {
      _result = result;
      _loading = false;
    });
    await _saveHistory(
        {...result, 'timestamp': DateTime.now().toIso8601String()});
    setState(() {
      _message = loc.translate('coffeeSaved');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formatter = DateFormat.yMMMMd(locale.languageCode);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('coffeeTitle')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('coffeeHint'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._files.map(
                  (file) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _CoffeePreview(file: file),
                  ),
                ),
                if (_files.length < 3)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
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
                          Text(loc.translate('coffeeLoading')),
                        ],
                      )
                    : Text(loc.translate('coffeeSubmit')),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_result != null)
              _CoffeeResultCard(
                result: _result!,
              ),
            const SizedBox(height: 24),
            Text(
              loc.translate('coffeeHistory'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              Text(
                loc.translate('coffeeHistoryEmpty'),
                style: theme.textTheme.bodySmall,
              )
            else
              ..._history.map(
                (entry) => Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry['timestamp'] != null)
                          Text(
                            formatter
                                .format(DateTime.parse(entry['timestamp']!)),
                            style: theme.textTheme.labelMedium,
                          ),
                        const SizedBox(height: 6),
                        Text(entry['general'] ?? ''),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              loc.translate('coffeePrivacy'),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoffeePreview extends StatelessWidget {
  const _CoffeePreview({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }
    return Image.file(
      File(file.path),
      width: 90,
      height: 90,
      fit: BoxFit.cover,
    );
  }
}

class _CoffeeResultCard extends StatelessWidget {
  const _CoffeeResultCard({required this.result});

  final Map<String, String> result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResultSection(
              icon: '✨',
              title: loc.translate('coffeeResultGeneral'),
              text: result['general'] ?? '',
            ),
            _ResultSection(
              icon: '❤️',
              title: loc.translate('coffeeResultLove'),
              text: result['love'] ?? '',
            ),
            _ResultSection(
              icon: '💼',
              title: loc.translate('coffeeResultCareer'),
              text: result['career'] ?? '',
            ),
            _ResultSection(
              icon: '⚠️',
              title: loc.translate('coffeeResultWarnings'),
              text: result['warnings'] ?? '',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.icon,
    required this.title,
    required this.text,
  });

  final String icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$icon  $title', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
