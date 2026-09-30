import 'package:flutter/foundation.dart';
import '../data/models/message_model.dart';
import '../data/repositories/social_repositories.dart';
import '../data/services/websocket_service.dart';

class ChatViewModel extends ChangeNotifier {
  final MessageRepository _msgRepo;
  final WebSocketService _wsService;

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
    } catch (e) {
      debugPrint('[ChatViewModel] error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
