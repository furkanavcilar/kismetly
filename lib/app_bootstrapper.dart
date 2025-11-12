import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/onboarding_flow.dart';
import 'features/profile/user_profile_controller.dart';
import 'features/profile/user_profile_scope.dart';
import 'features/profile/user_profile_storage.dart';
import 'features/profile/user_profile.dart';
import 'main_shell.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final storage = UserProfileStorage(prefs);
    final profile = storage.load();
    setState(() {
      _controller = UserProfileController(storage, profile);
      _loading = false;
    });
  }

  Future<void> _completeProfile(UserProfile profile) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = _controller!;
    return UserProfileScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final profile = controller.profile;
          if (profile == null) {
            return OnboardingFlow(onCompleted: _completeProfile);
          }
          return const MainShell();
        },
      ),
    );
  }
}
