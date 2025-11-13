import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import 'user_profile_scope.dart';
import 'user_profile.dart';
import '../../services/google_auth_service.dart';
import '../../services/location_autocomplete_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleAuthService _googleAuth = GoogleAuthService();
  final LocationAutocompleteService _autocompleteService = LocationAutocompleteService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _genderController = TextEditingController();
  final _layerLink = LayerLink();
  
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _profileImageUrl;
  bool _loading = false;
  bool _saving = false;
  List<LocationSuggestion> _citySuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _loading = true);
    
    try {
      final controller = UserProfileScope.of(context);
      final profile = controller.profile;
      final user = _googleAuth.currentUser;

      // Load from profile first
      if (profile != null) {
        _nameController.text = profile.name;
        _birthDate = profile.birthDate;
        _birthTime = TimeOfDay(
          hour: profile.birthTime.inHours,
          minute: profile.birthTime.inMinutes % 60,
        );
        _cityController.text = profile.birthCity;
        _genderController.text = profile.gender ?? '';
      }

      // Override with Google user data if available
      if (user != null) {
        _profileImageUrl = user.photoURL;
        if (_nameController.text.isEmpty && user.displayName != null) {
          _nameController.text = user.displayName!;
        }
        
        // Also try to load from Firestore as fallback
        try {
          final firestore = FirebaseFirestore.instance;
          final userDoc = await firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final data = userDoc.data();
            if (data != null) {
              if (_nameController.text.isEmpty && data['name'] != null) {
                _nameController.text = data['name'] as String;
              }
              if (_cityController.text.isEmpty && data['birthCity'] != null) {
                _cityController.text = data['birthCity'] as String;
              }
              if (_genderController.text.isEmpty && data['gender'] != null) {
                _genderController.text = data['gender'] as String;
              }
              if (_birthDate == null && data['birthDate'] != null) {
                final timestamp = data['birthDate'] as Timestamp;
                _birthDate = timestamp.toDate();
              }
              if (_birthTime == null && data['birthTime'] != null) {
                final minutes = data['birthTime'] as int;
                _birthTime = TimeOfDay(
                  hour: minutes ~/ 60,
                  minute: minutes % 60,
                );
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading from Firestore: $e');
          // Continue with existing data
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('profileLoadError') ?? 'Error loading profile')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      // TODO: Upload to Firebase Storage and update profile
      setState(() {
        _profileImageUrl = image.path;
      });
    }
  }

  Future<void> _searchCities(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _citySuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final suggestions = await _autocompleteService.search(query);
    if (mounted) {
      setState(() {
        _citySuggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    }
  }

  void _selectCity(LocationSuggestion suggestion) {
    setState(() {
      _cityController.text = suggestion.displayName;
      _showSuggestions = false;
      _citySuggestions = [];
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _birthTime = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _birthTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('onboardingMissingDate'))),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = UserProfileScope.of(context);
    
    // Resolve city location
    final location = await _autocompleteService.search(_cityController.text.trim());
    if (location.isEmpty) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('onboardingCityError'))),
      );
      return;
    }

    final suggestion = location.first;
    final profile = UserProfile(
      name: _nameController.text.trim(),
      birthDate: _birthDate!,
      birthTime: Duration(hours: _birthTime!.hour, minutes: _birthTime!.minute),
      birthCity: suggestion.city,
      birthLatitude: suggestion.latitude,
      birthLongitude: suggestion.longitude,
      gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
      sunSign: controller.profile?.sunSign,
      risingSign: controller.profile?.risingSign,
    );

    await controller.setProfile(profile);
    
    // Save to Firestore
    final user = _googleAuth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': profile.name,
        'birthDate': Timestamp.fromDate(profile.birthDate),
        'birthTime': profile.birthTime.inMinutes,
        'birthCity': profile.birthCity,
        'birthLatitude': profile.birthLatitude,
        'birthLongitude': profile.birthLongitude,
        'gender': profile.gender,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final user = _googleAuth.currentUser;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
          title: Text(loc.translate('menuSettings')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_showSuggestions) {
          setState(() => _showSuggestions = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.menu), onPressed: widget.onMenuTap),
          title: Text(loc.translate('menuSettings')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.dividerColor,
                        backgroundImage: _profileImageUrl != null
                            ? (_profileImageUrl!.startsWith('http')
                                ? NetworkImage(_profileImageUrl!)
                                : null)
                            : null,
                        child: _profileImageUrl == null || !_profileImageUrl!.startsWith('http')
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            onPressed: _pickImage,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // User Info from Google
                if (user != null) ...[
                  if (user.displayName != null)
                    Text(
                      user.displayName!,
                      style: theme.textTheme.titleLarge,
                    ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.email!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate('onboardingName'),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? loc.translate('onboardingNameError')
                      : null,
                ),
                const SizedBox(height: 24),
                // Birth Date & Time
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: theme.dividerColor, width: 1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthDate == null
                                    ? loc.translate('onboardingBirthDate')
                                    : DateFormat.yMd().format(_birthDate!),
                                style: theme.textTheme.bodyLarge,
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: theme.dividerColor, width: 1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _birthTime == null
                                    ? loc.translate('onboardingBirthTime')
                                    : _birthTime!.format(context),
                                style: theme.textTheme.bodyLarge,
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // City
                CompositedTransformTarget(
                  link: _layerLink,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: loc.translate('onboardingBirthCity'),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? loc.translate('onboardingCityError')
                        : null,
                    onChanged: _searchCities,
                  ),
                ),
                if (_showSuggestions && _citySuggestions.isNotEmpty)
                  CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: const Offset(0, 56),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _citySuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _citySuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(suggestion.displayName),
                              subtitle: suggestion.country != null
                                  ? Text(suggestion.country!)
                                  : null,
                              onTap: () => _selectCity(suggestion),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Gender
                TextFormField(
                  controller: _genderController,
                  decoration: InputDecoration(
                    labelText: loc.translate('onboardingGenderOptional'),
                  ),
                ),
                const SizedBox(height: 32),
                // Save Button
                ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

