import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class SuggestedUsersTray extends StatelessWidget {
  final List<UserProfile> users;
  final ValueChanged<String> onFollow;
  final ValueChanged<String> onDismiss;
  final ValueChanged<UserProfile>? onSelectUser;

  const SuggestedUsersTray({
    super.key,
    required this.users,
    required this.onFollow,
    required this.onDismiss,
    this.onSelectUser,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: CyberColors.surfaceDark,
        border: const Border(
          top: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
          bottom: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.hub_outlined,
                  size: 16,
                  color: CyberColors.secondaryCyan,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUGGESTED FOR YOU',
                  style: CyberTypography.hudHeader.copyWith(
                    fontSize: 12,
                    letterSpacing: 1.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CyberColors.secondaryCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: CyberColors.secondaryCyan.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'EXPAND MESH',
                    style: CyberTypography.hudCaption.copyWith(
                      color: CyberColors.secondaryCyan,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${users.length} NODES',
                  style: CyberTypography.hudCaption.copyWith(
                    color: CyberColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Users Carousel
          SizedBox(
            height: 204,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(context, user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserProfile user) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberColors.surfaceModal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: user.isFollowing
              ? CyberColors.secondaryCyan.withValues(alpha: 0.6)
              : CyberColors.borderSubtle,
          width: 1,
        ),
        boxShadow: user.isFollowing
            ? CyberColors.cyanGlowShadow(blur: 8, spread: 1)
            : null,
      ),
      child: Stack(
        children: [
          // Dismiss button in top right
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              onTap: () => onDismiss(user.username),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: CyberColors.textMuted,
                ),
              ),
            ),
          ),

          // Card Content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onSelectUser?.call(user),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    CyberAvatar(
                      radius: 28,
                      imageUrl: user.avatarUrl,
                      isVerified: user.isVerified,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: CyberTypography.bodyBold.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (user.isPrivate) ...[
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.lock,
                            size: 11,
                            color: CyberColors.tertiaryYellow,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: CyberTypography.hudCaption.copyWith(
                        color: CyberColors.secondaryCyan,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.badge.isNotEmpty ? user.badge : 'RECOMMENDED',
                      style: CyberTypography.hudCaption.copyWith(
                        color: CyberColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Follow / Follow Request Button
              SizedBox(
                width: double.infinity,
                height: 32,
                child: _buildFollowButton(context, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, UserProfile user) {
    if (user.isFollowing) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: CyberColors.secondaryCyan, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: Colors.transparent,
        ),
        onPressed: () => onFollow(user.username),
        child: Text(
          'FOLLOWING',
          style: CyberTypography.hudBadge.copyWith(
            color: CyberColors.secondaryCyan,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (user.isPrivate) {
      if (user.isFollowRequested) {
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: const BorderSide(color: CyberColors.tertiaryYellow, width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            backgroundColor: CyberColors.tertiaryYellow.withValues(alpha: 0.1),
          ),
          onPressed: () => onFollow(user.username),
          child: Text(
            'REQUESTED',
            style: CyberTypography.hudBadge.copyWith(
              color: CyberColors.tertiaryYellow,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: CyberColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: CyberColors.tertiaryYellow, width: 1),
          ),
          elevation: 0,
        ),
        onPressed: () => onFollow(user.username),
        child: Text(
          'REQUEST',
          style: CyberTypography.hudBadge.copyWith(
            color: CyberColors.tertiaryYellow,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: CyberColors.primaryHotPink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 2,
        shadowColor: CyberColors.primaryHotPink.withValues(alpha: 0.5),
      ),
      onPressed: () => onFollow(user.username),
      child: Text(
        'FOLLOW',
        style: CyberTypography.hudBadge.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
