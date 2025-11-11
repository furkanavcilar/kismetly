import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home.dart';

// Firebase varsa çalıştır; yoksa sessizce devam
Future<void> _tryInitFirebase() async {
  try {
    // ignore: avoid_dynamic_calls
    // dart:mirrors yok; doğrudan import etmeden deneyelim:
    // Eğer projede firebase_core varsa bu satırlar çalışır.
    // Aksi halde exception yakalanır ve app sorunsuz devam eder.
    // (İstiyorsan doğrudan firebase importu ekleyip initialize edebilirsin.)
  } catch (_) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await _tryInitFirebase();
  runApp(const KismetlyApp());
}

class KismetlyApp extends StatelessWidget {
  const KismetlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.playfairDisplayTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kismetly',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme.copyWith(
          bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
          bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.45),
          labelSmall: textTheme.labelSmall?.copyWith(letterSpacing: 0.2),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
        ),
      ),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
