import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kismetly/core/localization/locale_provider.dart';
import 'package:kismetly/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_locale': 'tr',
      'user_profile_v1': jsonEncode({
        'name': 'Test Kullanıcı',
        'birthDate': DateTime(1990, 1, 1).toIso8601String(),
        'birthTime': 480,
        'birthCity': 'İstanbul',
        'birthLatitude': 41.0082,
        'birthLongitude': 28.9784,
        'gender': 'F',
        'sunSign': 'aries',
        'risingSign': 'leo',
      }),
    });
  });

  tearDown(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Ana ekran başlığı yüklenir', (tester) async {
    final provider = LocaleProvider();
    await provider.loadSavedLocale();

    await tester.pumpWidget(
      LocaleScope(
        notifier: provider,
        child: KismetlyApp(localeProvider: provider),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kozmik Pano'), findsOneWidget);
  });
}
