/// Models for Story Viewer and Polls
class PollOption {
  final String text;
  final int votes;

  const PollOption({
    required this.text,
    this.votes = 0,
  });

  PollOption copyWith({
    String? text,
    int? votes,
  }) {
    return PollOption(
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      text: json['text'] as String? ?? '',
      votes: json['votes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'votes': votes,
  };
}

class StoryPoll {
  final String question;
  final List<PollOption> options;
  final int? userVoted;

  const StoryPoll({
    required this.question,
    required this.options,
    this.userVoted,
  });

  StoryPoll copyWith({
    String? question,
    List<PollOption>? options,
    int? userVoted,
  }) {
    return StoryPoll(
      question: question ?? this.question,
      options: options ?? this.options,
      userVoted: userVoted ?? this.userVoted,
    );
  }

  factory StoryPoll.fromJson(Map<String, dynamic> json) {
    return StoryPoll(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => PollOption.fromJson(Map<String, dynamic>.from(o)))
              .toList() ??
          [],
      userVoted: json['userVoted'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options.map((o) => o.toJson()).toList(),
    'userVoted': userVoted,
  };
}

class StoryItem {
  final String id;
  final String userId;
  final String username;
  final String avatarUrl;
  final String mediaUrl;
  final String timestamp;
  final bool hasUnseen;
  final StoryPoll? poll;
  final String? musicTrack;
  final String? location;

  const StoryItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.mediaUrl,
    required this.timestamp,
    this.hasUnseen = true,
    this.poll,
    this.musicTrack,
    this.location,
  });

  StoryItem copyWith({
    String? id,
    String? userId,
    String? username,
    String? avatarUrl,
    String? mediaUrl,
    String? timestamp,
    bool? hasUnseen,
    StoryPoll? poll,
    String? musicTrack,
    String? location,
  }) {
    return StoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      hasUnseen: hasUnseen ?? this.hasUnseen,
      poll: poll ?? this.poll,
      musicTrack: musicTrack ?? this.musicTrack,
      location: location ?? this.location,
    );
  }

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    return StoryItem(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '1h ago',
      hasUnseen: json['hasUnseen'] as bool? ?? true,
      poll: json['poll'] != null
          ? StoryPoll.fromJson(Map<String, dynamic>.from(json['poll']))
          : null,
      musicTrack: json['musicTrack'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'username': username,
    'avatarUrl': avatarUrl,
    'mediaUrl': mediaUrl,
    'timestamp': timestamp,
    'hasUnseen': hasUnseen,
    if (poll != null) 'poll': poll!.toJson(),
    if (musicTrack != null) 'musicTrack': musicTrack,
    if (location != null) 'location': location,
  };
}
