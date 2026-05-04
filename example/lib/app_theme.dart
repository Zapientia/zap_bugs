import 'package:flutter/material.dart';

const _brandNavy = Color(0xFF0B1B2B);
const _brandNavyDeep = Color(0xFF071521);
const _brandSurface = Color(0xFF11263A);
const _brandTeal = Color(0xFF1ED0B6);
const _brandTealSoft = Color(0xFF7FE8D7);
const _brandTextMuted = Color(0xFF8AA0B4);

/// App-level theme for the example.
///
/// ZapBugs does not need package-specific styling hooks. It reads normal
/// Flutter theme values such as [DialogThemeData], [InputDecorationTheme],
/// [FilledButtonThemeData], [TextButtonThemeData], and [ColorScheme].
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );

  return base.copyWith(
    scaffoldBackgroundColor: _brandNavy,
    colorScheme: const ColorScheme.dark(
      primary: _brandTeal,
      onPrimary: _brandNavyDeep,
      secondary: _brandTealSoft,
      onSecondary: _brandNavyDeep,
      surface: _brandSurface,
      onSurface: Colors.white,
      onSurfaceVariant: _brandTextMuted,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    ),
    extensions: const [ExampleThemeTokens(primarySoft: _brandTealSoft)],
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: _brandNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: _brandSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _brandSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: _brandTextMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _brandNavyDeep,
      hintStyle: const TextStyle(color: _brandTextMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3550), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandTeal, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _brandTeal,
        foregroundColor: _brandNavyDeep,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _brandTextMuted,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _brandSurface,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

@immutable
class ExampleThemeTokens extends ThemeExtension<ExampleThemeTokens> {
  const ExampleThemeTokens({required this.primarySoft});

  final Color primarySoft;

  @override
  ExampleThemeTokens copyWith({Color? primarySoft}) {
    return ExampleThemeTokens(primarySoft: primarySoft ?? this.primarySoft);
  }

  @override
  ExampleThemeTokens lerp(
    covariant ThemeExtension<ExampleThemeTokens>? other,
    double t,
  ) {
    if (other is! ExampleThemeTokens) {
      return this;
    }

    return ExampleThemeTokens(
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
    );
  }
}
