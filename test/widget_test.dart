import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kismetly/core/localization/locale_provider.dart';
import 'package:kismetly/main.dart';

void main() {
  testWidgets('Ana ekran başlığı yüklenir', (WidgetTester tester) async {
    final provider = LocaleProvider();
    await tester.pumpWidget(
      LocaleScope(
        notifier: provider,
        child: KismetlyApp(localeProvider: provider),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
  });
}
