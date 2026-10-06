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

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _authError;
  String? get authError => _authError;

  List<Map<String, dynamic>> _availableRoles = [];
  List<Map<String, dynamic>> get availableRoles => _availableRoles;

  List<UserProfile> _allUsers = [];
  List<UserProfile> get allUsers => _allUsers;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _userRepo.fetchRoles(),
        _userRepo.fetchAllUsers(),
      ]);
      _availableRoles = results[0] as List<Map<String, dynamic>>;
      _allUsers = results[1] as List<UserProfile>;
      // Keep unauthenticated initially so user can experience Sign In / Sign Up screen
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('[UserViewModel] fetchMe error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      _allUsers = await _userRepo.fetchAllUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('[UserViewModel] fetchAllUsers error: $e');
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      if (_allUsers.isEmpty) await fetchAllUsers();
      return _allUsers;
    }
    try {
      final res = await _userRepo.search(query);
      final users = (res['users'] as List<dynamic>?)?.cast<UserProfile>() ?? [];
      if (users.isNotEmpty) return users;
    } catch (e) {
      debugPrint('[UserViewModel] search error: $e');
    }
    return _allUsers.where((u) =>
      u.username.toLowerCase().contains(q) ||
      u.displayName.toLowerCase().contains(q) ||
      u.bio.toLowerCase().contains(q)
    ).toList();
  }

  Future<bool> login(String username, String passkey) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final user = await _userRepo.login(username, passkey);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _authError = null;
        notifyListeners();
        return true;
      } else {
        _authError = 'Quantum handshake rejected: Invalid Neural ID or Passkey';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authError = 'Connection failure: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String passkey,
    String? displayName,
    String? role,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final user = await _userRepo.register(
        username: username,
        passkey: passkey,
        displayName: displayName,
        role: role,
      );
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _authError = null;
        notifyListeners();
        return true;
      } else {
        _authError = 'Failed to mint Neural Identity';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authError = 'Neural network error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> switchPersona(String username) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _userRepo.switchPersona(username);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[UserViewModel] switchPersona error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
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
    if (_publicUser != null &&
        (_publicUser!.id == userId || _publicUser!.username.toLowerCase() == userId.toLowerCase())) {
      if (_publicUser!.isPrivate && !_publicUser!.isFollowing) {
        final newReq = !_publicUser!.isFollowRequested;
        _publicUser = _publicUser!.copyWith(isFollowRequested: newReq);
      } else {
        final newStatus = !_publicUser!.isFollowing;
        final newFollowers = newStatus
            ? _publicUser!.followersCount + 1
            : _publicUser!.followersCount - 1;
        _publicUser = _publicUser!.copyWith(
          isFollowing: newStatus,
          isFollowRequested: false,
          followersCount: newFollowers < 0 ? 0 : newFollowers,
        );
      }
      notifyListeners();
    }

    try {
      await _userRepo.toggleFollow(userId);
    } catch (e) {
      debugPrint('[UserViewModel] toggleFollow error: $e');
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? location,
    String? avatarUrl,
    bool? isPrivate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (avatarUrl != null) updates['avatar'] = avatarUrl;
      if (isPrivate != null) updates['isPrivate'] = isPrivate;

      final updated = await _userRepo.updateProfile(updates);
      if (updated != null) {
        _currentUser = updated;
      } else if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          bio: bio ?? _currentUser!.bio,
          location: location ?? _currentUser!.location,
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
          isPrivate: isPrivate ?? _currentUser!.isPrivate,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[UserViewModel] updateProfile error: $e');
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          bio: bio ?? _currentUser!.bio,
          location: location ?? _currentUser!.location,
          avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
          isPrivate: isPrivate ?? _currentUser!.isPrivate,
        );
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setAccountPrivacy(bool isPrivate) async {
    return updateProfile(isPrivate: isPrivate);
  }
}


