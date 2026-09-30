import 'package:flutter/foundation.dart';
import '../data/models/feed_model.dart';
import '../data/models/story_model.dart';
import '../data/repositories/feed_repository.dart';
import '../data/repositories/social_repositories.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedRepository _feedRepo;
  final StoryRepository _storyRepo;

  FeedViewModel({
    FeedRepository? feedRepo,
    StoryRepository? storyRepo,
  })  : _feedRepo = feedRepo ?? FeedRepository(),
        _storyRepo = storyRepo ?? StoryRepository();

  List<PostItem> _posts = [];
  List<PostItem> get posts => _posts;

  List<StoryItem> _stories = [];
  List<StoryItem> get stories => _stories;

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
      ]);
      _posts = results[0] as List<PostItem>;
      _stories = results[1] as List<StoryItem>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
