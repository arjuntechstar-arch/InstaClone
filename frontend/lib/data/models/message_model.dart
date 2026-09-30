import 'feed_model.dart';

/// Models for Direct Messages, Hologram messages, Voice waveforms
class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final String? duration;
  final List<int>? waveform;
  final bool isEncrypted;
  final String timestamp;
  final String type; // 'text', 'voice', 'hologram'

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.duration,
    this.waveform,
    this.isEncrypted = true,
    required this.timestamp,
    this.type = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: json['sender'] as String? ?? '',
      text: json['text'] as String? ?? '',
      duration: json['duration'] as String?,
      waveform: (json['waveform'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      timestamp: json['timestamp'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'text': text,
    'duration': duration,
    'waveform': waveform,
    'isEncrypted': isEncrypted,
    'timestamp': timestamp,
    'type': type,
  };
}

class ChatThread {
  final String id;
  final PostAuthor user;
  final String lastMessage;
  final int unreadCount;
  final bool isEncrypted;
  final bool isPinned;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.unreadCount,
    this.isEncrypted = true,
    this.isPinned = false,
    this.messages = const [],
  });

  ChatThread copyWith({
    String? id,
    PostAuthor? user,
    String? lastMessage,
    int? unreadCount,
    bool? isEncrypted,
    bool? isPinned,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id ?? this.id,
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isPinned: isPinned ?? this.isPinned,
      messages: messages ?? this.messages,
    );
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String? ?? '',
      user: json['user'] != null
          ? PostAuthor.fromJson(Map<String, dynamic>.from(json['user']))
          : const PostAuthor(id: '', username: 'user', displayName: 'User', avatarUrl: ''),
      lastMessage: json['lastMessage'] as String? ?? '',
      unreadCount: json['unreadCount'] as int? ?? 0,
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'lastMessage': lastMessage,
    'unreadCount': unreadCount,
    'isEncrypted': isEncrypted,
    'isPinned': isPinned,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}
