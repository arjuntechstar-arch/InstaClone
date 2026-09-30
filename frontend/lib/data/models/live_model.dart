import 'feed_model.dart';

/// Models for Cyberpunk Live Streaming, HUD and Floating Particles
class LiveComment {
  final String id;
  final String user;
  final String text;
  final String timestamp;
  final bool isPin;
  final String? giftType; // e.g. 'neon_heart', 'quantum_ramen', 'cyber_drone'

  const LiveComment({
    required this.id,
    required this.user,
    required this.text,
    required this.timestamp,
    this.isPin = false,
    this.giftType,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['id'] as String? ?? '',
      user: json['user'] as String? ?? 'user',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      isPin: json['isPin'] as bool? ?? false,
      giftType: json['giftType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'text': text,
    'timestamp': timestamp,
    'isPin': isPin,
    if (giftType != null) 'giftType': giftType,
  };
}

class LiveStream {
  final String id;
  final PostAuthor host;
  final String title;
  final int viewersCount;
  final bool isLive;
  final List<LiveComment> chatMessages;
  final Map<String, int> reactions;
  final Map<String, dynamic>? currentPoll;

  const LiveStream({
    required this.id,
    required this.host,
    required this.title,
    required this.viewersCount,
    this.isLive = true,
    this.chatMessages = const [],
    this.reactions = const {},
    this.currentPoll,
  });

  LiveStream copyWith({
    String? id,
    PostAuthor? host,
    String? title,
    int? viewersCount,
    bool? isLive,
    List<LiveComment>? chatMessages,
    Map<String, int>? reactions,
    Map<String, dynamic>? currentPoll,
  }) {
    return LiveStream(
      id: id ?? this.id,
      host: host ?? this.host,
      title: title ?? this.title,
      viewersCount: viewersCount ?? this.viewersCount,
      isLive: isLive ?? this.isLive,
      chatMessages: chatMessages ?? this.chatMessages,
      reactions: reactions ?? this.reactions,
      currentPoll: currentPoll ?? this.currentPoll,
    );
  }

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'] as String? ?? '',
      host: json['host'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['host']))
          : const PostAuthor(id: 'host', username: 'streamer', displayName: 'Streamer', avatarUrl: ''),
      title: json['title'] as String? ?? 'NEON STREAM',
      viewersCount: json['viewersCount'] as int? ?? 0,
      isLive: json['isLive'] as bool? ?? true,
      chatMessages: (json['chatMessages'] as List<dynamic>?)
              ?.map((c) => LiveComment.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
      reactions: (json['reactions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      currentPoll: json['currentPoll'] != null
          ? Map<String, dynamic>.from(json['currentPoll'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'host': host.toJson(),
    'title': title,
    'viewersCount': viewersCount,
    'isLive': isLive,
    'chatMessages': chatMessages.map((c) => c.toJson()).toList(),
    'reactions': reactions,
    if (currentPoll != null) 'currentPoll': currentPoll,
  };
}
