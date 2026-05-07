import 'package:flutter/material.dart';

const _brandNavy = Color(0xFF042B59);
const _brandNavyDeep = Color(0xFF031B36);
const _brandSurface = Color(0xFF0a3d73);
const _brandTeal = Color(0xFF027DFD);
const _brandOrange = Color(0xFFF15B38);
const _brandBorder = Color(0xFF0553B1);

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
      onPrimary: Colors.white,
      secondary: _brandBorder,
      onSecondary: Colors.white,
      surface: _brandSurface,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFD0D8E0),
      error: _brandOrange,
      onError: Colors.white,
    ),
    extensions: const [ExampleThemeTokens(primarySoft: _brandOrange)],
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
        color: Color(0xFFD0D8E0),
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _brandNavyDeep,
      hintStyle: const TextStyle(color: Color(0xFFD0D8E0)),
      labelStyle: const TextStyle(color: Colors.white),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brandOrange, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _brandTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _brandOrange,
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
