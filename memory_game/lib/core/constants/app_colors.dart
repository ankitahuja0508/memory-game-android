import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);

  // Secondary palette
  static const Color secondary = Color(0xFF00D9FF);
  static const Color secondaryLight = Color(0xFF5CE8FF);
  static const Color secondaryDark = Color(0xFF00A8C6);

  // Accent colors
  static const Color accent = Color(0xFFFFD93D);
  static const Color accentLight = Color(0xFFFFE580);
  static const Color accentDark = Color(0xFFE6C235);

  // Game element colors
  static const Color cardBack = Color(0xFF2D3436);
  static const Color cardFront = Color(0xFFFDFDFD);
  static const Color matchGlow = Color(0xFF00FF88);
  static const Color mismatchGlow = Color(0xFFFF6B6B);

  // UI colors
  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);
  static const Color surface = Color(0xFF0F3460);
  static const Color surfaceLight = Color(0xFF1A4B7C);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF808080);

  // Currency colors
  static const Color coinColor = Color(0xFFFFD700);
  static const Color gemColor = Color(0xFF00CED1);
  static const Color energyColor = Color(0xFF00FF88);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Star colors
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF4A4A4A);

  // Level difficulty colors
  static const Color levelBeginner = Color(0xFF4CAF50);
  static const Color levelEasy = Color(0xFF8BC34A);
  static const Color levelMedium = Color(0xFFFF9800);
  static const Color levelHard = Color(0xFFE53935);
  static const Color levelExpert = Color(0xFF9C27B0);

  // Gradient backgrounds
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF4A42E8),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9D97FF),
  ];

  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];
}
