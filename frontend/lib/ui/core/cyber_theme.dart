import 'package:flutter/material.dart';
import 'cyber_colors.dart';
import 'cyber_typography.dart';

/// App theme configuring dark neon cyberpunk ambiance
class CyberTheme {
  CyberTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CyberColors.bgVoid,
      primaryColor: CyberColors.primaryHotPink,
      canvasColor: CyberColors.bgVoid,
      cardColor: CyberColors.surfaceCard,
      dividerColor: CyberColors.borderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: CyberColors.primaryHotPink,
        secondary: CyberColors.secondaryCyan,
        tertiary: CyberColors.tertiaryYellow,
        surface: CyberColors.surfaceCard,
        onPrimary: Colors.white,
        onSecondary: CyberColors.bgVoid,
        onSurface: CyberColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CyberColors.bgVoid,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: CyberColors.textPrimary),
        titleTextStyle: CyberTypography.titleMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CyberColors.surfaceDark,
        selectedItemColor: CyberColors.primaryHotPink,
        unselectedItemColor: CyberColors.textMuted,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CyberColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CyberColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CyberColors.secondaryCyan, width: 1.5),
        ),
        hintStyle: CyberTypography.bodySecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CyberColors.surfaceModal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberColors.borderHighlight, width: 1),
        ),
      ),
    );
  }
}
