import 'package:flutter/material.dart';
import '../../data/models/live_model.dart';
import '../../viewmodels/live_viewmodel.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class LiveStreamViewerScreen extends StatefulWidget {
  final LiveStream stream;
  final List<FloatingReactionItem> floatingReactions;
  final ValueChanged<String> onSendReaction;
  final Function(String text, {String? giftType}) onSendChat;
  final VoidCallback onClose;

  const LiveStreamViewerScreen({
    super.key,
    required this.stream,
    required this.floatingReactions,
    required this.onSendReaction,
    required this.onSendChat,
    required this.onClose,
  });

  @override
  State<LiveStreamViewerScreen> createState() => _LiveStreamViewerScreenState();
}

class _LiveStreamViewerScreenState extends State<LiveStreamViewerScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  void _submitChat({String? giftType}) {
    final text = _chatController.text.trim();
    if (text.isNotEmpty || giftType != null) {
      widget.onSendChat(text, giftType: giftType);
      _chatController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Video Stream Simulation
          Image.network(
            'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=900',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: CyberColors.surfaceDark,
              child: const Center(
                child: Icon(Icons.live_tv, color: CyberColors.textMuted, size: 64),
              ),
            ),
          ),

          // Hologram scanline overlay
          const CyberScanlineOverlay(),

          // Top and Bottom gradient vignettes
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // 2. Top HUD Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            right: 14,
            child: Row(
              children: [
                CyberAvatar(
                  radius: 19,
                  imageUrl: stream.host.avatarUrl,
                  isLive: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.host.username,
                        style: CyberTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13),
                      ),
                      Text(
                        stream.title,
                        style: CyberTypography.hudCaption.copyWith(color: Colors.white70, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Viewers badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${stream.viewersCount}',
                        style: CyberTypography.hudCaption.copyWith(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // 3. Live Chat Overlay
          Positioned(
            left: 14,
            right: 90,
            bottom: 84,
            height: 240,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.25],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _chatScrollController,
                itemCount: stream.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = stream.chatMessages[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: msg.isPin
                          ? CyberColors.primaryHotPink.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: msg.isPin
                          ? Border.all(color: CyberColors.primaryHotPink, width: 0.8)
                          : null,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          if (msg.isPin) ...[
                            const WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.push_pin, color: CyberColors.tertiaryYellow, size: 12),
                              ),
                            ),
                          ],
                          TextSpan(
                            text: '${msg.user}: ',
                            style: CyberTypography.bodyBold.copyWith(
                              color: CyberColors.secondaryCyan,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: msg.text,
                            style: CyberTypography.bodyMedium.copyWith(color: Colors.white, fontSize: 12),
                          ),
                          if (msg.giftType != null) ...[
                            TextSpan(
                              text: ' [CYBER GIFT: ${msg.giftType!.toUpperCase()}]',
                              style: const TextStyle(color: CyberColors.tertiaryYellow, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Real-time Floating Reactions Particle Engine
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: widget.floatingReactions.map((reaction) {
                  final elapsed = DateTime.now().difference(reaction.createdAt).inMilliseconds;
                  final progress = (elapsed / 2500.0).clamp(0.0, 1.0);
                  final bottom = 80.0 + progress * 400.0;
                  final opacity = (1.0 - progress).clamp(0.0, 1.0);

                  return Positioned(
                    bottom: bottom,
                    right: 20.0 + (reaction.xOffset * 60.0),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: 1.0 + progress * 0.5,
                        child: Text(
                          reaction.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 5. Bottom Interactive Dock
          Positioned(
            left: 12,
            right: 12,
            bottom: 14,
            child: SafeArea(
              child: Row(
                children: [
                  // Chat Input Field
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: CyberColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: _chatController,
                        style: CyberTypography.bodyMedium.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Comment in stream...',
                          hintStyle: CyberTypography.bodySecondary.copyWith(color: Colors.white60),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _submitChat(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Quick Reaction & Gift Buttons
                  _buildReactionButton('❤️', () => widget.onSendReaction('heart')),
                  _buildReactionButton('🔥', () => widget.onSendReaction('flame')),
                  _buildReactionButton('⚡', () => widget.onSendReaction('neon')),
                  _buildReactionButton('🍜', () => _submitChat(giftType: 'quantum_ramen')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: CyberColors.borderHighlight, width: 0.8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
