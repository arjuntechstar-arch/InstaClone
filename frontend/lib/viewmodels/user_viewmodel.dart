import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/social_repositories.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  UserViewModel({UserRepository? userRepo}) : _userRepo = userRepo ?? UserRepository();

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  UserProfile? _publicUser;
  UserProfile? get publicUser => _publicUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _userRepo.fetchMe();
    } catch (e) {
      debugPrint('[UserViewModel] fetchMe error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPublicProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _publicUser = await _userRepo.fetchProfile(userId);
    } catch (e) {
      debugPrint('[UserViewModel] loadPublicProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollowUser(String userId) async {
    if (_publicUser != null && _publicUser!.id == userId) {
      final newStatus = !_publicUser!.isFollowing;
      final newFollowers = newStatus
          ? _publicUser!.followersCount + 1
          : _publicUser!.followersCount - 1;
      _publicUser = _publicUser!.copyWith(
        isFollowing: newStatus,
        followersCount: newFollowers < 0 ? 0 : newFollowers,
      );
      notifyListeners();
    }

    try {
      await _userRepo.toggleFollow(userId);
    } catch (e) {
      debugPrint('[UserViewModel] toggleFollow error: $e');
    }
  }
}
