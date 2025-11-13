import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Co-Star aesthetic: Pure white, minimal, elegant
  static const Color bg = Colors.white;
  static const Color card = Colors.white;
  static const Color text = Color(0xFF1A1A1A);
  static const Color subtext = Color(0xFF6B6B6B);
  static const Color stroke = Color(0xFFE5E5E5);
  static const Color primary = Color(0xFF1A1A1A);

  static ThemeData theme() {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      useMaterial3: true,
    );

    // Co-Star typography: Serif for titles (Playfair Display / Merriweather style)
    final serif = GoogleFonts.playfairDisplay(
      color: text,
      height: 1.3,
      letterSpacing: -0.5,
    );
    
    // Light sans-serif for body (Inter / Source Sans Pro style)
    final sans = GoogleFonts.inter(
      color: text,
      height: 1.5,
      letterSpacing: 0,
      fontWeight: FontWeight.w300,
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: card,
        primary: primary,
        onPrimary: Colors.white,
        onSurface: text,
      ),
      textTheme: TextTheme(
        displayLarge: serif.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: -1,
        ),
        displayMedium: serif.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
        ),
        titleLarge: serif.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
        ),
        titleMedium: serif.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: sans.copyWith(
          fontSize: 16,
          color: text,
          fontWeight: FontWeight.w300,
        ),
        bodyMedium: sans.copyWith(
          fontSize: 14,
          color: subtext,
          fontWeight: FontWeight.w300,
        ),
        labelLarge: sans.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: sans.copyWith(color: subtext),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: stroke, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: stroke, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: sans.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: stroke, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: sans.copyWith(
            color: primary,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: stroke,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        dense: true,
      ),
    );
  }
}

