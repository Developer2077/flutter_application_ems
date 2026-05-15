import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8A3D),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFD84315), // Deep Orange 800 per massimo contrasto
      secondary: const Color(0xFF455A64),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Sfondo più scuro per staccare dalle card
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFF0F2F5),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2, // Aggiunto un filo di elevazione per profondità
        shadowColor: Colors.black.withAlpha(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: base.outline.withAlpha(60), width: 1),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB26B),
      brightness: Brightness.dark,
      // Colori di superficie personalizzati per maggior contrasto OLED/Dark
      surface: const Color(0xFF15191E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: const Color(0xFF090B0E), // Sfondo quasi nero
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF090B0E),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF15191E), // Card leggermente rialzate
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: base.outlineVariant.withAlpha(50)),
        ),
      ),
    );
  }
}
