import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'cyber_colors.dart';
import 'cyber_typography.dart';

/// Reusable Cyberpunk UI components matching prototype specifications

/// Neon glowing card container with subtle borders
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasGlow;

  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 14,
    this.onTap,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? CyberColors.borderSubtle;
    final bg = backgroundColor ?? CyberColors.surfaceCard;

    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          ...CyberColors.cardElevationShadow,
          if (hasGlow)
            BoxShadow(
              color: border.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Cyberpunk action button with neon gradient and optional glow
class CyberButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isOutlined;
  final bool isSmall;
  final bool isLoading;
  final double? width;

  const CyberButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isSecondary ? CyberColors.secondaryCyan : CyberColors.primaryHotPink;
    final textColor = isOutlined
        ? primaryColor
        : (isSecondary ? CyberColors.bgVoid : Colors.white);

    final height = isSmall ? 36.0 : 46.0;
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 14)
        : const EdgeInsets.symmetric(horizontal: 20);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: isOutlined
            ? null
            : (isSecondary
                ? CyberColors.cyanGlow
                : CyberColors.pinkGlow),
        border: isOutlined
            ? Border.all(color: primaryColor, width: 1.5)
            : null,
        boxShadow: isOutlined
            ? null
            : (isSecondary
                ? CyberColors.cyanGlowShadow(blur: 10)
                : CyberColors.pinkGlowShadow(blur: 10)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, size: isSmall ? 16 : 18, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: isSmall
                      ? CyberTypography.titleSmall.copyWith(color: textColor, fontSize: 13)
                      : CyberTypography.buttonText.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cyberpunk badge / status tag (e.g., LIVE, PRO, VERIFIED, NEW)
class CyberBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool hasDot;
  final bool isGlowing;

  const CyberBadge({
    super.key,
    required this.text,
    this.color = CyberColors.secondaryCyan,
    this.hasDot = true,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text.toUpperCase(),
            style: CyberTypography.hudBadge.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glowing Cyber Avatar with gradient story ring or status indicator
class CyberAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool hasStory;
  final bool hasUnseenStory;
  final bool isLive;
  final bool isVerified;
  final VoidCallback? onTap;

  const CyberAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.hasStory = false,
    this.hasUnseenStory = true,
    this.isLive = false,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent = CircleAvatar(
      radius: radius,
      backgroundColor: CyberColors.surfaceElevated,
      backgroundImage: (imageUrl != null && imageUrl!.startsWith('http'))
          ? NetworkImage(imageUrl!)
          : null,
      child: (imageUrl == null || !imageUrl!.startsWith('http'))
          ? Icon(
              Icons.person,
              size: radius * 1.1,
              color: CyberColors.textSecondary,
            )
          : null,
    );

    Widget result;
    if (hasStory || isLive) {
      final ringGradient = isLive
          ? const LinearGradient(
              colors: [CyberColors.primaryHotPink, Color(0xFFFF0055)],
            )
          : (hasUnseenStory
              ? CyberColors.storyRingGradient
              : const LinearGradient(
                  colors: [CyberColors.borderSubtle, CyberColors.borderHighlight],
                ));

      result = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ringGradient,
          boxShadow: (isLive || hasUnseenStory)
              ? [
                  BoxShadow(
                    color: (isLive
                            ? CyberColors.primaryHotPink
                            : CyberColors.secondaryCyan)
                        .withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: CyberColors.bgVoid,
            shape: BoxShape.circle,
          ),
          child: avatarContent,
        ),
      );
    } else {
      result = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: CyberColors.borderSubtle, width: 1.5),
        ),
        child: avatarContent,
      );
    }

    if (isLive) {
      result = Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                gradient: CyberColors.pinkGlow,
                borderRadius: BorderRadius.circular(4),
                boxShadow: CyberColors.pinkGlowShadow(blur: 6),
              ),
              child: Text(
                'LIVE',
                style: CyberTypography.hudBadge.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (isVerified) {
      result = Stack(
        children: [
          result,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: CyberColors.bgVoid,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: CyberColors.secondaryCyan,
                size: 14,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: result,
      );
    }
    return result;
  }
}

/// Dynamic Audio Waveform Equalizer
class CyberWaveformWidget extends StatefulWidget {
  final List<int>? customWaveform;
  final bool isPlaying;
  final Color color;
  final double height;

  const CyberWaveformWidget({
    super.key,
    this.customWaveform,
    this.isPlaying = false,
    this.color = CyberColors.secondaryCyan,
    this.height = 32,
  });

  @override
  State<CyberWaveformWidget> createState() => _CyberWaveformWidgetState();
}

class _CyberWaveformWidgetState extends State<CyberWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _anim.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CyberWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.isPlaying && _anim.isAnimating) {
      _anim.stop();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.customWaveform ?? [30, 60, 45, 90, 70, 40, 85, 95, 50, 35, 75, 60, 40, 20, 80];
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(bars.length, (index) {
              final raw = bars[index] / 100.0;
              final wave = widget.isPlaying
                  ? (math.sin((_anim.value * 2 * math.pi) + (index * 0.4)).abs() * 0.5 + 0.5)
                  : 1.0;
              final barHeight = (raw * wave * widget.height).clamp(4.0, widget.height);

              return Container(
                width: 3,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: widget.isPlaying
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.6),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Cyber Reticle Viewfinder Corners for Camera and HUD screens
class CyberReticleWidget extends StatelessWidget {
  final Widget child;
  final Color reticleColor;
  final double cornerLength;
  final double strokeWidth;

  const CyberReticleWidget({
    super.key,
    required this.child,
    this.reticleColor = CyberColors.secondaryCyan,
    this.cornerLength = 18,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ReticlePainter(
        color: reticleColor,
        cornerLength: cornerLength,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  _ReticlePainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const offset = 8.0;
    final w = size.width - offset;
    final h = size.height - offset;

    // Top-Left
    canvas.drawLine(const Offset(offset, offset), Offset(offset + cornerLength, offset), paint);
    canvas.drawLine(const Offset(offset, offset), Offset(offset, offset + cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(w, offset), Offset(w - cornerLength, offset), paint);
    canvas.drawLine(Offset(w, offset), Offset(w, offset + cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(offset, h), Offset(offset + cornerLength, h), paint);
    canvas.drawLine(Offset(offset, h), Offset(offset, h - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scanline CRT overlay for futuristic holographic displays
class CyberScanlineOverlay extends StatelessWidget {
  const CyberScanlineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.15),
            ],
            stops: const [0.5, 1.0],
            tileMode: TileMode.repeated,
          ),
        ),
      ),
    );
  }
}
