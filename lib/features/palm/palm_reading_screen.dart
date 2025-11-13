import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/widgets/unicode_text_field.dart';
import '../../services/ai_service.dart';
import '../../services/daily_limits_service.dart';
import '../../services/monetization/monetization_service.dart';
import '../../features/paywall/upgrade_screen.dart';

class PalmReadingScreen extends StatefulWidget {
  const PalmReadingScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<PalmReadingScreen> createState() => _PalmReadingScreenState();
}

class _PalmReadingScreenState extends State<PalmReadingScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();
  final DailyLimitsService _dailyLimits = DailyLimitsService();
  XFile? _palmImage;
  String? _result;
  bool _loading = false;
  String? _error;
  bool _canUseFree = true;

  @override
  void initState() {
    super.initState();
    _checkDailyLimit();
  }

  Future<void> _checkDailyLimit() async {
    final canUse = await _dailyLimits.canUseFeature('palm');
    if (mounted) {
      setState(() => _canUseFree = canUse);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      setState(() {
        _palmImage = picked;
        _result = null;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    final monetization = MonetizationService.instance;

    if (_palmImage == null) {
      setState(() {
        _error = loc.translate('palmNoImage') ?? 'Please select a palm image';
      });
      return;
    }

    // Check daily free limit
    if (!_canUseFree && !monetization.isPremium) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UpgradeScreen()),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Record usage if free
    if (_canUseFree && !monetization.isPremium) {
      await _dailyLimits.recordFeatureUse('palm');
      setState(() => _canUseFree = false);
    }

    try {
      final locale = LocaleScope.of(context).locale;
      final bytes = await _palmImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final reading = await _aiService.interpretPalm(
        imageBase64: base64Image,
        locale: locale,
      );

      if (mounted) {
        setState(() {
          _result = reading;
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('menuPalmistry')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('palmDescription') ??
                  'Avuç içi fotoğrafınızı yükleyin ve karakter özelliklerinizi, duygusal desenlerinizi ve potansiyel yaşam yollarınızı keşfedin.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_palmImage != null)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Image.file(
                  File(_palmImage!.path),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.front_hand,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('palmNoImage') ?? 'No image selected',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(loc.translate('palmPickGallery') ?? 'Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(loc.translate('palmPickCamera') ?? 'Camera'),
                  ),
                ),
              ],
            ),
            if (!_canUseFree && !MonetizationService.instance.isPremium) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.translate('palmDailyLimit') ??
                            'Daily free limit reached. Upgrade to Pro for unlimited access.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_loading || _palmImage == null) ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(loc.translate('palmRead') ?? 'Read My Palm'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              Text(
                loc.translate('palmReading') ?? 'Your Palm Reading',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                _result!,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

