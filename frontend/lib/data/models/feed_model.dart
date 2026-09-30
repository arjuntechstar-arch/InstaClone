/// Models for Feed and Posts matching backend schema
class PostAuthor {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isVerified;

  const PostAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isVerified = false,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? 'user',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'isVerified': isVerified,
  };
}

class PostItem {
  final String id;
  final PostAuthor author;
  final String mediaUrl;
  final String caption;
  final String timestamp;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final String musicTrack;
  final String location;
  final String filterName;
  final List<String> tags;

  const PostItem({
    required this.id,
    required this.author,
    required this.mediaUrl,
    required this.caption,
    required this.timestamp,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.musicTrack = '',
    this.location = '',
    this.filterName = 'Normal',
    this.tags = const [],
  });

  PostItem copyWith({
    String? id,
    PostAuthor? author,
    String? mediaUrl,
    String? caption,
    String? timestamp,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    String? musicTrack,
    String? location,
    String? filterName,
    List<String>? tags,
  }) {
    return PostItem(
      id: id ?? this.id,
      author: author ?? this.author,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      musicTrack: musicTrack ?? this.musicTrack,
      location: location ?? this.location,
      filterName: filterName ?? this.filterName,
      tags: tags ?? this.tags,
    );
  }

  factory PostItem.fromJson(Map<String, dynamic> json) {
    return PostItem(
      id: json['id'] as String? ?? '',
      author: json['author'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['author']))
          : const PostAuthor(id: 'unknown', username: 'unknown', displayName: 'Unknown', avatarUrl: ''),
      mediaUrl: json['mediaUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? 'just now',
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      musicTrack: json['musicTrack'] as String? ?? '',
      location: json['location'] as String? ?? '',
      filterName: json['filterName'] as String? ?? 'Normal',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'mediaUrl': mediaUrl,
    'caption': caption,
    'timestamp': timestamp,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'isLiked': isLiked,
    'isSaved': isSaved,
    'musicTrack': musicTrack,
    'location': location,
    'filterName': filterName,
    'tags': tags,
  };
}
