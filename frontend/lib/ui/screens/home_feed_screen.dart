import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../../data/models/story_model.dart';
import '../../data/models/user_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/story_tray_widget.dart';
import '../widgets/suggested_users_tray.dart';

class HomeFeedScreen extends StatelessWidget {
  final List<PostItem> posts;
  final List<StoryItem> stories;
  final List<UserProfile> suggestedUsers;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onLikePost;
  final ValueChanged<String> onSavePost;
  final ValueChanged<String> onCommentPost;
  final ValueChanged<String> onSharePost;
  final ValueChanged<String>? onRepostPost;
  final ValueChanged<String>? onFollowSuggestion;
  final ValueChanged<String>? onDismissSuggestion;
  final ValueChanged<UserProfile>? onSelectSuggestedUser;
  final ValueChanged<String>? onAuthorTap;
  final ValueChanged<StoryItem> onStorySelected;
  final VoidCallback onAddStory;
  final VoidCallback onOpenDMs;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenLiveStream;
  final VoidCallback onOpenCreateCamera;

  const HomeFeedScreen({
    super.key,
    required this.posts,
    required this.stories,
    this.suggestedUsers = const [],
    required this.isLoading,
    required this.onRefresh,
    required this.onLikePost,
    required this.onSavePost,
    required this.onCommentPost,
    required this.onSharePost,
    this.onRepostPost,
    this.onFollowSuggestion,
    this.onDismissSuggestion,
    this.onSelectSuggestedUser,
    this.onAuthorTap,
    required this.onStorySelected,
    required this.onAddStory,
    required this.onOpenDMs,
    required this.onOpenNotifications,
    required this.onOpenLiveStream,
    required this.onOpenCreateCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        elevation: 0,
        title: GestureDetector(
          onTap: onRefresh,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOKYO',
                style: CyberTypography.titleLarge.copyWith(
                  color: CyberColors.primaryHotPink,
                  shadows: CyberColors.pinkGlowShadow(blur: 14),
                ),
              ),
              Text(
                '.GRAM',
                style: CyberTypography.titleLarge.copyWith(
                  color: CyberColors.secondaryCyan,
                  shadows: CyberColors.cyanGlowShadow(blur: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Live Stream Shortcut
          IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.sensors, color: CyberColors.primaryHotPink, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: CyberColors.primaryHotPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            tooltip: 'Live Streams',
            onPressed: onOpenLiveStream,
          ),
          // Notifications Bell/Heart
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 24),
            tooltip: 'Activity',
            onPressed: onOpenNotifications,
          ),
          // Direct Messages
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.send_rounded, color: Colors.white, size: 23),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: CyberColors.pinkGlow,
                      shape: BoxShape.circle,
                      boxShadow: CyberColors.pinkGlowShadow(blur: 6),
                    ),
                    child: Text(
                      '2',
                      style: CyberTypography.hudBadge.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Direct Messages',
            onPressed: onOpenDMs,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: isLoading && posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: CyberColors.secondaryCyan),
            )
          : RefreshIndicator(
              color: CyberColors.primaryHotPink,
              backgroundColor: CyberColors.surfaceDark,
              onRefresh: onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Stories Tray
                  SliverToBoxAdapter(
                    child: StoryTrayWidget(
                      stories: stories,
                      onStorySelected: onStorySelected,
                      onAddStory: onAddStory,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 8),
                  ),

                  // Feed Posts
                  if (posts.isEmpty) ...[
                    if (suggestedUsers.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SuggestedUsersTray(
                          users: suggestedUsers,
                          onFollow: onFollowSuggestion ?? (_) {},
                          onDismiss: onDismissSuggestion ?? (_) {},
                          onSelectUser: onSelectSuggestedUser,
                        ),
                      ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_tethering_off, size: 48, color: CyberColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'NO NEURAL SIGNALS FOUND',
                              style: CyberTypography.hudHeader.copyWith(color: CyberColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Post 0
                    SliverToBoxAdapter(
                      child: PostCardWidget(
                        post: posts[0],
                        onLike: () => onLikePost(posts[0].id),
                        onSave: () => onSavePost(posts[0].id),
                        onComment: () => onCommentPost(posts[0].id),
                        onShare: () => onSharePost(posts[0].id),
                        onRepost: () => onRepostPost?.call(posts[0].id),
                        onAuthorTap: () => onAuthorTap?.call(posts[0].author.id),
                      ),
                    ),

                    // Suggested Users Tray between post 0 and rest of feed
                    if (suggestedUsers.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SuggestedUsersTray(
                          users: suggestedUsers,
                          onFollow: onFollowSuggestion ?? (_) {},
                          onDismiss: onDismissSuggestion ?? (_) {},
                          onSelectUser: onSelectSuggestedUser,
                        ),
                      ),

                    // Remaining Posts from index 1
                    if (posts.length > 1)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = posts[index + 1];
                            return PostCardWidget(
                              post: post,
                              onLike: () => onLikePost(post.id),
                              onSave: () => onSavePost(post.id),
                              onComment: () => onCommentPost(post.id),
                              onShare: () => onSharePost(post.id),
                              onRepost: () => onRepostPost?.call(post.id),
                              onAuthorTap: () => onAuthorTap?.call(post.author.id),
                            );
                          },
                          childCount: posts.length - 1,
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
