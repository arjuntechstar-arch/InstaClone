import '../models/feed_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class FeedRepository {
  final ApiService _api;
  FeedRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<PostItem>> fetchFeed({int page = 1, int limit = 10}) {
    return _api.getFeed(page: page, limit: limit);
  }

  Future<Map<String, dynamic>?> toggleLike(String postId) {
    return _api.likePost(postId);
  }

  Future<bool> toggleSave(String postId) {
    return _api.savePost(postId);
  }

  Future<Map<String, dynamic>?> toggleRepost(String postId) {
    return _api.repostPost(postId);
  }

  Future<List<UserProfile>> fetchSuggestedUsers() {
    return _api.getSuggestedUsers();
  }

  Future<PostItem?> createPost({
    required String caption,
    required String mediaUrl,
    String? location,
    String? musicTrack,
    String? filterName,
    List<String> tags = const [],
  }) {
    return _api.createPost({
      'caption': caption,
      'mediaUrl': mediaUrl,
      'location': location ?? '',
      'musicTrack': musicTrack ?? '',
      'filterName': filterName ?? 'Normal',
      'tags': tags,
    });
  }
}

