import 'package:flutter/material.dart';

/// Application color palette - Ocean Blue Gaming Theme
class AppColors {
  AppColors._();

  // Primary palette - Vibrant Blue
  static const Color primary = Color(0xFF2979FF);
  static const Color primaryLight = Color(0xFF75A7FF);
  static const Color primaryDark = Color(0xFF0052CC);

  // Secondary palette - Sky Blue
  static const Color secondary = Color(0xFF40C4FF);
  static const Color secondaryLight = Color(0xFF82E9FF);
  static const Color secondaryDark = Color(0xFF0094CC);

  // Accent colors - Electric Cyan
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentLight = Color(0xFF6EFFFF);
  static const Color accentDark = Color(0xFF00B2CC);

  // Game element colors
  static const Color cardBack = Color(0xFF1A237E);
  static const Color cardFront = Color(0xFFFDFDFD);
  static const Color matchGlow = Color(0xFF00E676);
  static const Color mismatchGlow = Color(0xFFFF5252);

  // UI colors - Deep Space Blue
  static const Color background = Color(0xFF0A1929);
  static const Color backgroundLight = Color(0xFF0D2137);
  static const Color surface = Color(0xFF132F4C);
  static const Color surfaceLight = Color(0xFF1E4976);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB2BAC2);
  static const Color textHint = Color(0xFF6F7E8C);

  // Currency colors
  static const Color coinColor = Color(0xFFFFD700);
  static const Color gemColor = Color(0xFF00E5FF);
  static const Color energyColor = Color(0xFF76FF03);

  // Status colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF29B6F6);

  // Star colors
  static const Color starFilled = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF263850);

  // Level difficulty colors
  static const Color levelBeginner = Color(0xFF00E676);
  static const Color levelEasy = Color(0xFF69F0AE);
  static const Color levelMedium = Color(0xFFFFAB00);
  static const Color levelHard = Color(0xFFFF6D00);
  static const Color levelExpert = Color(0xFFE040FB);

  // Gradient backgrounds
  static const List<Color> primaryGradient = [
    Color(0xFF2979FF),
    Color(0xFF0052CC),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF0A1929),
    Color(0xFF0D2137),
    Color(0xFF132F4C),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF2979FF),
    Color(0xFF75A7FF),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),  // Softer green
    Color(0xFF66BB6A),  // Muted green
  ];
}
