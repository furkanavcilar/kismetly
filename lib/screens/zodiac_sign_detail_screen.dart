import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../data/zodiac_signs.dart';
import '../services/ai_content_service.dart';

class ZodiacSignDetailScreen extends StatefulWidget {
  const ZodiacSignDetailScreen({super.key, required this.signId});

  final String signId;

  @override
  State<ZodiacSignDetailScreen> createState() => _ZodiacSignDetailScreenState();
}

class _ZodiacSignDetailScreenState extends State<ZodiacSignDetailScreen> {
  final _aiService = AiContentService();
  Map<String, String>? _details;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading && _details == null) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final locale = LocaleScope.of(context).locale;
      final sign = findZodiacById(widget.signId);
      if (sign == null) {
        setState(() {
          _error = 'Sign not found';
          _loading = false;
        });
        return;
      }

      final signLabel = sign.labelFor(locale.languageCode);
      final details = await _aiService.fetchZodiacSignDetails(
        sign: signLabel,
        locale: locale,
      );

      if (mounted) {
        setState(() {
          _details = details;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final sign = findZodiacById(widget.signId);
    final signLabel = sign?.labelFor(locale.languageCode) ?? widget.signId;

    return Scaffold(
      appBar: AppBar(
        title: Text(signLabel),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('errorConnection') ?? 'Connection error',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate('errorConnectionDesc') ?? 'Please check your internet connection',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDetails,
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sign?.emoji != null) ...[
                        Center(
                          child: Text(
                            sign!.emoji!,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_details != null) ...[
                        _DetailSection(
                          title: loc.translate('zodiacTraits') ?? 'Genel Özellikler',
                          content: _details!['traits'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacStrengths') ?? 'Güçlü Yönler',
                          content: _details!['strengths'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacChallenges') ?? 'Zorluklar',
                          content: _details!['challenges'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacLove') ?? 'Aşk & İlişkiler',
                          content: _details!['love'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacCareer') ?? 'Kariyer & Para',
                          content: _details!['career'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacEmotional') ?? 'Duygusal Manzara',
                          content: _details!['emotional'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacSpiritual') ?? 'Ruhsal Yolculuk',
                          content: _details!['spiritual'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        _DetailSection(
                          title: loc.translate('zodiacThemes') ?? 'Bu Ayın Teması',
                          content: _details!['themes'] ?? '',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

