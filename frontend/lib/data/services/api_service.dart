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

  /// Default Base URL dynamically chosen depending on web/desktop vs Android emulator
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:4000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  String baseUrl = defaultBaseUrl;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ===================== FEED =====================
  Future<List<PostItem>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/feed?page=$page&limit=$limit'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['posts'] as List<dynamic>?) ?? [];
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
  Future<List<ChatThread>> getMessageThreads() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/api/messages'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['threads'] as List<dynamic>?) ?? [];
        return list.map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getMessageThreads fallback: $e');
    }
    return _fallbackThreads;
  }

  Future<ChatMessage?> sendMessage(String threadId, Map<String, dynamic> messageData) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/messages/$threadId'),
        headers: _headers,
        body: jsonEncode(messageData),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return ChatMessage.fromJson(Map<String, dynamic>.from(data['message']));
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
        final list = (data['comments'] as List<dynamic>?) ?? [];
        return list.map((e) => CommentItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] getComments fallback: $e');
    }
    return _fallbackComments;
  }

  Future<CommentItem?> addComment(String postId, String text, {String? replyToId}) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/api/comments/$postId'),
        headers: _headers,
        body: jsonEncode({'text': text, 'replyToId': replyToId}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return CommentItem.fromJson(Map<String, dynamic>.from(data['comment']));
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
        return UserProfile.fromJson(Map<String, dynamic>.from(data['profile']));
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
        return UserProfile.fromJson(Map<String, dynamic>.from(data['profile']));
      }
    } catch (e) {
      debugPrint('[ApiService] getUserProfile fallback: $e');
    }
    return null;
  }

  Future<bool> toggleFollow(String userId) async {
    try {
      final res = await _client.post(Uri.parse('$baseUrl/api/users/$userId/follow'), headers: _headers)
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['isFollowing'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('[ApiService] toggleFollow fallback: $e');
    }
    return true;
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
}
