import 'feed_model.dart';

/// Models for Comments & Nested Discussion
class CommentItem {
  final String id;
  final String postId;
  final PostAuthor author;
  final String text;
  final String timestamp;
  final int likesCount;
  final bool isLiked;
  final bool isPinned;
  final List<CommentItem> replies;

  const CommentItem({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.timestamp,
    this.likesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.replies = const [],
  });

  CommentItem copyWith({
    String? id,
    String? postId,
    PostAuthor? author,
    String? text,
    String? timestamp,
    int? likesCount,
    bool? isLiked,
    bool? isPinned,
    List<CommentItem>? replies,
  }) {
    return CommentItem(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      replies: replies ?? this.replies,
    );
  }

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    return CommentItem(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      author: json['author'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['author']))
          : const PostAuthor(id: 'unknown', username: 'anon', displayName: 'Anonymous', avatarUrl: ''),
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? 'just now',
      likesCount: json['likesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => CommentItem.fromJson(Map<String, dynamic>.from(r)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'author': author.toJson(),
    'text': text,
    'timestamp': timestamp,
    'likesCount': likesCount,
    'isLiked': isLiked,
    'isPinned': isPinned,
    'replies': replies.map((r) => r.toJson()).toList(),
  };
}
