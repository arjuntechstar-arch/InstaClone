import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/live_model.dart';
import '../data/repositories/social_repositories.dart';
import '../data/services/websocket_service.dart';

class FloatingReactionItem {
  final String id;
  final String emoji;
  final double xOffset; // 0.0 to 1.0
  final DateTime createdAt;

  FloatingReactionItem({
    required this.id,
    required this.emoji,
    required this.xOffset,
    required this.createdAt,
  });
}

class LiveViewModel extends ChangeNotifier {
  final LiveRepository _liveRepo;
  final WebSocketService _wsService;

  LiveViewModel({
    LiveRepository? liveRepo,
    WebSocketService? wsService,
  })  : _liveRepo = liveRepo ?? LiveRepository(),
        _wsService = wsService ?? WebSocketService();

  LiveStream? _stream;
  LiveStream? get stream => _stream;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<FloatingReactionItem> _floatingReactions = [];
  List<FloatingReactionItem> get floatingReactions => _floatingReactions;

  StreamSubscription? _sub;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stream = await _liveRepo.fetchLiveStream();
      _wsService.connect();
      _sub = _wsService.stream.listen(_handleWsMessage);
    } catch (e) {
      debugPrint('[LiveViewModel] error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    if (data['type'] == 'LIVE_REACTION') {
      spawnReaction(data['reaction'] as String? ?? '❤️');
    } else if (data['type'] == 'LIVE_CHAT_MESSAGE') {
      final newComment = LiveComment(
        id: 'lc_${DateTime.now().millisecondsSinceEpoch}',
        user: data['user'] as String? ?? 'anon',
        text: data['text'] as String? ?? '',
        timestamp: 'Just now',
        giftType: data['giftType'] as String?,
      );
      if (_stream != null) {
        final updatedChat = List<LiveComment>.from(_stream!.chatMessages)..add(newComment);
        _stream = _stream!.copyWith(chatMessages: updatedChat);
        notifyListeners();
      }
    }
  }

  void spawnReaction(String reactionType) {
    String emoji = '❤️';
    if (reactionType == 'flame' || reactionType == '🔥') emoji = '🔥';
    if (reactionType == 'neon' || reactionType == '⚡') emoji = '⚡';
    if (reactionType == 'quantum_ramen') emoji = '🍜';
    if (reactionType == 'cyber_drone') emoji = '🛸';

    final xOffset = 0.2 + (DateTime.now().millisecond % 60) / 100.0;
    final item = FloatingReactionItem(
      id: 'react_${DateTime.now().millisecondsSinceEpoch}_${_floatingReactions.length}',
      emoji: emoji,
      xOffset: xOffset,
      createdAt: DateTime.now(),
    );

    _floatingReactions.add(item);
    notifyListeners();

    // Clean up expired floating particles after animation (2.5s)
    Future.delayed(const Duration(milliseconds: 2500), () {
      _floatingReactions.removeWhere((r) => r.id == item.id);
      notifyListeners();
    });
  }

  Future<void> sendReaction(String reactionType) async {
    spawnReaction(reactionType);
    if (_stream != null) {
      _wsService.sendLiveReaction(_stream!.id, reactionType);
      final currentMap = Map<String, int>.from(_stream!.reactions);
      currentMap[reactionType] = (currentMap[reactionType] ?? 0) + 1;
      _stream = _stream!.copyWith(reactions: currentMap);
      notifyListeners();
    }
  }

  Future<void> sendChatMessage(String text, {String? giftType}) async {
    if (text.trim().isEmpty && giftType == null) return;
    if (_stream == null) return;

    final comment = LiveComment(
      id: 'lc_${DateTime.now().millisecondsSinceEpoch}',
      user: 'cyber_ren',
      text: text.trim().isEmpty ? 'Sent a Cyber Gift' : text.trim(),
      timestamp: 'Just now',
      giftType: giftType,
    );

    final updated = List<LiveComment>.from(_stream!.chatMessages)..add(comment);
    _stream = _stream!.copyWith(chatMessages: updated);
    notifyListeners();

    if (giftType != null) {
      spawnReaction(giftType);
    }

    try {
      _wsService.sendLiveChatMessage(_stream!.id, 'cyber_ren', text, giftType: giftType);
      await _liveRepo.sendChat(_stream!.id, text, giftType: giftType);
    } catch (e) {
      debugPrint('[LiveViewModel] sendChat error: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
