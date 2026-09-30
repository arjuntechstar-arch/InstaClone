import 'package:flutter/foundation.dart';
import '../data/models/reel_model.dart';
import '../data/repositories/social_repositories.dart';

class ReelViewModel extends ChangeNotifier {
  final ReelRepository _reelRepo;
  ReelViewModel({ReelRepository? reelRepo}) : _reelRepo = reelRepo ?? ReelRepository();

  List<ReelItem> _reels = [];
  List<ReelItem> get reels => _reels;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reels = await _reelRepo.fetchReels();
    } catch (e) {
      debugPrint('[ReelViewModel] error fetching reels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> toggleLike(String reelId) async {
    final idx = _reels.indexWhere((r) => r.id == reelId);
    if (idx == -1) return;

    final current = _reels[idx];
    final newLiked = !current.isLiked;
    final newCount = newLiked ? current.likesCount + 1 : current.likesCount - 1;

    _reels[idx] = current.copyWith(
      isLiked: newLiked,
      likesCount: newCount < 0 ? 0 : newCount,
    );
    notifyListeners();

    try {
      final res = await _reelRepo.toggleLike(reelId);
      if (res != null && res['likesCount'] != null) {
        _reels[idx] = _reels[idx].copyWith(
          isLiked: res['isLiked'] as bool? ?? newLiked,
          likesCount: res['likesCount'] as int? ?? newCount,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ReelViewModel] like error: $e');
    }
  }

  void toggleFollow(String reelId) {
    final idx = _reels.indexWhere((r) => r.id == reelId);
    if (idx == -1) return;

    final current = _reels[idx];
    _reels[idx] = current.copyWith(isFollowing: !current.isFollowing);
    notifyListeners();
  }

  void toggleSave(String reelId) {
    final idx = _reels.indexWhere((r) => r.id == reelId);
    if (idx == -1) return;

    final current = _reels[idx];
    _reels[idx] = current.copyWith(isSaved: !current.isSaved);
    notifyListeners();
  }
}
