import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../core/localization/app_localizations.dart';
import '../../data/zodiac_signs.dart';
import '../../services.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _begin() => setState(() => _step = 1);

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
      final location = await _resolveCity(_cityController.text.trim());
      if (location == null) {
        setState(() {
          _submitting = false;
          _error = loc.translate('onboardingCityError');
        });
        return;
      }
      final birthDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );
      final sun = AstroService.sunSign(birthDateTime);
      final sunId = _signIdFromLabel(sun);
      final risingId = _estimateRising(
        birthTime: Duration(hours: _birthTime!.hour, minutes: _birthTime!.minute),
        longitude: location.longitude,
      );
      final profile = UserProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        birthTime: Duration(hours: _birthTime!.hour, minutes: _birthTime!.minute),
        birthCity: location.city ?? _cityController.text.trim(),
        birthLatitude: location.latitude,
        birthLongitude: location.longitude,
        gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
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
    if (input.isEmpty) return null;
    try {
      final results = await geo.locationFromAddress(input);
      if (results.isEmpty) return null;
      final loc = results.first;
      String? city;
      try {
        final placemarks = await geo.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (placemarks.isNotEmpty) {
          city = placemarks.first.locality ?? placemarks.first.administrativeArea;
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

  String _estimateRising({required Duration birthTime, required double longitude}) {
    final minutes = birthTime.inMinutes + longitude.round();
    final index = (minutes ~/ 120) % zodiacSigns.length;
    final normalized = (index % zodiacSigns.length + zodiacSigns.length) % zodiacSigns.length;
    return zodiacSigns[normalized].id;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (_step == 0) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('onboardingGreeting'), style: theme.textTheme.displayMedium),
              const SizedBox(height: 24),
              Text(loc.translate('onboardingIntro'), style: theme.textTheme.bodyLarge),
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
              Text(loc.translate('onboardingWelcome'), style: theme.textTheme.titleLarge),
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
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
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
