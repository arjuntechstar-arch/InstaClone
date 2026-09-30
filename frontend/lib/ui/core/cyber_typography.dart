import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cyber_colors.dart';

/// Cyberpunk typography system matching Sora, Inter, and Space Grotesk
class CyberTypography {
  CyberTypography._();

  // Display / App Titles (Sora)
  static TextStyle get titleLarge => GoogleFonts.sora(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: CyberColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: CyberColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.sora(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: CyberColors.textPrimary,
  );

  // HUD / Futuristic Monospace Labels (Space Grotesk)
  static TextStyle get hudHeader => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: CyberColors.secondaryCyan,
  );

  static TextStyle get hudBadge => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: CyberColors.bgVoid,
  );

  static TextStyle get hudMetric => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: CyberColors.textPrimary,
  );

  static TextStyle get hudCaption => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: CyberColors.textSecondary,
  );

  // Body & Feed Content (Inter)
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: CyberColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: CyberColors.textPrimary,
  );

  static TextStyle get bodySecondary => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CyberColors.textSecondary,
  );

  static TextStyle get bodyBold => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: CyberColors.textPrimary,
  );

  static TextStyle get buttonText => GoogleFonts.sora(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: Colors.white,
  );
}
