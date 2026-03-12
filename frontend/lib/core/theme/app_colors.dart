import 'package:flutter/material.dart';

class AppColors {
  // Primary Sanzen Colors
  static const Color primaryDark = Color(0xFF192A1D); // Deeper, more elegant forest green
  static const Color primaryGreen = Color(0xFF144525); // Sleeker green
  static const Color gold = Color(0xFFC2A563); // Signature Sanzen Gold
  static const Color goldBright = Color(0xFFD4B97A);

  // Modern Neutral Colors (High Contrast Luxury)
  static const Color black = Color(0xFF111111); // Off-black for slightly softer luxury text
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA); // Standard app background
  static const Color darkGrey = Color(0xFF333333);
  static const Color grey = Color(0xFF888888);
  static const Color lightGrey = Color(0xFFE5E5E5);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFFFFFFF);

  // Status Colors (Subtle variants)
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF1976D2);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);

  // Transparent / Glassmorphism
  static const Color blackOverlay = Color(0x75000000); // Slightly darker for image text readability
  static const Color whiteOverlay = Color(0x66FFFFFF);

  // Gradients for Cards
  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryGreen],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBright, gold],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x99FFFFFF),
      Color(0x4DFFFFFF),
    ],
  );
}
