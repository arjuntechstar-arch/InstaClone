import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/feed_model.dart';
import '../models/story_model.dart';
import '../models/reel_model.dart';
import '../models/message_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/collection_model.dart';
import '../models/live_model.dart';

/// Senior Architecture API Service with cross-platform URL resolution & resilient offline fallback
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _envApiUrl = String.fromEnvironment('API_URL');

  /// Default Base URL dynamically chosen depending on environment variable, web query parameter, or platform
  static String get defaultBaseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl.replaceAll(RegExp(r'/+$'), '');
    }
    if (kIsWeb) {
      try {
        final uri = Uri.base;
        final queryParam = uri.queryParameters['apiUrl'] ?? uri.queryParameters['api'];
        if (queryParam != null && queryParam.isNotEmpty) {
          return queryParam.replaceAll(RegExp(r'/+$'), '');
        }
      } catch (_) {}
      return 'http://localhost:4000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  String baseUrl = defaultBaseUrl;

  void setBaseUrl(String url) {
    baseUrl = url.replaceAll(RegExp(r'/+$'), '');
  }

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ===================== AUTHENTICATION & ROLES =====================
  static const List<Map<String, dynamic>> defaultRoles = [
    {
      'id': 'u1',
      'username': 'cyber_ren',
      'displayName': 'Ren Tanaka',
      'role': 'Creator / Photographer',
      'accessLevel': 5,
      'passkey': 'neon_ren_2088',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      'bio': 'Cybernetic optics architect & nightscape photographer. ⚡🌆 Shooting Neo-Tokyo at 03:00 AM.',
      'badge': 'VERIFIED CREATOR',
      'isVerified': true,
    },
    {
      'id': 'u2',
      'username': 'neon_kaito',
      'displayName': 'Kaito Vance',
      'role': 'Cyber Modder / Crypto Specialist',
      'accessLevel': 4,
      'passkey': 'quantum_kaito_42',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      'bio': 'Overclocking quantum cyberdecks & neural relays. 🦾 Akihabara Underground Sector 9.',
      'badge': 'VERIFIED MODDER',
      'isVerified': true,
    },
    {
      'id': 'u3',
      'username': 'kira_synth',
      'displayName': 'Kira Oshiro',
      'role': 'Live Streamer / Audio DJ',
      'accessLevel': 5,
      'passkey': 'synth_kira_99',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300',
      'bio': 'Synthwave audio producer & live holographic streamer. 🎧⚡ 140BPM pure cyber vibes.',
      'badge': 'BROADCAST HOST',
      'isVerified': true,
    },
    {
      'id': 'u4',
      'username': 'neotech_admin',
      'displayName': 'NeoTech Corp',
      'role': 'Marketplace Merchant / Brand Partner',
      'accessLevel': 3,
      'passkey': 'neotech_drop_77',
      'avatar': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300',
      'bio': 'Official Neo-Tokyo cyberware distributor. Tactical visors, cyberdecks & neural suits. 🛒⚡',
      'badge': 'OFFICIAL MERCHANT',
      'isVerified': true,
    },
    {
      'id': 'guest',
      'username': 'anon_mesh',
      'displayName': 'Anonymous Explorer',
      'role': 'Consumer / Guest User',
      'accessLevel': 1,
      'passkey': 'guest_token_00',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
      'bio': 'Wandering through the digital neon fog. Unregistered neural link node. 🌐',
      'badge': 'GUEST NODE',
      'isVerified': false,
    },
  ];

  Future<List<Map<String, dynamic>>> getAuthRoles() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/auth/roles'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['roles'] as List<dynamic>?) ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getAuthRoles fallback: $e');
    }
    return defaultRoles;
  }

  Future<UserProfile?> login(String username, String passkey) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'passkey': passkey}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final userMap = data['user'] ?? data['data'];
        if (userMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(userMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] login fallback: $e');
    }
    final match = defaultRoles.firstWhere(
      (r) => (r['username'] as String).toLowerCase() == username.toLowerCase() && r['passkey'] == passkey,
      orElse: () => {},
    );
    if (match.isNotEmpty) {
      return UserProfile.fromJson(Map<String, dynamic>.from(match));
    }
    return null;
  }

  Future<UserProfile?> register({
    required String username,
    required String passkey,
    String? displayName,
    String? role,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'passkey': passkey,
          'displayName': displayName,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final userMap = data['user'] ?? data['data'];
        if (userMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(userMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] register fallback: $e');
    }
    return UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      displayName: displayName ?? username,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
      bio: 'Newly registered on Tokyo.Gram grid. ⚡',
      badge: 'INITIATE',
      followersCount: 1,
      followingCount: 1,
      postsCount: 0,
      isVerified: false,
    );
  }

  Future<UserProfile?> switchPersona(String username) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/auth/switch-persona'),
        headers: _headers,
        body: jsonEncode({'username': username}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final userMap = data['user'] ?? data['data'];
        if (userMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(userMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] switchPersona fallback: $e');
    }
    final match = defaultRoles.firstWhere(
      (r) => (r['username'] as String).toLowerCase() == username.toLowerCase(),
      orElse: () => {},
    );
    if (match.isNotEmpty) {
      return UserProfile.fromJson(Map<String, dynamic>.from(match));
    }
    return null;
  }

  // ===================== FEED =====================
  Future<List<PostItem>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/feed?page=$page&limit=$limit'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = ((data['posts'] ?? data['data']) as List<dynamic>?) ?? [];
        return list.map((e) => PostItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getFeed fallback: $e');
    }
    return _fallbackFeed;
  }

  Future<Map<String, dynamic>?> likePost(String postId) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/feed/$postId/like'),
        headers: _headers,
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] likePost fallback: $e');
    }
    return null;
  }

  final Set<String> _fallbackSavedPostIds = {'post_1'};
  Future<bool> savePost(String postId) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/feed/$postId/save'),
        headers: _headers,
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['isSaved'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('[ApiService] savePost fallback: $e');
    }
    if (_fallbackSavedPostIds.contains(postId)) {
      _fallbackSavedPostIds.remove(postId);
      return false;
    } else {
      _fallbackSavedPostIds.add(postId);
      return true;
    }
  }

  Future<Map<String, dynamic>?> repostPost(String postId) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/feed/$postId/repost'),
        headers: _headers,
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] repostPost fallback: $e');
    }
    return null;
  }


  Future<PostItem?> createPost(Map<String, dynamic> postData) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/feed'),
        headers: _headers,
        body: jsonEncode(postData),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return PostItem.fromJson(Map<String, dynamic>.from(data['post']));
      }
    } catch (e) {
      debugPrint('[ApiService] createPost fallback: $e');
    }
    return PostItem.fromJson({
      'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
      'author': {
        'id': 'u1',
        'username': 'cyber_ren',
        'displayName': 'Ren Tanaka',
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'isVerified': true
      },
      ...postData,
      'timestamp': 'Just now',
      'likesCount': 0,
      'commentsCount': 0,
    });
  }

  // ===================== STORIES =====================
  Future<List<StoryItem>> getStories() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/stories'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['stories'] as List<dynamic>?) ?? [];
        return list.map((e) => StoryItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getStories fallback: $e');
    }
    return _fallbackStories;
  }

  Future<StoryItem?> votePoll(String storyId, int optionIndex) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/stories/$storyId/vote'),
        headers: _headers,
        body: jsonEncode({'optionIndex': optionIndex}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return StoryItem.fromJson(Map<String, dynamic>.from(data['story']));
      }
    } catch (e) {
      debugPrint('[ApiService] votePoll fallback: $e');
    }
    return null;
  }

  // ===================== REELS =====================
  Future<List<ReelItem>> getReels() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/reels'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['reels'] as List<dynamic>?) ?? [];
        return list.map((e) => ReelItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getReels fallback: $e');
    }
    return _fallbackReels;
  }

  Future<Map<String, dynamic>?> likeReel(String reelId) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/reels/$reelId/like'),
        headers: _headers,
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] likeReel fallback: $e');
    }
    return null;
  }

  // ===================== EXPLORE =====================
  Future<Map<String, dynamic>> getExplore({String? query, String? tag}) async {
    try {
      final q = query != null ? 'q=$query' : (tag != null ? 'tag=$tag' : '');
      final res = await _client.get(Uri.parse('$baseUrl/api/explore?$q'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] getExplore fallback: $e');
    }
    return _fallbackExplore;
  }

  // ===================== MESSAGES =====================
  // ===================== MESSAGES =====================
  Future<List<ChatThread>> getMessageThreads() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/messages'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['threads'] ?? data['data']) as List<dynamic>? ?? [];
        return list.map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getMessageThreads fallback: $e');
    }
    return _fallbackThreads;
  }

  Future<ChatThread?> startChatThread(String participantUsername) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/messages/start'),
        headers: _headers,
        body: jsonEncode({'participantUsername': participantUsername}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final threadData = data['thread'] ?? data['data'];
        if (threadData != null) {
          return ChatThread.fromJson(Map<String, dynamic>.from(threadData));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] startChatThread error: $e');
    }
    return null;
  }

  Future<ChatMessage?> sendMessage(String threadId, Map<String, dynamic> messageData) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/messages/$threadId'),
        headers: _headers,
        body: jsonEncode(messageData),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final msgData = data['message'] ?? data['data'];
        if (msgData != null) {
          return ChatMessage.fromJson(Map<String, dynamic>.from(msgData));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] sendMessage fallback: $e');
    }
    return ChatMessage.fromJson({
      'id': 'm_${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'me',
      ...messageData,
      'timestamp': 'Just now',
    });
  }

  // ===================== COMMENTS =====================
  Future<List<CommentItem>> getComments(String postId) async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/comments/$postId'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['comments'] ?? data['data']) as List<dynamic>? ?? [];
        return list.map((e) => CommentItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getComments fallback: $e');
    }
    return _fallbackComments;
  }

  Future<CommentItem?> addComment(String postId, String text, {String? replyToId, Map<String, dynamic>? user}) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/comments/$postId'),
        headers: _headers,
        body: jsonEncode({
          'text': text,
          'replyToId': replyToId,
          'parentCommentId': replyToId,
          if (user != null) 'user': user,
        }),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final commentData = data['comment'] ?? data['data'];
        if (commentData != null) {
          return CommentItem.fromJson(Map<String, dynamic>.from(commentData));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] addComment fallback: $e');
    }
    return CommentItem(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      author: const PostAuthor(
        id: 'u1',
        username: 'cyber_ren',
        displayName: 'Ren Tanaka',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        isVerified: true,
      ),
      text: text,
      timestamp: 'Just now',
    );
  }

  // ===================== NOTIFICATIONS =====================
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/notifications'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['notifications'] as List<dynamic>?) ?? [];
        return list.map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getNotifications fallback: $e');
    }
    return _fallbackNotifications;
  }

  // ===================== USERS & PROFILE =====================
  Future<UserProfile> getMe() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/users/me'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final profileMap = data['profile'] ?? data['data'];
        if (profileMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(profileMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] getMe fallback: $e');
    }
    return _fallbackProfile;
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/users/$userId'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final profileMap = data['profile'] ?? data['data'];
        if (profileMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(profileMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] getUserProfile fallback: $e');
    }
    return null;
  }

  Future<UserProfile?> updateProfile(Map<String, dynamic> updates) async {
    try {
      final res = await _client.put(
        Uri.parse('$baseUrl/api/users/me'),
        headers: _headers,
        body: jsonEncode(updates),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final profileMap = data['profile'] ?? data['data'];
        if (profileMap != null) {
          return UserProfile.fromJson(Map<String, dynamic>.from(profileMap));
        }
      }
    } catch (e) {
      debugPrint('[ApiService] updateProfile fallback: $e');
    }
    return null;
  }


  Future<List<UserProfile>> getSuggestedUsers() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/users/suggestions'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?) ?? [];
        return list.map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getSuggestedUsers fallback: $e');
    }
    return _fallbackSuggestedUsers;
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/users'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['users'] ?? data['data']) as List<dynamic>? ?? [];
        return list.map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getAllUsers fallback: $e');
    }
    return _fallbackSuggestedUsers;
  }

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final q = Uri.encodeQueryComponent(query);
      final res = await _client
          .get(Uri.parse('$baseUrl/api/explore/search?q=$q'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final resData = data['data'] as Map<String, dynamic>? ?? {};
        final rawUsers = (resData['users'] as List<dynamic>?) ?? [];
        final users = rawUsers.map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e))).toList();
        return {
          'users': users,
          'posts': resData['posts'] ?? [],
          'exploreItems': resData['exploreItems'] ?? [],
        };
      }
    } catch (e) {
      debugPrint('[ApiService] search fallback: $e');
    }
    return {'users': <UserProfile>[], 'posts': [], 'exploreItems': []};
  }

  Future<Map<String, dynamic>?> toggleFollow(String userId) async {
    try {
      final res = await _client.post(Uri.parse('$baseUrl/api/users/$userId/follow'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ApiService] toggleFollow fallback: $e');
    }
    return null;
  }

  // ===================== SHOP =====================
  Future<List<ShopProduct>> getShopProducts({String? category}) async {
    try {
      final q = category != null ? '?category=$category' : '';
      final res = await _client.get(Uri.parse('$baseUrl/api/shop$q'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['products'] as List<dynamic>?) ?? [];
        return list.map((e) => ShopProduct.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getShopProducts fallback: $e');
    }
    return _fallbackProducts;
  }

  // ===================== COLLECTIONS =====================
  Future<List<CollectionItem>> getCollections() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/collections'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['collections'] as List<dynamic>?) ?? [];
        return list.map((e) => CollectionItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getCollections fallback: $e');
    }
    return _fallbackCollections;
  }

  // ===================== LIVE STREAM =====================
  Future<LiveStream> getLiveStream() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/live/live_1'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return LiveStream.fromJson(Map<String, dynamic>.from(data['stream']));
      }
    } catch (e) {
      debugPrint('[ApiService] getLiveStream fallback: $e');
    }
    return _fallbackLiveStream;
  }

  Future<LiveComment?> sendLiveChat(String streamId, String text, {String? giftType}) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/live/$streamId/chat'),
        headers: _headers,
        body: jsonEncode({'text': text, 'giftType': giftType}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return LiveComment.fromJson(Map<String, dynamic>.from(data['comment']));
      }
    } catch (e) {
      debugPrint('[ApiService] sendLiveChat fallback: $e');
    }
    return LiveComment(
      id: 'lc_${DateTime.now().millisecondsSinceEpoch}',
      user: 'cyber_ren',
      text: text,
      timestamp: 'Just now',
      giftType: giftType,
    );
  }

  // ===================== SETTINGS =====================
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/settings'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['settings'] as Map<String, dynamic>?) ?? {};
      }
    } catch (e) {
      debugPrint('[ApiService] getSettings fallback: $e');
    }
    return {
      'cyberOpticsMode': 'Neon Vivid',
      'quantumEncryption': true,
      'hologramPreview': true,
      'biometricAuth': true,
      'hapticFeedback': true,
      'dataTransmission': 'Neural Mesh',
      'stealthMode': false,
    };
  }

  // ===================== FALLBACK SEED DATA =====================
  static final List<PostItem> _fallbackFeed = [
    PostItem.fromJson({
      'id': 'post_1',
      'author': {
        'id': 'u1',
        'username': 'cyber_ren',
        'displayName': 'Ren Tanaka',
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        'isVerified': true
      },
      'mediaUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=800',
      'caption': 'Neon drenched alleys of Shinjuku Sector 4. The rain never stops the signals. #cyberpunk #tokyo #neon #nightscape',
      'timestamp': '12m ago',
      'likesCount': 2841,
      'commentsCount': 148,
      'isLiked': true,
      'isSaved': true,
      'musicTrack': 'Kavinsky - Nightcall (Synthwave Rework)',
      'location': 'Shinjuku Sector 4, Neo-Tokyo',
      'filterName': 'Neon Glitch',
      'tags': ['cyberpunk', 'tokyo', 'neon', 'nightscape']
    }),
    PostItem.fromJson({
      'id': 'post_2',
      'author': {
        'id': 'u2',
        'username': 'neon_kaito',
        'displayName': 'Kaito Vance',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'isVerified': true
      },
      'mediaUrl': 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=800',
      'caption': 'Overclocked neural implant synced with Shibuya skygrid. Zero latency living. ⚡📡',
      'timestamp': '2h ago',
      'likesCount': 5120,
      'commentsCount': 389,
      'isLiked': false,
      'isSaved': false,
      'musicTrack': 'Perturbator - Future Club',
      'location': 'Shibuya Crossing Sky-Bridge',
      'filterName': 'Cyan Glow',
      'tags': ['shibuya', 'neuralnet', 'overclock']
    }),
  ];

  static final List<StoryItem> _fallbackStories = [
    StoryItem.fromJson({
      'id': 'story_1',
      'userId': 'u1',
      'username': 'cyber_ren',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      'mediaUrl': 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800',
      'timestamp': '45m ago',
      'hasUnseen': true,
      'poll': {
        'question': 'Which optics enhancement should I install next?',
        'options': [
          {'text': 'Cyan Thermal HUD', 'votes': 428},
          {'text': 'Hot Pink UV Spectrum', 'votes': 312}
        ],
        'userVoted': null
      }
    }),
    StoryItem.fromJson({
      'id': 'story_2',
      'userId': 'u3',
      'username': 'kira_synth',
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      'mediaUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
      'timestamp': '1h ago',
      'hasUnseen': true,
    }),
  ];

  static final List<ReelItem> _fallbackReels = [
    ReelItem.fromJson({
      'id': 'reel_1',
      'author': {
        'id': 'u3',
        'username': 'kira_synth',
        'displayName': 'Kira Oshiro',
        'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        'isVerified': true
      },
      'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-futuristic-city-with-flying-cars-and-skyscrapers-41618-large.mp4',
      'caption': 'Drifting through Akihabara Level 7 sky-lanes. Anti-grav turbo running at 140% capacity! 🏎️💨 #drift #cybercar #akiba',
      'musicTrack': 'Carpenter Brut - Turbo Killer',
      'likesCount': 42890,
      'commentsCount': 1204,
      'sharesCount': 5890,
      'isLiked': true,
      'isSaved': false,
      'isFollowing': true
    }),
  ];

  static final Map<String, dynamic> _fallbackExplore = {
    'trendingTags': ['#NeoTokyo', '#CyberdeckMod', '#SynthwaveBeats', '#HoloFashion', '#NeuralArt'],
    'gridItems': [
      {'id': 'exp_1', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500', 'likesCount': 1420},
      {'id': 'exp_2', 'type': 'video', 'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500', 'likesCount': 3890},
      {'id': 'exp_3', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=500', 'likesCount': 2400},
    ]
  };

  static final List<ChatThread> _fallbackThreads = [
    ChatThread.fromJson({
      'id': 'thread_1',
      'user': {
        'id': 'u2',
        'username': 'neon_kaito',
        'displayName': 'Kaito Vance',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'isVerified': true
      },
      'lastMessage': 'The encrypted neural payload is ready for decrypt. 📡',
      'unreadCount': 2,
      'isEncrypted': true,
      'isPinned': true,
      'messages': [
        {'id': 'm1', 'sender': 'kaito', 'text': 'Are you near the Roppongi junction?', 'timestamp': '10:14 PM', 'type': 'text'},
        {'id': 'm2', 'sender': 'me', 'text': 'Yeah, by the holo ramen stand.', 'timestamp': '10:15 PM', 'type': 'text'},
        {'id': 'm3', 'sender': 'kaito', 'text': 'Voice stream incoming:', 'duration': '0:14', 'waveform': [20, 50, 80, 45, 90, 60, 30, 75, 40, 95], 'timestamp': '10:16 PM', 'type': 'voice'},
      ]
    })
  ];

  static final List<CommentItem> _fallbackComments = [
    CommentItem.fromJson({
      'id': 'c1',
      'postId': 'post_1',
      'author': {
        'id': 'u2',
        'username': 'neon_kaito',
        'displayName': 'Kaito Vance',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'isVerified': true
      },
      'text': 'The volumetric bloom on the wet tarmac is unmatched! Which lens filter was this?',
      'timestamp': '10m ago',
      'likesCount': 42,
      'isLiked': true,
      'isPinned': true,
      'replies': [
        {
          'id': 'c1_r1',
          'postId': 'post_1',
          'author': {
            'id': 'u1',
            'username': 'cyber_ren',
            'displayName': 'Ren Tanaka',
            'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            'isVerified': true
          },
          'text': 'Custom anamorphic prism with ISO 3200 gain! 🔥',
          'timestamp': '6m ago',
          'likesCount': 12,
          'isLiked': false,
          'isPinned': false,
          'replies': []
        }
      ]
    })
  ];

  static final List<NotificationItem> _fallbackNotifications = [
    NotificationItem.fromJson({
      'id': 'n1',
      'type': 'like',
      'actor': {
        'id': 'u3',
        'username': 'kira_synth',
        'displayName': 'Kira Oshiro',
        'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        'isVerified': true
      },
      'message': 'liked your neural snapshot from Shinjuku Sector 4',
      'previewUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=150',
      'timestamp': '3m ago',
      'isFollowingBack': false
    })
  ];

  static final UserProfile _fallbackProfile = UserProfile.fromJson({
    'id': 'u1',
    'username': 'cyber_ren',
    'displayName': 'Ren Tanaka',
    'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
    'bio': 'Cybernetic optics architect & nightscape photographer. Capturing the neon pulse of Neo-Tokyo 2088. ⚡🌆',
    'followersCount': 142800,
    'followingCount': 492,
    'postsCount': 187,
    'isFollowing': false,
    'isVerified': true,
    'pronouns': 'they/them',
    'location': 'Neo-Tokyo, Sector 03',
    'badge': 'VERIFIED CREATOR',
    'gallery': [
      {'id': 'g1', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=500', 'likesCount': 2841},
      {'id': 'g2', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=500', 'likesCount': 3490},
      {'id': 'g3', 'type': 'video', 'imageUrl': 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=500', 'likesCount': 5120},
    ]
  });

  static final List<ShopProduct> _fallbackProducts = [
    ShopProduct.fromJson({
      'id': 'p1',
      'title': 'Tactical Holo-Visor V3',
      'price': 249.99,
      'brand': 'NEO-TECH CORP',
      'imageUrl': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500',
      'inStock': true,
      'isWishlisted': false,
      'category': 'Optics',
      'rating': 4.9
    })
  ];

  static final List<CollectionItem> _fallbackCollections = [
    CollectionItem.fromJson({
      'id': 'col_1',
      'name': 'Neon Inspo 2088',
      'coverUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=400',
      'count': 34,
      'isPrivate': false
    })
  ];

  static final LiveStream _fallbackLiveStream = LiveStream.fromJson({
    'id': 'live_1',
    'host': {
      'id': 'u3',
      'username': 'kira_synth',
      'displayName': 'Kira Oshiro',
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      'isVerified': true
    },
    'title': 'Midnight Rooftop DJ Set & Cyber Synth Jam 🎧⚡',
    'viewersCount': 18420,
    'isLive': true,
    'chatMessages': [
      {'id': 'lm1', 'user': 'neon_kaito', 'text': 'The sub-bass drop is vibrating my neural interface! 🔥', 'timestamp': '10:45 PM', 'isPin': true},
      {'id': 'lm2', 'user': 'cyber_ren', 'text': 'Streaming this live to Shinjuku main square! 🚀', 'timestamp': '10:46 PM', 'isPin': false, 'giftType': 'neon_heart'},
    ],
    'reactions': {'heart': 4892, 'flame': 3104, 'neon': 1920},
  });

  static final List<UserProfile> _fallbackSuggestedUsers = [
    UserProfile.fromJson({
      'id': 'usr_kira',
      'username': 'k1ra_neo',
      'displayName': 'Kira // 雲雀 キラ',
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVVHe-EHFdcdYsnnBWVT8tvj-puFT-ibf-GfvABu1OtzzMK8LTk9wJmUYNfrasFseqOM9i7e6s9Vm4JbNSfYnmQ_LIk1vjf0UiPMpOaJrSLOxtxKGKcaY3UGvL65qiURdmfzZA1FlVMHn_k7JF0If7ki89fof9qC8YGk1TOfgWAO8gtv-4VY6dAtcnlf4VIbBc7FuKEYgDTQZqTywlCCPs8HmgooVeBMtaYe6jtvUDQDKfrqO_M5NQ',
      'badge': 'SYNTHWAVE PRODUCER',
      'isVerified': true,
      'isFollowing': false,
      'isPrivate': false,
      'followersCount': 182400,
      'followingCount': 319,
      'postsCount': 248,
      'bio': 'Sound designer @kurogane_audio 🎛️ Glitch in the neon matrix.',
    }),
    UserProfile.fromJson({
      'id': 'usr_valkyrie',
      'username': 'cyber_valkyrie',
      'displayName': 'Cyber Valkyrie',
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBDYL-s3CJmDNWyo9oFTLQcTcMMmDSDX16cVLaV8JAiEf5hOANlIlFhMrIG_fHBMew7uINwdkUTnQZHrqhZXDT9_Vsc9QT5_2YB129koT0xmOAXubxSV5CXPKxdCW1yvuNCDRnuh_6vFZ0ilBgiotbKUFvexnrkgewP1NCudkAtLem7NiHc5DEu8515aiEL_oZZq1JXfpLsC-aOHPcMrY8OLnH18EQH2tQmHccJSgvJruXR52uw23B8',
      'badge': 'STREET SAMURAI',
      'isVerified': true,
      'isFollowing': false,
      'isPrivate': false,
      'followersCount': 342900,
      'followingCount': 145,
      'postsCount': 310,
      'bio': 'Chasing the neon sunrise above Sector 7 before grid reset. 🌆✨',
    }),
    UserProfile.fromJson({
      'id': 'usr_rei',
      'username': 'rei_kusanagi',
      'displayName': 'Rei Kusanagi',
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDyUb083Zqd8xe992LgA35XrjBrHLhhm7P3ZEy8ZfzCeuXvfkFzIjVjz-9Vt98EeFTQ4jiID9kYyrdNwMO60gcPmLNg-ZgtU71mj9awGjMnp3zb3UIz7QjurWkZTH_l7JND_t55NulWD9vShQo_TBg6sn4_keJnW7Wng5A1X62iW-Tx1SJNKXpXSvQK_olIpP8Su4GEbHIaMYXSTv-c0pQC0E3DEBliX98v_9cQuOtBs86oPiF_b_PD',
      'badge': 'NETRUNNER',
      'isVerified': false,
      'isFollowing': false,
      'isPrivate': true,
      'followersCount': 45200,
      'followingCount': 110,
      'postsCount': 76,
      'bio': 'Netrunner // Neural Investigator. Shibuya underground never sleeps.',
    }),
    UserProfile.fromJson({
      'id': 'usr_speed',
      'username': 'shibuya_speed_unit',
      'displayName': 'Shibuya Speed Unit',
      'avatar': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDegTA7tA0I94hcmgkI_HJf2xuwrIOD3TtQhnSGZiLFfA0Rux1mc3qlXzyxNPnNxmApbvD9u6TvsExnQtB8CMr2Zs8T74KYGwD9mEGoPicl78KxujlBdREucMcxKaKLJkc-Rxpj8DvjMEFbq8j4Lxpx-e2V6IE84L4bQkPi0hH2s7M1ImLEFrVAcEM4LJake2ws7wd3MRybPltfA_gbHapRgH_08LQWW9IXPIijPY01z_6jf9iibGV8',
      'badge': 'MIDNIGHT RACING',
      'isVerified': true,
      'isFollowing': false,
      'isPrivate': false,
      'followersCount': 1200000,
      'followingCount': 88,
      'postsCount': 92,
      'bio': '02:00 AM Grid Battles. Plasma manifolds uncapped. 🏎️🔥',
    }),
  ];
}

