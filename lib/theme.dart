import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Colors.black;
  static const Color card = Color(0xFF121212);
  static const Color text = Colors.white;
  static const Color subtext = Color(0xFFBFBFBF);
  static const Color stroke = Color(0x22FFFFFF);

  static ThemeData theme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      useMaterial3: true,
    );

    final serif = GoogleFonts.playfairDisplay(
      color: text,
      height: 1.2,
    );
    final sans = GoogleFonts.inter(
      color: text,
      height: 1.25,
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
        surface: card,
        primary: Colors.white,
        onPrimary: Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: serif.copyWith(fontSize: 34, fontWeight: FontWeight.w700),
        displayMedium:
            serif.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
        titleLarge: serif.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
        bodyLarge: sans.copyWith(fontSize: 16, color: text),
        bodyMedium: sans.copyWith(fontSize: 14, color: subtext),
        labelLarge: sans.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: sans.copyWith(color: subtext),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: sans.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: stroke),
        ),
      ),
      dividerTheme: const DividerThemeData(color: stroke, thickness: 1),
    );
  }
}
