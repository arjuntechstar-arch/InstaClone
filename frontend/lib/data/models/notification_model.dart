import 'feed_model.dart';

/// Models for Activity & Push Notifications
class NotificationItem {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'system', 'mention'
  final PostAuthor actor;
  final String message;
  final String? previewUrl;
  final String timestamp;
  final bool isFollowingBack;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.actor,
    required this.message,
    this.previewUrl,
    required this.timestamp,
    this.isFollowingBack = false,
  });

  NotificationItem copyWith({
    String? id,
    String? type,
    PostAuthor? actor,
    String? message,
    String? previewUrl,
    String? timestamp,
    bool? isFollowingBack,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      actor: actor ?? this.actor,
      message: message ?? this.message,
      previewUrl: previewUrl ?? this.previewUrl,
      timestamp: timestamp ?? this.timestamp,
      isFollowingBack: isFollowingBack ?? this.isFollowingBack,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'system',
      actor: json['actor'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['actor']))
          : const PostAuthor(id: 'system', username: 'tokyogram', displayName: 'TOKYO.GRAM', avatarUrl: ''),
      message: json['message'] as String? ?? '',
      previewUrl: json['previewUrl'] as String?,
      timestamp: json['timestamp'] as String? ?? 'just now',
      isFollowingBack: json['isFollowingBack'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'actor': actor.toJson(),
    'message': message,
    if (previewUrl != null) 'previewUrl': previewUrl,
    'timestamp': timestamp,
    'isFollowingBack': isFollowingBack,
  };
}
