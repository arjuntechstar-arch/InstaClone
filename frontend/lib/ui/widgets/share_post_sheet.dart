import 'package:flutter/material.dart';
import '../../data/models/feed_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

/// Instagram-style Share Sheet to send a Post or Reel to Direct Messages
class SharePostSheet extends StatefulWidget {
  final PostItem post;
  final Function(String recipientUsername, String? message) onSend;

  const SharePostSheet({
    super.key,
    required this.post,
    required this.onSend,
  });

  @override
  State<SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends State<SharePostSheet> {
  final TextEditingController _messageController = TextEditingController();
  final Set<String> _sentRecipients = {};

  final List<Map<String, dynamic>> _contacts = [
    {
      'username': 'neon_kaito',
      'displayName': 'Kaito Vance',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
      'status': 'Online // Modding',
    },
    {
      'username': 'kira_synth',
      'displayName': 'Kira Oshiro',
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300',
      'status': 'Live Streamer',
    },
    {
      'username': 'neotech_admin',
      'displayName': 'NeoTech Corp',
      'avatar': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300',
      'status': 'Merchant Node',
    },
    {
      'username': 'cyber_ren',
      'displayName': 'Ren Tanaka',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      'status': 'Creator Node',
    },
    {
      'username': 'anon_mesh',
      'displayName': 'Anonymous Explorer',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300',
      'status': 'Roaming Mesh',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend(String username) {
    widget.onSend(username, _messageController.text.trim());
    setState(() {
      _sentRecipients.add(username);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CyberColors.surfaceModal,
        duration: const Duration(seconds: 2),
        content: Text('Transmitted post to @$username! ⚡', style: CyberTypography.bodyMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: CyberColors.surfaceModal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: CyberColors.secondaryCyan, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CyberColors.borderHighlight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SHARE TO QUANTUM DIRECT',
                  style: CyberTypography.hudHeader.copyWith(
                    color: CyberColors.secondaryCyan,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Post thumbnail preview banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CyberColors.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    widget.post.mediaUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: CyberColors.surfaceCard,
                      child: const Icon(Icons.image, color: CyberColors.textMuted, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${widget.post.author.username}',
                        style: CyberTypography.bodyBold.copyWith(fontSize: 12),
                      ),
                      Text(
                        widget.post.caption.isNotEmpty ? widget.post.caption : 'Cyberpunk media packet',
                        style: CyberTypography.hudCaption.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Optional message input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _messageController,
              style: CyberTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Add an encrypted note...',
                hintStyle: CyberTypography.bodySecondary,
                prefixIcon: const Icon(Icons.chat_bubble_outline, color: CyberColors.secondaryCyan, size: 18),
                filled: true,
                fillColor: CyberColors.surfaceDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: CyberColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: CyberColors.secondaryCyan),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Contacts List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const Divider(color: CyberColors.borderSubtle, height: 1),
              itemBuilder: (context, index) {
                final c = _contacts[index];
                final u = c['username'] as String;
                final isSent = _sentRecipients.contains(u);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  leading: CyberAvatar(
                    imageUrl: c['avatar'] as String,
                    radius: 20,
                  ),
                  title: Text(
                    c['displayName'] as String,
                    style: CyberTypography.bodyBold.copyWith(fontSize: 13),
                  ),
                  subtitle: Text(
                    '@$u • ${c['status']}',
                    style: CyberTypography.hudCaption.copyWith(fontSize: 11),
                  ),
                  trailing: SizedBox(
                    width: 76,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isSent ? null : () => _handleSend(u),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSent ? CyberColors.surfaceDark : CyberColors.primaryHotPink,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSent ? CyberColors.borderSubtle : CyberColors.primaryHotPink,
                          ),
                        ),
                      ),
                      child: Text(
                        isSent ? 'SENT' : 'SEND',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSent ? CyberColors.secondaryCyan : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
