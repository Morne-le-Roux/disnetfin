import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const _surface = Color(0xFFF7F2E8);
  static const _surfaceVariant = Color(0xFFE8E0D3);
  static const _ink = Color(0xFF1C2421);
  static const _sage = Color(0xFF2F6A5A);
  static const _clay = Color(0xFFBF5A37);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _sage,
            brightness: Brightness.light,
          ).copyWith(
            primary: _sage,
            secondary: _clay,
            surface: _surface,
            surfaceContainerHighest: _surfaceVariant,
            onSurface: _ink,
          ),
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme)
        .copyWith(
          headlineLarge: GoogleFonts.dmSerifDisplay(
            fontSize: 42,
            fontWeight: FontWeight.w400,
            color: _ink,
          ),
          headlineMedium: GoogleFonts.dmSerifDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: _ink,
          ),
          titleLarge: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          bodyLarge: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _ink,
          ),
          bodyMedium: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _ink.withValues(alpha: 0.82),
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: _surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.78),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCDBEAA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCDBEAA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _sage, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _sage,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        indicatorColor: _sage.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.spaceGrotesk(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            color: selected ? _sage : _ink.withValues(alpha: 0.75),
          );
        }),
      ),
    );
  }
}
