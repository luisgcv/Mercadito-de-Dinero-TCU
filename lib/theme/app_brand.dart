import 'package:flutter/material.dart';

/// Identidad visual de la app: paleta de colores, gradiente de fondo y tema
/// de Material 3.
///
/// **Usar siempre estas constantes** en lugar de escribir colores directos
/// en las pantallas, para mantener la coherencia visual. La guía completa
/// está en `docs/identidad_visual.md`.
class AppBrand {
  /// Celeste: color primario del tema (`#00C0F3`).
  static const Color celeste = Color(0xFF00C0F3);
  /// Azul oscuro: textos, íconos y estructura (`#005DA4`).
  static const Color azulOscuro = Color(0xFF005DA4);
  /// Naranja: color de acción (botones principales) (`#F37021`).
  static const Color naranja = Color(0xFFF37021);
  /// Amarillo naranja: detalles y moneda del logo (`#F99D1C`).
  static const Color amarilloNaranja = Color(0xFFF99D1C);
  /// Verde: acento educativo (`#8DC63F`).
  static const Color verde = Color(0xFF8DC63F);
  /// Blanco: superficies y tarjetas.
  static const Color blanco = Color(0xFFFFFFFF);

  /// Gradiente suave (celeste → naranja → verde) usado de fondo en el splash
  /// y el menú principal.
  static const LinearGradient fondoGradiente = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE7F8FF), Color(0xFFFFF4E9), Color(0xFFEFF9E4)],
    stops: [0.1, 0.55, 1],
  );

  /// Tema global de la app (se aplica en [MyApp]). Define los estilos de
  /// AppBar, tarjetas, botones, chips, campos de texto y SnackBars.
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
