import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../widgets/post_card_widget.dart';

/// Full Post Detail Viewer Screen matching Instagram's detail view
class PostDetailScreen extends StatelessWidget {
  final PostItem post;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onAuthorTap;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'POST TELEMETRY',
          style: CyberTypography.hudHeader.copyWith(
            color: CyberColors.secondaryCyan,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: PostCardWidget(
          post: post,
          onLike: onLike,
          onSave: onSave,
          onComment: onComment,
          onShare: onShare,
          onAuthorTap: onAuthorTap,
        ),
      ),
    );
  }
}
