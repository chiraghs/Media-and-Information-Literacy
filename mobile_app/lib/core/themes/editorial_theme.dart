import 'package:flutter/material.dart';

class EditorialTheme {
  // Light Mode Default Colors (Warm Ivory, Sepia Black, Warm Terracotta)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFC2410C),      // Terracotta primary brand
      secondary: Color(0xFF15803D),    // Forest Green
      surface: Color(0xFFFFFFFF),      // White card background
      background: Color(0xFFFBF9F4),   // Warm Ivory primary background
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1C1917),    // Sepia Black
      onBackground: Color(0xFF1C1917),
      error: Color(0xFF991B1B),        // Brick Red
      outline: Color(0xFFE3DED5),      // Sand Outline
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF1C1917)),
      headlineLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF1C1917)),
      headlineMedium: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1C1917)),
      titleLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1C1917)),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFF44403C)),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 12, color: Color(0xFF78716C)),
    ),
  );

  // Dark Mode Colors (Dark Sepia / Warm Charcoal)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFEA580C),      // Terracotta accent
      secondary: Color(0xFF22C55E),    // Forest Green
      surface: Color(0xFF1F1C1B),      // Dark Sepia Cards
      background: Color(0xFF151312),   // Dark Sepia Base
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFF5F2EB),    // Cream light text
      onBackground: Color(0xFFF5F2EB),
      error: Color(0xFFEF4444),
      outline: Color(0xFF333130),
    ),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFFF5F2EB)),
      headlineLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFFF5F2EB)),
      headlineMedium: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFFF5F2EB)),
      titleLarge: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF5F2EB)),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xFFD6D3D1)),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 12, color: Color(0xFFA8A29E)),
    ),
  );
}
