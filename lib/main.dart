import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_bootstrapper.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    debugPrint('Firebase not configured, continuing without it.');
  }
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  runApp(
    LocaleScope(
      notifier: localeProvider,
      child: KismetlyApp(localeProvider: localeProvider),
    ),
  );
}

class KismetlyApp extends StatelessWidget {
  const KismetlyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kismetly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme(),
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppBootstrapper(),
        );
      },
    );
  }
}
