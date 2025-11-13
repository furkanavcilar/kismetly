import 'package:flutter/widgets.dart';

import 'user_profile_controller.dart';

class UserProfileScope extends InheritedNotifier<UserProfileController> {
  const UserProfileScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static UserProfileController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserProfileScope>();
    assert(scope != null, 'UserProfileScope not found in context');
    return scope!.notifier!;
  }
}
