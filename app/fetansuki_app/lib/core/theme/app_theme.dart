import 'package:flutter/material.dart';

class AppTheme {
  static const String _fontFamily = 'Sora';

  static TextTheme _getTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? const Color(0xFF0F3C7E) : Colors.white;
    return TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold, color: color),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold, color: color),
      displaySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold, color: color),
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: color),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: color),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, color: color),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: color),
      titleSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, color: color),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.normal, color: color),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.normal, color: color),
      bodySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.normal, color: color),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, color: color),
      labelMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, color: color),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F3C7E),
        primary: const Color(0xFF0F3C7E),
      ),
      fontFamily: _fontFamily,
      textTheme: _getTextTheme(Brightness.light),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: Color(0xFF0F3C7E),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF0F3C7E), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F3C7E),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      textTheme: _getTextTheme(Brightness.dark),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF0F3C7E),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
      ),
    );
  }
}
