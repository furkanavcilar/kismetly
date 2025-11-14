import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    if (raw == null) {
      debugPrint('UserProfileStorage.load() - No saved profile found, returning null');
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(decoded);
      debugPrint('UserProfileStorage.load() - Loaded profile: $profile');
      return profile;
    } catch (e) {
      debugPrint('UserProfileStorage.load() - Error parsing profile: $e');
      return null;
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
