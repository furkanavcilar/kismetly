import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._strings);

  final Locale locale;
  final Map<String, String> _strings;

  static const supportedLocales = [Locale('tr'), Locale('en')];

  static Future<AppLocalizations> load(Locale locale) async {
    final languageCode = supportedLocales
            .map((e) => e.languageCode)
            .contains(locale.languageCode)
        ? locale.languageCode
        : supportedLocales.first.languageCode;
    final path = 'lib/l10n/app_\${languageCode}.arb';
    final data = await rootBundle.loadString(path);
    final map = json.decode(data) as Map<String, dynamic>;
    return AppLocalizations(
      Locale(languageCode),
      map.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key, {Map<String, String>? params}) {
    final template = _strings[key] ?? key;
    if (params == null || params.isEmpty) {
      return template;
    }
    var result = template;
    params.forEach((placeholder, value) {
      result = result.replaceAll('{$placeholder}', value);
    });
    return result;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((element) => element.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
