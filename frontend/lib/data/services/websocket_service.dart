import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';

/// Real-time WebSocket connection client for Live events and Chat relay
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _eventController.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String get _wsUrl {
    final base = ApiService().baseUrl;
    if (base.startsWith('https://')) {
      return base.replaceFirst('https://', 'wss://');
    } else if (base.startsWith('http://')) {
      return base.replaceFirst('http://', 'ws://');
    }
    return 'ws://$base';
  }

  void connect() {
    if (_isConnected) return;
    try {
      final uri = Uri.parse(_wsUrl);
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data.toString());
            _eventController.add(Map<String, dynamic>.from(json));
          } catch (e) {
            debugPrint('[WebSocket] parse error: $e');
          }
        },
        onError: (err) {
          debugPrint('[WebSocket] error: $err');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('[WebSocket] connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint('[WebSocket] connect failed: $e');
      _isConnected = false;
    }
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        debugPrint('[WebSocket] send error: $e');
      }
    }
  }

  void sendLiveReaction(String streamId, String reactionType) {
    send({
      'type': 'LIVE_REACTION',
      'streamId': streamId,
      'reaction': reactionType,
    });
  }

  void sendLiveChatMessage(String streamId, String username, String text, {String? giftType}) {
    send({
      'type': 'LIVE_CHAT_MESSAGE',
      'streamId': streamId,
      'user': username,
      'text': text,
      'giftType': giftType,
    });
  }

  void dispose() {
    _channel?.sink.close();
    _isConnected = false;
  }
}
