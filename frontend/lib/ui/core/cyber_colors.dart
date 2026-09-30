import 'package:flutter/material.dart';

/// Design tokens extracted from prototype/neon_tokyo/DESIGN.md
/// Cyberpunk "Electric Nightscape" Palette
class CyberColors {
  CyberColors._();

  // Primary Brand Colors
  static const Color primaryHotPink = Color(0xFFFF2D78);
  static const Color secondaryCyan = Color(0xFF00FFCC);
  static const Color tertiaryYellow = Color(0xFFFFE04A);
  static const Color purpleAccent = Color(0xFF7928CA);
  static const Color violetNeon = Color(0xFF9900FF);

  // Background and Surfaces
  static const Color bgVoid = Color(0xFF0A0A12);
  static const Color surfaceDark = Color(0xFF12121E);
  static const Color surfaceCard = Color(0xFF161628);
  static const Color surfaceElevated = Color(0xFF1F1F35);
  static const Color surfaceModal = Color(0xFF18182B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF232338);
  static const Color borderHighlight = Color(0xFF38385A);
  static const Color borderPink = Color(0x66FF2D78);
  static const Color borderCyan = Color(0x6600FFCC);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EA3BF);
  static const Color textMuted = Color(0xFF5A5C75);
  static const Color textHighlight = Color(0xFFFFE04A);

  // Semantic Status
  static const Color statusOnline = Color(0xFF00FFCC);
  static const Color statusLive = Color(0xFFFF2D78);
  static const Color statusWarning = Color(0xFFFFE04A);

  // Gradients
  static const LinearGradient tokyoSunset = LinearGradient(
    colors: [primaryHotPink, purpleAccent, secondaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    colors: [primaryHotPink, tertiaryYellow, secondaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGlow = LinearGradient(
    colors: [secondaryCyan, Color(0xFF0080FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pinkGlow = LinearGradient(
    colors: [primaryHotPink, Color(0xFFFF5E99)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161628), Color(0xFF0F0F1B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glow Shadows
  static List<BoxShadow> pinkGlowShadow({double spread = 0, double blur = 14}) => [
    BoxShadow(
      color: primaryHotPink.withValues(alpha: 0.45),
      spreadRadius: spread,
      blurRadius: blur,
    ),
  ];

  static List<BoxShadow> cyanGlowShadow({double spread = 0, double blur = 14}) => [
    BoxShadow(
      color: secondaryCyan.withValues(alpha: 0.45),
      spreadRadius: spread,
      blurRadius: blur,
    ),
  ];

  static List<BoxShadow> cardElevationShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      spreadRadius: 1,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
