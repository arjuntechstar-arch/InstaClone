/// Models for Saved Collections & Bookmarks
class CollectionItem {
  final String id;
  final String name;
  final String coverUrl;
  final int count;
  final bool isPrivate;

  const CollectionItem({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.count,
    this.isPrivate = true,
  });

  CollectionItem copyWith({
    String? id,
    String? name,
    String? coverUrl,
    int? count,
    bool? isPrivate,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      count: count ?? this.count,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coverUrl': coverUrl,
    'count': count,
    'isPrivate': isPrivate,
  };
}
