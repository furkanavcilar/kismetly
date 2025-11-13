import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({Locale? defaultLocale})
      : _locale = defaultLocale ?? const Locale('tr');

  Locale _locale;
  bool _initialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _initialized;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

class LocaleScope extends InheritedNotifier<LocaleProvider> {
  const LocaleScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static LocaleProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context');
    return scope!.notifier!;
  }
}
