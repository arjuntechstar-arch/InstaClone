import 'package:flutter/material.dart';
import '../../data/models/story_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class StoryTrayWidget extends StatelessWidget {
  final List<StoryItem> stories;
  final ValueChanged<StoryItem> onStorySelected;
  final VoidCallback onAddStory;

  const StoryTrayWidget({
    super.key,
    required this.stories,
    required this.onStorySelected,
    required this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: CyberColors.bgVoid,
        border: Border(
          bottom: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Your Story" item with plus badge
            return GestureDetector(
              onTap: onAddStory,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CyberAvatar(
                        radius: 28,
                        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                        hasStory: false,
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: CyberColors.pinkGlow,
                          shape: BoxShape.circle,
                          boxShadow: CyberColors.pinkGlowShadow(blur: 6),
                          border: Border.all(color: CyberColors.bgVoid, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your Story',
                    style: CyberTypography.bodySecondary.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }

          final story = stories[index - 1];
          return GestureDetector(
            onTap: () => onStorySelected(story),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CyberAvatar(
                  radius: 28,
                  imageUrl: story.avatarUrl,
                  hasStory: true,
                  hasUnseenStory: story.hasUnseen,
                  isLive: story.userId == 'u3', // Live tag simulation for Kira
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 64,
                  child: Text(
                    story.username,
                    style: CyberTypography.bodySecondary.copyWith(
                      fontSize: 11,
                      color: story.hasUnseen ? CyberColors.textPrimary : CyberColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
