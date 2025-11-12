import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile.dart';

class UserProfileStorage {
  UserProfileStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'user_profile_v1';

  Future<void> save(UserProfile profile) async {
    await _prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  UserProfile? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
