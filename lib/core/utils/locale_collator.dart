import 'package:flutter/widgets.dart';

class LocaleCollator {
  const LocaleCollator();

  int compare(String a, String b, Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    if (lang == 'tr') {
      return _compareTurkish(a, b);
    }
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  int _compareTurkish(String a, String b) {
    const order = [
      'a',
      'b',
      'c',
      'ç',
      'd',
      'e',
      'f',
      'g',
      'ğ',
      'h',
      'ı',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
      'ö',
      'p',
      'r',
      's',
      'ş',
      't',
      'u',
      'ü',
      'v',
      'y',
      'z',
    ];
    final map = {for (var i = 0; i < order.length; i++) order[i]: i};
    final minLength = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < minLength; i++) {
      final charA = a[i].toLowerCase();
      final charB = b[i].toLowerCase();
      final indexA = map[charA];
      final indexB = map[charB];
      if (indexA != null && indexB != null) {
        if (indexA != indexB) {
          return indexA.compareTo(indexB);
        }
      } else {
        final cmp = charA.compareTo(charB);
        if (cmp != 0) {
          return cmp;
        }
      }
    }
    return a.length.compareTo(b.length);
  }
}
