import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class DirectChatThreadScreen extends StatefulWidget {
  final ChatThread thread;
  final ValueChanged<String> onSendText;
  final Function(String duration, List<int> waveform) onSendVoice;
  final ValueChanged<String> onSendHologram;
  final VoidCallback onBack;

  const DirectChatThreadScreen({
    super.key,
    required this.thread,
    required this.onSendText,
    required this.onSendVoice,
    required this.onSendHologram,
    required this.onBack,
  });

  @override
  State<DirectChatThreadScreen> createState() => _DirectChatThreadScreenState();
}

class _DirectChatThreadScreenState extends State<DirectChatThreadScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _playingVoiceId;

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendText(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.thread.messages;

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            CyberAvatar(
              radius: 17,
              imageUrl: widget.thread.user.avatarUrl,
              isVerified: widget.thread.user.isVerified,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.thread.user.displayName.isNotEmpty
                        ? widget.thread.user.displayName
                        : widget.thread.user.username,
                    style: CyberTypography.bodyBold.copyWith(fontSize: 14),
                  ),
                  Text(
                    '256-BIT QUANTUM LOCKED',
                    style: CyberTypography.hudCaption.copyWith(
                      color: CyberColors.secondaryCyan,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: CyberColors.surfaceModal,
                  content: Text('Holo-feed link requested'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Message Stream List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.sender == 'me';

                if (msg.type == 'voice') {
                  return _buildVoiceBubble(msg, isMe);
                } else if (msg.type == 'hologram') {
                  return _buildHologramBubble(msg, isMe);
                }
                return _buildTextBubble(msg, isMe);
              },
            ),
          ),

          // 2. Chat Input Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: CyberColors.surfaceDark,
              border: Border(
                top: BorderSide(color: CyberColors.borderSubtle, width: 0.8),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Hologram shortcut
                  IconButton(
                    icon: const Icon(Icons.view_in_ar, color: CyberColors.secondaryCyan),
                    tooltip: 'Send 3D Hologram',
                    onPressed: () {
                      widget.onSendHologram('Akihabara Neon Mesh 3D');
                      _scrollToBottom();
                    },
                  ),
                  // Voice waveform record shortcut
                  IconButton(
                    icon: const Icon(Icons.mic, color: CyberColors.tertiaryYellow),
                    tooltip: 'Record Voice Waveform',
                    onPressed: () {
                      widget.onSendVoice('0:18', [25, 60, 85, 40, 95, 70, 30, 80, 50, 90]);
                      _scrollToBottom();
                    },
                  ),
                  // Text input
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: CyberColors.bgVoid,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CyberColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: CyberTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Transmit neural packet...',
                          hintStyle: CyberTypography.bodySecondary,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Send Button
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: CyberColors.pinkGlow,
                        shape: BoxShape.circle,
                        boxShadow: CyberColors.pinkGlowShadow(blur: 6),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe ? CyberColors.pinkGlow : null,
          color: isMe ? null : CyberColors.surfaceElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe ? null : Border.all(color: CyberColors.borderSubtle),
          boxShadow: isMe ? CyberColors.pinkGlowShadow(blur: 8) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: CyberTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  msg.timestamp,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceBubble(ChatMessage msg, bool isMe) {
    final isPlaying = _playingVoiceId == msg.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CyberColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMe ? CyberColors.primaryHotPink : CyberColors.secondaryCyan,
            width: 1,
          ),
          boxShadow: [
            if (isMe) ...CyberColors.pinkGlowShadow(blur: 6) else ...CyberColors.cyanGlowShadow(blur: 6),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _playingVoiceId = isPlaying ? null : msg.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: isMe ? CyberColors.pinkGlow : CyberColors.cyanGlow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CyberWaveformWidget(
              isPlaying: isPlaying,
              customWaveform: msg.waveform ?? [30, 60, 80, 50, 95, 40, 70],
              color: isMe ? CyberColors.primaryHotPink : CyberColors.secondaryCyan,
              height: 24,
            ),
            const SizedBox(width: 10),
            Text(
              msg.duration ?? '0:15',
              style: CyberTypography.hudCaption.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHologramBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CyberColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CyberColors.secondaryCyan, width: 1.2),
          boxShadow: CyberColors.cyanGlowShadow(blur: 8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.view_in_ar, color: CyberColors.secondaryCyan, size: 18),
                const SizedBox(width: 6),
                Text(
                  '3D SPATIAL HOLOGRAM',
                  style: CyberTypography.hudCaption.copyWith(
                    color: CyberColors.secondaryCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CyberScanlineOverlay(),
                  const Icon(Icons.interests_outlined, color: CyberColors.secondaryCyan, size: 48),
                  Positioned(
                    bottom: 6,
                    child: Text(
                      'ROTATING SPATIAL MESH',
                      style: CyberTypography.hudCaption.copyWith(fontSize: 9, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: CyberTypography.bodySecondary.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
