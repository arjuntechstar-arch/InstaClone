import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/feed_model.dart';
import '../data/models/story_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/feed_repository.dart';
import '../data/repositories/social_repositories.dart';
import '../data/services/websocket_service.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  final StoryRepository _storyRepo;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  FeedViewModel({
    FeedRepository? feedRepo,
    StoryRepository? storyRepo,
  })  : _feedRepo = feedRepo ?? FeedRepository(),
        _storyRepo = storyRepo ?? StoryRepository();

  List<PostItem> _posts = [];
  List<PostItem> get posts => _posts;

  List<StoryItem> _stories = [];
  List<StoryItem> get stories => _stories;

  List<UserProfile> _suggestedUsers = [];
  List<UserProfile> get suggestedUsers => _suggestedUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _feedRepo.fetchFeed(),
        _storyRepo.fetchStories(),
        _feedRepo.fetchSuggestedUsers(),
      ]);
      _posts = results[0] as List<PostItem>;
      _stories = results[1] as List<StoryItem>;
      _suggestedUsers = results[2] as List<UserProfile>;

      WebSocketService().connect();
      _setupWebSocketListener();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupWebSocketListener() {
    _wsSub?.cancel();
    _wsSub = WebSocketService().stream.listen((event) {
      final type = event['type'];
      if (type == 'POST_LIKED') {
        final postId = event['postId']?.toString();
        final isLiked = event['isLiked'] as bool?;
        final likesCount = event['likesCount'] as int?;
        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          _posts[idx] = _posts[idx].copyWith(
            isLiked: isLiked ?? _posts[idx].isLiked,
            likesCount: likesCount ?? _posts[idx].likesCount,
          );
          notifyListeners();
        }
      } else if (type == 'COMMENT_ADDED') {
        final postId = event['postId']?.toString();
        final count = event['commentsCount'] as int?;
        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          _posts[idx] = _posts[idx].copyWith(
            commentsCount: count ?? (_posts[idx].commentsCount + 1),
          );
          notifyListeners();
        }
      } else if (type == 'NEW_POST') {
        final rawPost = event['post'];
        if (rawPost != null) {
          final newPost = PostItem.fromJson(Map<String, dynamic>.from(rawPost));
          final exists = _posts.any((p) => p.id == newPost.id);
          if (!exists) {
            _posts.insert(0, newPost);
            notifyListeners();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final newLiked = !current.isLiked;
    final newCount = newLiked ? current.likesCount + 1 : current.likesCount - 1;

    // Optimistic UI update
    _posts[index] = current.copyWith(
      isLiked: newLiked,
      likesCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    try {
      final res = await _feedRepo.toggleLike(postId);
      if (res != null && res['likesCount'] != null) {
        _posts[index] = _posts[index].copyWith(
          isLiked: res['isLiked'] as bool? ?? newLiked,
          likesCount: res['likesCount'] as int? ?? newCount,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[FeedViewModel] toggleLike error: $e');
    }
  }

  Future<void> toggleSave(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final newSaved = !current.isSaved;

    // Optimistic UI update
    _posts[index] = current.copyWith(isSaved: newSaved);
    notifyListeners();

    try {
      final isSaved = await _feedRepo.toggleSave(postId);
      _posts[index] = _posts[index].copyWith(isSaved: isSaved);
      notifyListeners();
    } catch (e) {
      debugPrint('[FeedViewModel] toggleSave error: $e');
    }
  }

  Future<void> toggleRepost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final newReposted = !current.isReposted;
    final newCount = newReposted ? current.repostsCount + 1 : current.repostsCount - 1;

    // Optimistic UI update
    _posts[index] = current.copyWith(
      isReposted: newReposted,
      repostsCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    try {
      final res = await _feedRepo.toggleRepost(postId);
      if (res != null && res['repostsCount'] != null) {
        _posts[index] = _posts[index].copyWith(
          isReposted: res['isReposted'] as bool? ?? newReposted,
          repostsCount: res['repostsCount'] as int? ?? newCount,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[FeedViewModel] toggleRepost error: $e');
    }
  }

  void recordCommentAdded(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentsCount: _posts[index].commentsCount + 1,
      );
      notifyListeners();
    }
  }

  Future<void> toggleFollowSuggestion(String username) async {
    final index = _suggestedUsers.indexWhere(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
    if (index == -1) return;

    final current = _suggestedUsers[index];
    if (current.isPrivate && !current.isFollowing) {
      // Toggle follow request
      final newRequested = !current.isFollowRequested;
      _suggestedUsers[index] = current.copyWith(isFollowRequested: newRequested);
      notifyListeners();
    } else {
      final newFollowing = !current.isFollowing;
      final newFollowers = newFollowing
          ? current.followersCount + 1
          : (current.followersCount > 0 ? current.followersCount - 1 : 0);
      _suggestedUsers[index] = current.copyWith(
        isFollowing: newFollowing,
        followersCount: newFollowers,
        isFollowRequested: false,
      );
      notifyListeners();
    }

    try {
      await _feedRepo.fetchSuggestedUsers(); // re-sync
    } catch (e) {
      debugPrint('[FeedViewModel] toggleFollowSuggestion error: $e');
    }
  }

  void dismissSuggestion(String username) {
    _suggestedUsers.removeWhere(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
    notifyListeners();
  }


  Future<bool> addNewPost({
    required String caption,
    required String mediaUrl,
    String? location,
    String? musicTrack,
    String? filterName,
    List<String> tags = const [],
  }) async {
    try {
      final newPost = await _feedRepo.createPost(
        caption: caption,
        mediaUrl: mediaUrl,
        location: location,
        musicTrack: musicTrack,
        filterName: filterName,
        tags: tags,
      );
      if (newPost != null) {
        _posts.insert(0, newPost);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[FeedViewModel] addNewPost error: $e');
    }
    return false;
  }

  Future<void> voteStoryPoll(String storyId, int optionIndex) async {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;

    final currentStory = _stories[index];
    if (currentStory.poll == null) return;

    final poll = currentStory.poll!;
    final updatedOptions = List<PollOption>.from(poll.options);
    if (optionIndex >= 0 && optionIndex < updatedOptions.length) {
      updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(
        votes: updatedOptions[optionIndex].votes + 1,
      );
    }

    _stories[index] = currentStory.copyWith(
      poll: poll.copyWith(
        options: updatedOptions,
        userVoted: optionIndex,
      ),
    );
    notifyListeners();

    try {
      final res = await _storyRepo.votePoll(storyId, optionIndex);
      if (res != null) {
        _stories[index] = res;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[FeedViewModel] voteStoryPoll error: $e');
    }
  }

  Future<bool> addStory({
    required String mediaUrl,
    required String username,
    required String avatarUrl,
    String? caption,
    String? pollQuestion,
    List<String>? pollOptions,
  }) async {
    final newStory = StoryItem(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'u_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      avatarUrl: avatarUrl,
      mediaUrl: mediaUrl,
      timestamp: 'Just now',
      hasUnseen: true,
      poll: (pollQuestion != null &&
              pollQuestion.trim().isNotEmpty &&
              pollOptions != null &&
              pollOptions.isNotEmpty)
          ? StoryPoll(
              question: pollQuestion.trim(),
              options: pollOptions.map((opt) => PollOption(text: opt, votes: 0)).toList(),
            )
          : null,
    );
    _stories.insert(0, newStory);
    notifyListeners();
    return true;
  }
}

