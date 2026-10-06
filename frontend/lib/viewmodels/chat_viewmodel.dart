import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/message_model.dart';
import '../data/models/feed_model.dart';
import '../data/repositories/social_repositories.dart';
import '../data/services/websocket_service.dart';

class ChatViewModel extends ChangeNotifier {
  final MessageRepository _msgRepo;
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  ChatViewModel({
    MessageRepository? msgRepo,
    WebSocketService? wsService,
  })  : _msgRepo = msgRepo ?? MessageRepository(),
        _wsService = wsService ?? WebSocketService();

  List<ChatThread> _threads = [];
  List<ChatThread> get threads => _threads;

  ChatThread? _activeThread;
  ChatThread? get activeThread => _activeThread;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _threads = await _msgRepo.fetchThreads();
      if (_threads.isNotEmpty) {
        _activeThread = _threads.first;
      }
      _wsService.connect();
      _setupWebSocketListener();
    } catch (e) {
      debugPrint('[ChatViewModel] error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupWebSocketListener() {
    _wsSub?.cancel();
    _wsSub = _wsService.stream.listen((event) {
      final type = event['type'];
      if (type == 'DIRECT_MESSAGE' || type == 'CHAT_MESSAGE') {
        final threadId = event['threadId']?.toString();
        final rawMsg = event['message'];
        if (rawMsg != null) {
          final incoming = ChatMessage.fromJson(Map<String, dynamic>.from(rawMsg));
          // If this message is for the currently active thread
          if (_activeThread != null &&
              (_activeThread!.id == threadId ||
               _activeThread!.user.username.toLowerCase() == incoming.sender.toLowerCase())) {
            final exists = _activeThread!.messages.any((m) => m.id == incoming.id);
            if (!exists) {
              _appendMessage(incoming);
            }
          } else {
            // Update thread preview
            final idx = _threads.indexWhere((t) => t.id == threadId);
            if (idx != -1) {
              _threads[idx] = _threads[idx].copyWith(
                lastMessage: event['lastMessage'] ?? incoming.text,
                unreadCount: _threads[idx].unreadCount + 1,
              );
              notifyListeners();
            } else {
              refreshThreads();
            }
          }
        }
      }
    });
  }

  Future<void> refreshThreads() async {
    try {
      final fetched = await _msgRepo.fetchThreads();
      if (fetched.isNotEmpty) {
        _threads = fetched;
        if (_activeThread != null) {
          final current = _threads.firstWhere((t) => t.id == _activeThread!.id, orElse: () => _activeThread!);
          _activeThread = current;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ChatViewModel] refreshThreads error: $e');
    }
  }

  Future<ChatThread> startChatWithUser(String username, {String? displayName, String? avatarUrl}) async {
    try {
      final remoteThread = await _msgRepo.startThread(username);
      if (remoteThread != null) {
        final idx = _threads.indexWhere((t) => t.id == remoteThread.id);
        if (idx != -1) {
          _threads[idx] = remoteThread;
        } else {
          _threads.insert(0, remoteThread);
        }
        _activeThread = remoteThread;
        notifyListeners();
        return remoteThread;
      }
    } catch (e) {
      debugPrint('[ChatViewModel] startChatWithUser error: $e');
    }
    return openOrCreateThread(username, displayName: displayName, avatarUrl: avatarUrl);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  void selectThread(String threadId) {
    final idx = _threads.indexWhere((t) => t.id == threadId);
    if (idx != -1) {
      _activeThread = _threads[idx];
      notifyListeners();
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty || _activeThread == null) return;

    final newMessage = ChatMessage(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'me',
      text: text.trim(),
      timestamp: 'Just now',
      type: 'text',
      isEncrypted: true,
    );

    _appendMessage(newMessage);

    try {
      await _msgRepo.sendMessage(_activeThread!.id, {
        'text': text.trim(),
        'type': 'text',
      });
    } catch (e) {
      debugPrint('[ChatViewModel] send error: $e');
    }

    _triggerSimulatedReply(_activeThread!.user.username);
  }

  void _triggerSimulatedReply(String contactUsername) {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (_activeThread == null) return;
      final replyMap = {
        'neon_kaito': 'Quantum uplink confirmed. Patching into Akihabara subnet now. 🦾⚡',
        'kira_synth': 'Frequency received! Playing this track on the night stream tonight 🎧✨',
        'neotech_admin': 'Order request noted. New cybernetic implants dropping in the marketplace soon.',
        'cyber_ren': 'Great composition! The neon saturation in Shinjuku is peak right now 📸🌆',
        'anon_mesh': 'Encrypted handshake verified. Mesh node routing complete. 🌐',
      };
      final replyText = replyMap[contactUsername.toLowerCase()] ??
          'Neural ping acknowledged by @$contactUsername. ⚡';

      final replyMsg = ChatMessage(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        sender: contactUsername,
        text: replyText,
        timestamp: 'Just now',
        type: 'text',
        isEncrypted: true,
      );
      _appendMessage(replyMsg);
    });
  }

  Future<void> sharePostToContact(String recipientUsername, PostItem post, String? note) async {
    var targetIdx = _threads.indexWhere((t) => t.user.username.toLowerCase() == recipientUsername.toLowerCase());
    if (targetIdx == -1) {
      final newThread = ChatThread(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        user: PostAuthor(
          id: 'u_$recipientUsername',
          username: recipientUsername,
          displayName: recipientUsername.replaceAll('_', ' ').toUpperCase(),
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
        ),
        lastMessage: 'Shared Post',
        unreadCount: 0,
      );
      _threads.insert(0, newThread);
      targetIdx = 0;
    }

    _activeThread = _threads[targetIdx];
    final shareText = (note != null && note.isNotEmpty)
        ? '$note\n[Shared Post by @${post.author.username}]: "${post.caption}"'
        : '[Shared Post by @${post.author.username}]: "${post.caption}"';

    final shareMsg = ChatMessage(
      id: 'm_share_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'me',
      text: shareText,
      timestamp: 'Just now',
      type: 'text',
      isEncrypted: true,
    );
    _appendMessage(shareMsg);

    _triggerSimulatedReply(recipientUsername);
  }

  ChatThread openOrCreateThread(String username, {String? displayName, String? avatarUrl}) {
    final idx = _threads.indexWhere((t) => t.user.username.toLowerCase() == username.toLowerCase());
    if (idx != -1) {
      _activeThread = _threads[idx];
      notifyListeners();
      return _activeThread!;
    }
    final newThread = ChatThread(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      user: PostAuthor(
        id: 'u_$username',
        username: username,
        displayName: displayName ?? username,
        avatarUrl: avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
      ),
      lastMessage: 'Frequency opened',
      unreadCount: 0,
      messages: [],
    );
    _threads.insert(0, newThread);
    _activeThread = newThread;
    notifyListeners();
    return newThread;
  }

  Future<void> sendVoiceMessage(String duration, List<int> waveform) async {
    if (_activeThread == null) return;

    final newMessage = ChatMessage(
      id: 'm_voice_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'me',
      text: 'Encrypted voice packet',
      duration: duration,
      waveform: waveform,
      timestamp: 'Just now',
      type: 'voice',
      isEncrypted: true,
    );

    _appendMessage(newMessage);

    try {
      await _msgRepo.sendMessage(_activeThread!.id, {
        'text': 'Encrypted voice packet',
        'duration': duration,
        'waveform': waveform,
        'type': 'voice',
      });
    } catch (e) {
      debugPrint('[ChatViewModel] send voice error: $e');
    }
  }

  Future<void> sendHologramMessage(String hologramDescription) async {
    if (_activeThread == null) return;

    final newMessage = ChatMessage(
      id: 'm_holo_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'me',
      text: 'Transmitting Holographic Geometry [3D Spatial Model]',
      timestamp: 'Just now',
      type: 'hologram',
      isEncrypted: true,
    );

    _appendMessage(newMessage);

    try {
      await _msgRepo.sendMessage(_activeThread!.id, {
        'text': 'Transmitting Holographic Geometry [3D Spatial Model]',
        'type': 'hologram',
      });
    } catch (e) {
      debugPrint('[ChatViewModel] send holo error: $e');
    }
  }

  void _appendMessage(ChatMessage msg) {
    if (_activeThread == null) return;

    final updatedMessages = List<ChatMessage>.from(_activeThread!.messages)..add(msg);
    _activeThread = _activeThread!.copyWith(
      messages: updatedMessages,
      lastMessage: msg.type == 'voice'
          ? 'Voice (${msg.duration})'
          : (msg.type == 'hologram' ? '3D Hologram' : msg.text),
    );

    final idx = _threads.indexWhere((t) => t.id == _activeThread!.id);
    if (idx != -1) {
      _threads[idx] = _activeThread!;
    }
    notifyListeners();
  }
}

