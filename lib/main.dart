import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class KismetlyApp extends StatefulWidget {
  const KismetlyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  @override
  State<KismetlyApp> createState() => _KismetlyAppState();
}

class _KismetlyAppState extends State<KismetlyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    if (mounted) {
      setState(() {
        _themeMode = ThemeMode.values[themeModeIndex.clamp(0, 2)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reload theme mode on each build to catch changes from Settings
    _loadThemeMode();
    
    return AnimatedBuilder(
      animation: widget.localeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kismetly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: _themeMode,
          locale: widget.localeProvider.locale,
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
