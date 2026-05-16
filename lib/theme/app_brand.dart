import 'package:flutter/material.dart';

class AppBrand {
  static const Color celeste = Color(0xFF00C0F3);
  static const Color azulOscuro = Color(0xFF005DA4);
  static const Color naranja = Color(0xFFF37021);
  static const Color amarilloNaranja = Color(0xFFF99D1C);
  static const Color verde = Color(0xFF8DC63F);
  static const Color blanco = Color(0xFFFFFFFF);

  static const LinearGradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE7F8FF), Color(0xFFFFF4E9), Color(0xFFEFF9E4)],
    stops: [0.1, 0.55, 1],
  );

  static ThemeData get theme {
    const radius = 20.0;

    final scheme = ColorScheme.fromSeed(
      seedColor: celeste,
      primary: celeste,
      secondary: naranja,
      tertiary: verde,
      surface: blanco,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF9FDFF),
      fontFamily: 'Trebuchet MS',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: azulOscuro,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: azulOscuro,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: blanco,
        elevation: 2,
        shadowColor: celeste.withValues(alpha: 0.20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: Color(0x2200C0F3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: naranja,
          foregroundColor: blanco,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: azulOscuro,
        foregroundColor: blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: celeste.withValues(alpha: 0.15),
        selectedColor: verde.withValues(alpha: 0.25),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blanco,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33005DA4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: azulOscuro, width: 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: azulOscuro,
        contentTextStyle: TextStyle(color: blanco, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
