import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/onboarding_flow.dart';
import 'features/profile/user_profile_controller.dart';
import 'features/profile/user_profile_scope.dart';
import 'features/profile/user_profile_storage.dart';
import 'features/profile/user_profile.dart';
import 'main_shell.dart';
import 'services/monetization/monetization_service.dart';
import 'services/notification_service.dart';

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({super.key});

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  UserProfileController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize monetization service in parallel with profile loading
    final prefs = await SharedPreferences.getInstance();
    final storage = UserProfileStorage(prefs);
    final profile = storage.load();
    
    // Initialize monetization service (non-blocking for UI)
    MonetizationService.instance.init().catchError((e) {
      debugPrint('MonetizationService init error: $e');
    });

    // Initialize notifications (non-blocking)
    NotificationService().initialize().then((_) async {
      // Check if permission granted before scheduling
      final granted = await NotificationService().requestPermission();
      if (granted) {
        // Schedule notifications if enabled
        NotificationService().scheduleDailyHoroscope().catchError((e) {
          debugPrint('Error scheduling daily horoscope: $e');
        });
        NotificationService().scheduleNightlyMotivation().catchError((e) {
          debugPrint('Error scheduling nightly motivation: $e');
        });
      } else {
        debugPrint('NotificationService - Permission not granted, skipping scheduling');
      }
    }).catchError((e) {
      debugPrint('NotificationService init error: $e');
    });
    
    if (!mounted) return;
    setState(() {
      _controller = UserProfileController(storage, profile);
      _loading = false;
    });
  }

  Future<void> _completeProfile(UserProfile profile) async {
    debugPrint('Onboarding completed: $profile');
    final controller = _controller;
    if (controller == null) {
      debugPrint('AppBootstrapper._completeProfile() - Controller is null!');
      return;
    }
    await controller.setProfile(profile);
    debugPrint('AppBootstrapper._completeProfile() - Profile saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = _controller!;
    debugPrint('AppBootstrapper.build() - Profile: ${controller.profile}');
    
    return UserProfileScope(
      notifier: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final profile = controller.profile;
          debugPrint('AppBootstrapper.build() - Profile at build(): $profile');
          
          if (profile == null) {
            return OnboardingFlow(onCompleted: _completeProfile);
          }
          
          return const MainShell();
        },
      ),
    );
  }
}
