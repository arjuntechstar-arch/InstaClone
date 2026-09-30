import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class PostCardWidget extends StatefulWidget {
  final PostItem post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onAuthorTap;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
    this.onAuthorTap,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget>
    with SingleTickerProviderStateMixin {
  bool _showHeartAnimation = false;
  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_heartAnimController);

    _heartAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _showHeartAnimation = false);
        }
      }
    });
  }

  void _triggerDoubleTapLike() {
    if (!widget.post.isLiked) {
      widget.onLike();
    }
    setState(() => _showHeartAnimation = true);
    _heartAnimController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CyberColors.surfaceDark,
        border: const Border(
          top: BorderSide(color: CyberColors.borderSubtle, width: 0.6),
          bottom: BorderSide(color: CyberColors.borderSubtle, width: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onAuthorTap,
                  child: CyberAvatar(
                    radius: 19,
                    imageUrl: post.author.avatarUrl,
                    isVerified: post.author.isVerified,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.author.username,
                              style: CyberTypography.bodyBold.copyWith(fontSize: 13),
                            ),
                            if (post.author.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: CyberColors.secondaryCyan,
                              ),
                            ],
                          ],
                        ),
                        if (post.location.isNotEmpty) ...[
                          const SizedBox(height: 1),
                          Text(
                            post.location,
                            style: CyberTypography.hudCaption.copyWith(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: CyberColors.textSecondary, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: CyberColors.surfaceModal,
                        content: Text('Post options for ${post.id}', style: CyberTypography.bodyMedium),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. Media Image with Double-Tap Heart and HUD Overlays
          GestureDetector(
            onDoubleTap: _triggerDoubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: CyberColors.surfaceElevated,
                    child: Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.broken_image, size: 48, color: CyberColors.textMuted),
                      ),
                    ),
                  ),
                ),

                // Audio Track Chip Overlay
                if (post.musicTrack.isNotEmpty)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: CyberColors.bgVoid.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CyberColors.borderCyan, width: 0.8),
                        boxShadow: CyberColors.cyanGlowShadow(blur: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CyberWaveformWidget(
                            isPlaying: true,
                            color: CyberColors.secondaryCyan,
                            height: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            post.musicTrack,
                            style: CyberTypography.hudCaption.copyWith(
                              color: CyberColors.secondaryCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Filter Badge Overlay
                if (post.filterName != 'Normal')
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CyberBadge(
                      text: post.filterName,
                      color: CyberColors.primaryHotPink,
                      hasDot: false,
                    ),
                  ),

                // Animated Explosion Heart on Double-Tap
                if (_showHeartAnimation)
                  ScaleTransition(
                    scale: _heartScale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: CyberColors.pinkGlowShadow(blur: 32, spread: 8),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 96,
                        color: CyberColors.primaryHotPink,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Action Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? CyberColors.primaryHotPink : CyberColors.textPrimary,
                    size: 26,
                  ),
                  onPressed: widget.onLike,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: CyberColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: widget.onComment,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: CyberColors.textPrimary,
                    size: 23,
                  ),
                  onPressed: widget.onShare,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSaved ? CyberColors.secondaryCyan : CyberColors.textPrimary,
                    size: 26,
                  ),
                  onPressed: widget.onSave,
                ),
              ],
            ),
          ),

          // 4. Likes Counter & Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likesCount} likes',
                  style: CyberTypography.hudMetric.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: CyberTypography.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${post.author.username} ',
                        style: CyberTypography.bodyBold,
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                if (post.commentsCount > 0) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: widget.onComment,
                    child: Text(
                      'View all ${post.commentsCount} comments',
                      style: CyberTypography.bodySecondary.copyWith(
                        color: CyberColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  post.timestamp.toUpperCase(),
                  style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
