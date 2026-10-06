/// Models for User Profile & Public Profile
class GalleryItem {
  final String id;
  final String type; // 'image', 'video'
  final String imageUrl;
  final int likesCount;

  const GalleryItem({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.likesCount,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      imageUrl: json['imageUrl'] as String? ?? '',
      likesCount: json['likesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'imageUrl': imageUrl,
    'likesCount': likesCount,
  };
}

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;
  final bool isVerified;
  final bool isPrivate;
  final bool isFollowRequested;
  final String pronouns;
  final String location;
  final String badge;
  final List<GalleryItem> gallery;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    this.isFollowing = false,
    this.isVerified = false,
    this.isPrivate = false,
    this.isFollowRequested = false,
    this.pronouns = '',
    this.location = '',
    this.badge = 'CYBERPUNK CREATOR',
    this.gallery = const [],
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isFollowing,
    bool? isVerified,
    bool? isPrivate,
    bool? isFollowRequested,
    String? pronouns,
    String? location,
    String? badge,
    List<GalleryItem>? gallery,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      isFollowRequested: isFollowRequested ?? this.isFollowRequested,
      pronouns: pronouns ?? this.pronouns,
      location: location ?? this.location,
      badge: badge ?? this.badge,
      gallery: gallery ?? this.gallery,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: (json['avatarUrl'] ?? json['avatar']) as String? ?? '',
      bio: json['bio'] as String? ?? '',
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFollowRequested: json['isFollowRequested'] as bool? ?? false,
      pronouns: json['pronouns'] as String? ?? '',
      location: (json['location'] ?? json['subNet']) as String? ?? '',
      badge: (json['badge'] ?? json['role'] ?? json['category']) as String? ?? 'CYBER CREATOR',
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((g) => GalleryItem.fromJson(Map<String, dynamic>.from(g)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'postsCount': postsCount,
    'isFollowing': isFollowing,
    'isVerified': isVerified,
    'isPrivate': isPrivate,
    'isFollowRequested': isFollowRequested,
    'pronouns': pronouns,
    'location': location,
    'badge': badge,
    'gallery': gallery.map((g) => g.toJson()).toList(),
  };
}
