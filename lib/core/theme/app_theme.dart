import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium fintech dark theme with glassmorphism accents.
class AppTheme {
  AppTheme._();

  // ─── Semantic Aliases ──────────────────────────────────────────
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceLight = AppColors.surfaceLight;
  static const Color cardColor = AppColors.cardColor;
  static const Color cardBorder = AppColors.cardBorder;
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color primaryAction = AppColors.primaryAction;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color profit = AppColors.profit;
  static const Color loss = AppColors.loss;
  static const Color divider = AppColors.divider;

  // ─── Gradient Aliases ──────────────────────────────────────────
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
  static const LinearGradient cardGradient = AppColors.cardGradient;
  static const LinearGradient heroGradient = AppColors.heroGradient;

  // ─── Theme Data ────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(color: textPrimary),
        titleSmall: textTheme.titleSmall?.copyWith(color: textSecondary),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: textPrimary),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: textSecondary),
        bodySmall: textTheme.bodySmall?.copyWith(color: textTertiary),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        error: loss,
        onPrimary: Color(0xFF003329),
        onSurface: textPrimary,
        onError: Colors.white,
        outline: cardBorder,
      ),
      appBarTheme: _appBarTheme(textTheme),
      cardTheme: _cardTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(),
      dividerTheme: const DividerThemeData(color: divider, thickness: 0.5),
      snackBarTheme: _snackBarTheme(),
      dialogTheme: _dialogTheme(),
    );
  }

  // ─── Private Theme Builders ────────────────────────────────────

  static AppBarTheme _appBarTheme(TextTheme textTheme) => AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: textTheme.titleLarge?.copyWith(
      color: textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    iconTheme: const IconThemeData(color: textPrimary),
  );

  static CardThemeData _cardTheme() => CardThemeData(
    color: cardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: cardBorder, width: 0.5),
    ),
  );

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF003329),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: primary, width: 1.5),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme() => InputDecorationTheme(
    filled: true,
    fillColor: surfaceLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: _inputBorder(),
    enabledBorder: _inputBorder(width: 0.5),
    focusedBorder: _inputBorder(color: primary, width: 1.5),
    errorBorder: _inputBorder(color: loss),
    hintStyle: const TextStyle(color: textTertiary),
    prefixIconColor: textTertiary,
  );

  static OutlineInputBorder _inputBorder({Color? color, double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color ?? cardBorder, width: width),
      );

  static BottomNavigationBarThemeData _bottomNavigationBarTheme() =>
      const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static SnackBarThemeData _snackBarTheme() => SnackBarThemeData(
    backgroundColor: surfaceLight,
    contentTextStyle: const TextStyle(color: textPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  );

  static DialogThemeData _dialogTheme() => DialogThemeData(
    backgroundColor: surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

/// Glassmorphism card decoration.
BoxDecoration glassCard({double borderRadius = 16, Color? borderColor}) {
  return BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: borderColor ?? AppColors.cardBorder, width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
