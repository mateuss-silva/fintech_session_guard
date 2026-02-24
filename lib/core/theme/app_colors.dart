import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Colors ────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1F2937);
  static const Color cardColor = Color(0xFF162032);
  static const Color cardBorder = Color(0xFF1E3A5F);

  static const Color primary = Color(0xFF00D4AA);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color primaryAction = primary;

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  static const Color profit = Color(0xFF10B981);
  static const Color loss = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color divider = Color(0xFF1F2937);
  static const Color shimmerBase = Color(0xFF1F2937);
  static const Color shimmerHighlight = Color(0xFF374151);

  // ─── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF00B4D8)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF162032), Color(0xFF0F172A)],
  );

  static const LinearGradient portfolioGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D1F24), // Very Dark Teal (Subtle)
      Color(0xFF0A0E1A), // Dark Background
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), background],
    stops: [0.0, 1.0],
  );
}
