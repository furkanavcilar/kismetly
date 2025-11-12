import 'package:flutter/foundation.dart';

import 'user_profile.dart';
import 'user_profile_storage.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController(this._storage, [UserProfile? initial])
      : _profile = initial;

  final UserProfileStorage _storage;
  UserProfile? _profile;
  bool _loading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _loading;

  Future<void> setProfile(UserProfile profile) async {
    _loading = true;
    notifyListeners();
    _profile = profile;
    await _storage.save(profile);
    _loading = false;
    notifyListeners();
  }

  Future<void> clear() async {
    _loading = true;
    notifyListeners();
    _profile = null;
    await _storage.clear();
    _loading = false;
    notifyListeners();
  }
}
