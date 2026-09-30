import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/story_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryItem> stories;
  final int initialIndex;
  final Function(String storyId, int optionIndex) onVotePoll;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    required this.onVotePoll,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int _currentIndex;
  Timer? _progressTimer;
  double _currentProgress = 0.0;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _startStoryTimer();
  }

  void _startStoryTimer() {
    _progressTimer?.cancel();
    _currentProgress = 0.0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _currentProgress += 0.01;
        if (_currentProgress >= 1.0) {
          _advanceStory();
        }
      });
    });
  }

  void _advanceStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _startStoryTimer();
      });
    } else {
      _progressTimer?.cancel();
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _startStoryTimer();
      });
    } else {
      setState(() {
        _currentProgress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const Scaffold(backgroundColor: CyberColors.bgVoid);
    }

    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Background Media Image
            Positioned.fill(
              child: GestureDetector(
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < width * 0.35) {
                    _previousStory();
                  } else {
                    _advanceStory();
                  }
                },
                child: Image.network(
                  story.mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: CyberColors.surfaceElevated,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64, color: CyberColors.textMuted),
                    ),
                  ),
                ),
              ),
            ),

            // Top gradient vignette for contrast
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 2. Top Progress Indicators
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  double value;
                  if (index < _currentIndex) {
                    value = 1.0;
                  } else if (index == _currentIndex) {
                    value = _currentProgress;
                  } else {
                    value = 0.0;
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CyberColors.secondaryCyan,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: CyberColors.cyanGlowShadow(blur: 6),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 3. Author Info Header
            Positioned(
              top: 22,
              left: 14,
              right: 14,
              child: Row(
                children: [
                  CyberAvatar(
                    radius: 17,
                    imageUrl: story.avatarUrl,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    story.username,
                    style: CyberTypography.bodyBold.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    story.timestamp,
                    style: CyberTypography.hudCaption.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 4. Interactive Poll Widget Overlay
            if (story.poll != null)
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height * 0.45,
                child: _buildInteractivePoll(story),
              ),

            // 5. Bottom Reply Field & Reaction Shortcuts
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: CyberColors.bgVoid.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: CyberColors.borderSubtle, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              style: CyberTypography.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'Send neural packet...',
                                hintStyle: CyberTypography.bodySecondary.copyWith(color: Colors.white54),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: CyberColors.secondaryCyan, size: 20),
                            onPressed: () {
                              if (_replyController.text.trim().isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: CyberColors.surfaceModal,
                                    content: Text('Neural packet sent to @${story.username}'),
                                  ),
                                );
                                _replyController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickEmoji('❤️'),
                  _buildQuickEmoji('🔥'),
                  _buildQuickEmoji('⚡'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEmoji(String emoji) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CyberColors.surfaceModal,
            duration: const Duration(seconds: 1),
            content: Text('$emoji reaction transmitted!'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: CyberColors.bgVoid.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          border: Border.all(color: CyberColors.borderSubtle, width: 1),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildInteractivePoll(StoryItem story) {
    final poll = story.poll!;
    final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.votes);
    final hasVoted = poll.userVoted != null;

    return CyberCard(
      backgroundColor: CyberColors.surfaceModal.withValues(alpha: 0.9),
      borderColor: CyberColors.secondaryCyan.withValues(alpha: 0.7),
      hasGlow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.poll_rounded, color: CyberColors.tertiaryYellow, size: 18),
              const SizedBox(width: 6),
              const Text('NEURAL POLL', style: TextStyle(color: CyberColors.tertiaryYellow, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            poll.question,
            style: CyberTypography.titleSmall.copyWith(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ...List.generate(poll.options.length, (idx) {
            final option = poll.options[idx];
            final percent = totalVotes > 0 ? (option.votes / totalVotes * 100).round() : 50;
            final isChosen = poll.userVoted == idx;

            return GestureDetector(
              onTap: hasVoted
                  ? null
                  : () {
                      widget.onVotePoll(story.id, idx);
                      setState(() {});
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isChosen
                        ? CyberColors.primaryHotPink
                        : CyberColors.borderHighlight,
                    width: isChosen ? 1.8 : 1.0,
                  ),
                  color: CyberColors.surfaceDark,
                ),
                child: Stack(
                  children: [
                    if (hasVoted)
                      FractionallySizedBox(
                        widthFactor: (percent / 100.0).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: idx == 0
                                ? CyberColors.cyanGlow.withOpacity(0.35)
                                : CyberColors.pinkGlow.withOpacity(0.35),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isChosen)
                                const Icon(Icons.check_circle, color: CyberColors.primaryHotPink, size: 16),
                              if (isChosen) const SizedBox(width: 6),
                              Text(
                                option.text,
                                style: CyberTypography.bodyBold.copyWith(
                                  color: isChosen ? Colors.white : CyberColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (hasVoted)
                            Text(
                              '$percent%',
                              style: CyberTypography.hudMetric.copyWith(
                                fontSize: 13,
                                color: idx == 0 ? CyberColors.secondaryCyan : CyberColors.primaryHotPink,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}


