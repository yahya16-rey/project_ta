import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JamuTheme {
  // Client's Mockup Color Palette
  static const Color primaryGreen = Color(0xFF063A24); // Deep Forest Green (Brand & Buttons)
  static const Color primaryGreenDark = Color(0xFF032215);
  static const Color primaryGreenLight = Color(0xFF5CAE93); // Medium Green/Gray (Sparkline & Gauge)
  static const Color accentGreen = Color(0xFFA9F3C6); // Light Mint Green (Selected Nav Capsule)
  static const Color lightMintBg = Color(0xFFD3F6E3); // Mint green background
  static const Color statusGreenBg = Color(0xFFE3F9ED); // Very light mint green for success badges
  static const Color statusGreenText = Color(0xFF2E7D32);

  // Warning & Danger
  static const Color warningOrangeBg = Color(0xFFFFF3E0);
  static const Color warningOrangeText = Color(0xFFE65100);
  static const Color dangerRedBg = Color(0xFFFFEBEE);
  static const Color dangerRedText = Color(0xFFC62828);

  // Neutral colors
  static const Color backgroundColor = Color(0xFFF8F9FE); // Soft grayish-purple background
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E2229); // Dark Charcoal
  static const Color textSecondary = Color(0xFF5C626C);
  static const Color textLight = Color(0xFF9096A2);
  static const Color borderLight = Color(0xFFF0F2F6);

  // Radius & Shadows
  static BorderRadius cardRadius = BorderRadius.circular(24.0);
  static BorderRadius innerCardRadius = BorderRadius.circular(16.0);
  static BorderRadius badgeRadius = BorderRadius.circular(10.0);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.015),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Font & Typography Styles (Outfit/Inter preferred)
  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textLight,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textLight,
      );

  // Custom ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        background: backgroundColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: const BorderSide(color: borderLight, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}

