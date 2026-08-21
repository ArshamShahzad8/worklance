import 'package:flutter/material.dart';

/// Centralized color palette for the WORKLANCE brand.
///
/// Screens and widgets should pull colors from here (or from the
/// [ColorScheme] built in `app_theme.dart`) instead of defining ad-hoc
/// colors inline. This keeps the whole app visually consistent and makes
/// rebranding a one-file change.
abstract final class AppColors {
  // --- Brand ---
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimaryContainer = Color(0xFF312E81);

  // --- Accent ---
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentContainer = Color(0xFFFEF3C7);
  static const Color onAccent = Color(0xFF451A03);

  // --- Neutrals ---
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  // --- Text ---
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // --- Feedback ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);

  // --- Decoration ---
  static const List<Color> brandGradient = [primaryLight, primaryDark];

  /// Palette used to give each freelancer a distinct avatar background.
  static const List<Color> avatarPalette = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF14B8A6),
  ];
}
