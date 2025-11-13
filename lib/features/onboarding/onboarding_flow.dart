import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;

import 'package:kismetly/services/weather_service.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/zodiac_signs.dart';
<<<<<<< Updated upstream
=======
import '../../services.dart' as services;
>>>>>>> Stashed changes
import '../../models/weather_report.dart';
import '../profile/user_profile.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onCompleted});

  final ValueChanged<UserProfile> onCompleted;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _genderController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _submitting = false;
  String? _error;
  Timer? _cityDebounce;
  _ResolvedLocation? _resolvedLocation;
  String? _resolvedQuery;
  WeatherReport? _weatherPreview;
  bool _weatherLoading = false;
  String? _weatherError;

  @override
  void dispose() {
    _cityDebounce?.cancel();
    _nameController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _begin() => setState(() => _step = 1);

  void _scheduleWeatherLookup(String value) {
    _cityDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _weatherPreview = null;
        _weatherError = null;
        _weatherLoading = false;
        _resolvedLocation = null;
        _resolvedQuery = null;
      });
      return;
    }

    _cityDebounce = Timer(const Duration(milliseconds: 650), () async {
      final location = await _resolveCity(trimmed);
      if (!mounted) return;
      if (location == null) {
        setState(() {
          _weatherLoading = false;
          _weatherPreview = null;
          _weatherError =
              AppLocalizations.of(context).translate('onboardingCityError');
          _resolvedLocation = null;
          _resolvedQuery = null;
        });
        return;
      }

      setState(() {
        _resolvedLocation = location;
        _resolvedQuery = trimmed.toLowerCase();
      });
      await _loadWeatherPreview(location);
    });
  }

  Future<void> _loadWeatherPreview(_ResolvedLocation location) async {
    if (!mounted) return;
    setState(() {
      _weatherLoading = true;
      _weatherError = null;
    });
    final locale = Localizations.localeOf(context);
    try {
      final report = await WeatherService().fetchWeather(
        city: location.city ?? _cityController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        localeCode: locale.languageCode,
      );
      if (!mounted) return;
      setState(() {
        _weatherPreview = report;
        _weatherLoading = false;
        _weatherError = report == null
            ? _localizedWeatherUnavailable(locale.languageCode)
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherLoading = false;
        _weatherError = e.toString();
      });
    }
  }

  Future<void> _refreshWeather() async {
    final location = _resolvedLocation;
    if (location == null) return;
    await _loadWeatherPreview(location);
  }

  String _localizedWeatherUnavailable(String languageCode) {
    return languageCode == 'tr'
        ? 'Hava verisi şu an alınamadı. Birkaç dakika sonra tekrar dene.'
        : 'Weather insight is taking a pause. Try again in a moment.';
  }

  String _contextualSalutation(Locale locale) {
    final greeting = _timeGreeting(locale);
    return locale.languageCode == 'tr'
        ? '$greeting • yolculuğuna kozmik bir dokunuş kat.'
        : '$greeting • let’s tune your cosmic path.';
  }

  String _timeGreeting(Locale locale) {
    final hour = DateTime.now().hour;
    if (locale.languageCode == 'tr') {
      if (hour < 12) return 'Günaydın';
      if (hour < 18) return 'İyi akşamüstü';
      return 'İyi akşamlar';
    }
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _birthTime = picked);
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _birthTime == null) {
      setState(() => _error = loc.translate('onboardingMissingDate'));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final cityInput = _cityController.text.trim();
      final normalized = cityInput.toLowerCase();
      var location = _resolvedLocation;
      final needsLookup = location == null ||
          _resolvedQuery == null ||
          _resolvedQuery != normalized;
      if (needsLookup) {
        location = await _resolveCity(cityInput);
      }
      if (location == null) {
        setState(() {
          _submitting = false;
          _error = loc.translate('onboardingCityError');
        });
        return;
      }
      final shouldFetchWeather = _weatherPreview == null ||
          _resolvedQuery == null ||
          _resolvedQuery != normalized;
      if (needsLookup && mounted) {
        setState(() {
          _resolvedLocation = location;
          _resolvedQuery = normalized;
        });
      }
      if (shouldFetchWeather) {
        await _loadWeatherPreview(location);
      }
      final birthDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );
      final sun = services.AstroService.sunSign(birthDateTime);
      final sunId = _signIdFromLabel(sun);
      final risingId = _estimateRising(
        birthTime:
            Duration(hours: _birthTime!.hour, minutes: _birthTime!.minute),
        longitude: location.longitude,
      );
      final profile = UserProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        birthTime:
            Duration(hours: _birthTime!.hour, minutes: _birthTime!.minute),
        birthCity: location.city ?? _cityController.text.trim(),
        birthLatitude: location.latitude,
        birthLongitude: location.longitude,
        gender: _genderController.text.trim().isEmpty
            ? null
            : _genderController.text.trim(),
        sunSign: sunId,
        risingSign: risingId,
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onCompleted(profile);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  Future<_ResolvedLocation?> _resolveCity(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.toLowerCase();
    if (_resolvedLocation != null && _resolvedQuery == normalized) {
      return _resolvedLocation;
    }
    try {
      final results = await geo.locationFromAddress(trimmed);
      if (results.isEmpty) return null;
      final loc = results.first;
      String? city;
      try {
        final placemarks = await geo.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (placemarks.isNotEmpty) {
          city =
              placemarks.first.locality ?? placemarks.first.administrativeArea;
        }
      } catch (_) {
        city = null;
      }
      return _ResolvedLocation(
        latitude: loc.latitude,
        longitude: loc.longitude,
        city: city,
      );
    } catch (_) {
      return null;
    }
  }

  String? _signIdFromLabel(String label) {
    final sign = zodiacSigns.firstWhere(
      (element) => element.labels.values.contains(label),
      orElse: () => zodiacSigns.first,
    );
    return sign.id;
  }

  String _estimateRising(
      {required Duration birthTime, required double longitude}) {
    final minutes = birthTime.inMinutes + longitude.round();
    final index = (minutes ~/ 120) % zodiacSigns.length;
    final normalized =
        (index % zodiacSigns.length + zodiacSigns.length) % zodiacSigns.length;
    return zodiacSigns[normalized].id;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    if (_step == 0) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('onboardingGreeting'),
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _contextualSalutation(locale),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(loc.translate('onboardingIntro'),
                  style: theme.textTheme.bodyLarge),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _begin,
                icon: const Icon(Icons.auto_awesome),
                label: Text(loc.translate('onboardingSignGoogle')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _begin,
                child: Text(loc.translate('onboardingContinueGuest')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('onboardingDetailsTitle')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('onboardingWelcome'),
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.translate('onboardingName'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? loc.translate('onboardingNameError')
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OutlineCard(
                      label: _birthDate == null
                          ? loc.translate('onboardingBirthDate')
                          : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlineCard(
                      label: _birthTime == null
                          ? loc.translate('onboardingBirthTime')
                          : _birthTime!.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: loc.translate('onboardingBirthCity'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? loc.translate('onboardingCityError')
                    : null,
                onChanged: _scheduleWeatherLookup,
              ),
              const SizedBox(height: 12),
              _WeatherPeek(
                loading: _weatherLoading,
                error: _weatherError,
                report: _weatherPreview,
                onRetry: _refreshWeather,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: loc.translate('onboardingGenderOptional'),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.translate('onboardingFinish')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResolvedLocation {
  const _ResolvedLocation({
    required this.latitude,
    required this.longitude,
    this.city,
  });

  final double latitude;
  final double longitude;
  final String? city;
}

class _WeatherPeek extends StatelessWidget {
  const _WeatherPeek({
    required this.loading,
    required this.error,
    required this.report,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final WeatherReport? report;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (!loading && error == null && report == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    Widget content;
    String keyLabel;
    if (loading) {
      content = Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.translate('loading'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      );
      keyLabel = 'loading';
    } else if (error != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('homeWeatherErrorTitle'),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            error!,
            style: theme.textTheme.bodySmall,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => onRetry(),
              child: Text(loc.translate('actionRetry')),
            ),
          ),
        ],
      );
      keyLabel = 'error';
    } else {
      final narrative = report?.narrative ?? '';
      final vibe = report?.vibeTag ?? '';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(report?.icon ?? '☀️', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(report?.temperature ?? 0).toStringAsFixed(0)}°',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(report?.condition ?? '',
                      style: theme.textTheme.bodyMedium),
                  Text(report?.city ?? '', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          if (vibe.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              vibe,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          if (narrative.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(narrative, style: theme.textTheme.bodySmall),
          ],
        ],
      );
      keyLabel = 'content';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(keyLabel),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: content,
      ),
    );
  }
}

class _OutlineCard extends StatelessWidget {
  const _OutlineCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(label, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
