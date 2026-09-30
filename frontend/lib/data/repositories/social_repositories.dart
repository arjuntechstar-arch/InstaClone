import '../models/story_model.dart';
import '../models/reel_model.dart';
import '../models/message_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/collection_model.dart';
import '../models/live_model.dart';
import '../services/api_service.dart';

class StoryRepository {
  final ApiService _api;
  StoryRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<StoryItem>> fetchStories() => _api.getStories();
  Future<StoryItem?> votePoll(String storyId, int optionIndex) =>
      _api.votePoll(storyId, optionIndex);
}

class ReelRepository {
  final ApiService _api;
  ReelRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ReelItem>> fetchReels() => _api.getReels();
  Future<Map<String, dynamic>?> toggleLike(String reelId) => _api.likeReel(reelId);
}

class MessageRepository {
  final ApiService _api;
  MessageRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ChatThread>> fetchThreads() => _api.getMessageThreads();
  Future<ChatMessage?> sendMessage(String threadId, Map<String, dynamic> messageData) =>
      _api.sendMessage(threadId, messageData);
}

class CommentRepository {
  final ApiService _api;
  CommentRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<CommentItem>> fetchComments(String postId) => _api.getComments(postId);
  Future<CommentItem?> addComment(String postId, String text, {String? replyToId}) =>
      _api.addComment(postId, text, replyToId: replyToId);
}

class NotificationRepository {
  final ApiService _api;
  NotificationRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<NotificationItem>> fetchNotifications() => _api.getNotifications();
}

class UserRepository {
  final ApiService _api;
  UserRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<UserProfile> fetchMe() => _api.getMe();
  Future<UserProfile?> fetchProfile(String userId) => _api.getUserProfile(userId);
  Future<bool> toggleFollow(String userId) => _api.toggleFollow(userId);
}

class ShopRepository {
  final ApiService _api;
  ShopRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ShopProduct>> fetchProducts({String? category}) =>
      _api.getShopProducts(category: category);
}

class CollectionRepository {
  final ApiService _api;
  CollectionRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<CollectionItem>> fetchCollections() => _api.getCollections();
}

class LiveRepository {
  final ApiService _api;
  LiveRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<LiveStream> fetchLiveStream() => _api.getLiveStream();
  Future<LiveComment?> sendChat(String streamId, String text, {String? giftType}) =>
      _api.sendLiveChat(streamId, text, giftType: giftType);
}

class SettingsRepository {
  final ApiService _api;
  SettingsRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> fetchSettings() => _api.getSettings();
}
