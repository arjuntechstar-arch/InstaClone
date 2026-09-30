import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/reel_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class ReelsScreen extends StatefulWidget {
  final List<ReelItem> reels;
  final Function(String reelId) onLike;
  final Function(String reelId) onSave;
  final Function(String reelId) onFollow;
  final Function(String reelId) onComment;
  final Function(String reelId) onShare;
  final VoidCallback? onCameraTap;

  const ReelsScreen({
    super.key,
    required this.reels,
    required this.onLike,
    required this.onSave,
    required this.onFollow,
    required this.onComment,
    required this.onShare,
    this.onCameraTap,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _discAnimController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty) {
      return const Scaffold(
        backgroundColor: CyberColors.bgVoid,
        body: Center(
          child: CircularProgressIndicator(color: CyberColors.primaryHotPink),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: Stack(
        children: [
          // 1. Vertical PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.reels.length,
            itemBuilder: (context, index) {
              final reel = widget.reels[index];
              return _buildReelItem(reel);
            },
          ),

          // 2. Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REELS',
                  style: CyberTypography.hudHeader.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2.0,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                  onPressed: widget.onCameraTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(ReelItem reel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Simulated video background with cyberpunk neon imagery
        Image.network(
          'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=900',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: CyberColors.surfaceElevated,
            child: const Center(
              child: Icon(Icons.videocam, color: CyberColors.textMuted, size: 48),
            ),
          ),
        ),

        // Gradient vignettes
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Right Action Bar
        Positioned(
          right: 12,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
                color: reel.isLiked ? CyberColors.primaryHotPink : Colors.white,
                label: '${reel.likesCount}',
                onTap: () => widget.onLike(reel.id),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                color: Colors.white,
                label: '${reel.commentsCount}',
                onTap: () => widget.onComment(reel.id),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: Icons.send_rounded,
                color: Colors.white,
                label: '${reel.sharesCount}',
                onTap: () => widget.onShare(reel.id),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: reel.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: reel.isSaved ? CyberColors.secondaryCyan : Colors.white,
                label: '',
                onTap: () => widget.onSave(reel.id),
              ),
              const SizedBox(height: 20),
              // Spinning Vinyl Disc
              AnimatedBuilder(
                animation: _discAnimController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _discAnimController.value * 2 * math.pi,
                    child: Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CyberColors.bgVoid,
                        border: Border.all(color: CyberColors.borderCyan, width: 1.5),
                        boxShadow: CyberColors.cyanGlowShadow(blur: 8),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          reel.author.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: CyberColors.secondaryCyan, size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Bottom Left Info Overlay
        Positioned(
          left: 16,
          right: 80,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Author and Follow Button
              Row(
                children: [
                  CyberAvatar(
                    radius: 18,
                    imageUrl: reel.author.avatarUrl,
                    isVerified: reel.author.isVerified,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    reel.author.username,
                    style: CyberTypography.bodyBold.copyWith(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => widget.onFollow(reel.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: reel.isFollowing
                            ? Colors.transparent
                            : CyberColors.primaryHotPink,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: reel.isFollowing
                              ? CyberColors.secondaryCyan
                              : CyberColors.primaryHotPink,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        reel.isFollowing ? 'FOLLOWING' : 'FOLLOW',
                        style: CyberTypography.hudBadge.copyWith(
                          color: reel.isFollowing ? CyberColors.secondaryCyan : Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Caption
              Text(
                reel.caption,
                style: CyberTypography.bodyMedium.copyWith(color: Colors.white, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Audio Track Marquee
              Row(
                children: [
                  const Icon(Icons.music_note, size: 14, color: CyberColors.secondaryCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reel.musicTrack,
                      style: CyberTypography.hudCaption.copyWith(
                        color: CyberColors.secondaryCyan,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberColors.bgVoid.withValues(alpha: 0.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: CyberTypography.hudCaption.copyWith(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
