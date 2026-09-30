import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class CommentsDiscussionScreen extends StatefulWidget {
  final String postId;
  final List<CommentItem> comments;
  final Future<void> Function(String text, {String? replyToId}) onAddComment;
  final VoidCallback onClose;

  const CommentsDiscussionScreen({
    super.key,
    required this.postId,
    required this.comments,
    required this.onAddComment,
    required this.onClose,
  });

  @override
  State<CommentsDiscussionScreen> createState() => _CommentsDiscussionScreenState();
}

class _CommentsDiscussionScreenState extends State<CommentsDiscussionScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyingToUsername;
  String? _replyingToId;
  bool _isSubmitting = false;

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await widget.onAddComment(text, replyToId: _replyingToId);

    if (mounted) {
      _commentController.clear();
      setState(() {
        _isSubmitting = false;
        _replyingToId = null;
        _replyingToUsername = null;
      });
    }
  }

  void _setReply(CommentItem comment) {
    setState(() {
      _replyingToId = comment.id;
      _replyingToUsername = comment.author.username;
      _commentController.text = '@${comment.author.username} ';
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: CyberColors.surfaceModal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: CyberColors.borderCyan, width: 1.2),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CyberColors.borderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COMMENTS & DISCUSSION',
                  style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(color: CyberColors.borderSubtle, height: 1),

          // Comments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.comments[index];
                return _buildCommentTile(comment);
              },
            ),
          ),

          // Replying To Banner
          if (_replyingToUsername != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: CyberColors.surfaceDark,
              child: Row(
                children: [
                  Text(
                    'Replying to @$_replyingToUsername',
                    style: CyberTypography.hudCaption.copyWith(color: CyberColors.secondaryCyan),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToId = null;
                        _replyingToUsername = null;
                        _commentController.clear();
                      });
                    },
                    child: const Icon(Icons.close, size: 16, color: CyberColors.textMuted),
                  ),
                ],
              ),
            ),

          // Quick Emoji Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: CyberColors.surfaceDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['❤️', '🔥', '⚡', '🍜', '🚀', '💯'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _commentController.text += emoji;
                    });
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                );
              }).toList(),
            ),
          ),

          // Comment Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: CyberColors.bgVoid,
              border: Border(
                top: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const CyberAvatar(
                    radius: 16,
                    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: CyberTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Add to discussion...',
                        hintStyle: CyberTypography.bodySecondary,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CyberButton(
                    label: 'POST',
                    isSmall: true,
                    isLoading: _isSubmitting,
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentItem comment, {bool isReply = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 14, left: isReply ? 38 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CyberAvatar(
                radius: isReply ? 14 : 17,
                imageUrl: comment.author.avatarUrl,
                isVerified: comment.author.isVerified,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author.username,
                          style: CyberTypography.bodyBold.copyWith(fontSize: 12),
                        ),
                        if (comment.isPinned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: CyberColors.tertiaryYellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: CyberColors.tertiaryYellow, width: 0.6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.push_pin, color: CyberColors.tertiaryYellow, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  'PINNED',
                                  style: CyberTypography.hudBadge.copyWith(
                                    color: CyberColors.tertiaryYellow,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          comment.timestamp,
                          style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: CyberTypography.bodyMedium.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _setReply(comment),
                      child: Text(
                        'Reply',
                        style: CyberTypography.hudCaption.copyWith(
                          color: CyberColors.secondaryCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.favorite_border, size: 16, color: CyberColors.textMuted),
                  if (comment.likesCount > 0)
                    Text(
                      '${comment.likesCount}',
                      style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted),
                    ),
                ],
              ),
            ],
          ),

          // Render nested replies
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => _buildCommentTile(reply, isReply: true)),
        ],
      ),
    );
  }
}
