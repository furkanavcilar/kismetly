import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('tr'), Locale('en')];

  static Future<AppLocalizations> load(Locale locale) async {
    final String langCode = supportedLocales
            .map((e) => e.languageCode)
            .contains(locale.languageCode)
        ? locale.languageCode
        : supportedLocales.first.languageCode;

    final String jsonString =
        await rootBundle.loadString('lib/l10n/app_$langCode.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    final localization = AppLocalizations(locale);
    localization._localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return localization;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key, {Map<String, String>? params}) {
    String value = _localizedStrings[key] ?? key;
    if (params != null) {
      params.forEach((param, replacement) {
        value = value.replaceAll('{$param}', replacement);
      });
    }
    return value;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((e) => e.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
