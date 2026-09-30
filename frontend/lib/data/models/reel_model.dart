import 'feed_model.dart';

/// Models for Fullscreen Cyber Reels
class ReelItem {
  final String id;
  final PostAuthor author;
  final String videoUrl;
  final String caption;
  final String musicTrack;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;

  const ReelItem({
    required this.id,
    required this.author,
    required this.videoUrl,
    required this.caption,
    required this.musicTrack,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowing = false,
  });

  ReelItem copyWith({
    String? id,
    PostAuthor? author,
    String? videoUrl,
    String? caption,
    String? musicTrack,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
  }) {
    return ReelItem(
      id: id ?? this.id,
      author: author ?? this.author,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      musicTrack: musicTrack ?? this.musicTrack,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  factory ReelItem.fromJson(Map<String, dynamic> json) {
    return ReelItem(
      id: json['id'] as String? ?? '',
      author: json['author'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['author']))
          : const PostAuthor(id: 'unknown', username: 'unknown', displayName: 'Unknown', avatarUrl: ''),
      videoUrl: json['videoUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      musicTrack: json['musicTrack'] as String? ?? '',
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'videoUrl': videoUrl,
    'caption': caption,
    'musicTrack': musicTrack,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'sharesCount': sharesCount,
    'isLiked': isLiked,
    'isSaved': isSaved,
    'isFollowing': isFollowing,
  };
}
