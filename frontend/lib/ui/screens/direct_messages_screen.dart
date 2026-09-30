import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class DirectMessagesScreen extends StatefulWidget {
  final List<ChatThread> threads;
  final ValueChanged<String> onSelectThread;
  final VoidCallback onBack;
  final VoidCallback onNewMessage;

  const DirectMessagesScreen({
    super.key,
    required this.threads,
    required this.onSelectThread,
    required this.onBack,
    required this.onNewMessage,
  });

  @override
  State<DirectMessagesScreen> createState() => _DirectMessagesScreenState();
}

class _DirectMessagesScreenState extends State<DirectMessagesScreen> {
  int _selectedTab = 0; // 0: Primary, 1: General
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredThreads = widget.threads.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.user.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
            Text(
              'NEURAL CHAT',
              style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CyberColors.secondaryCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: CyberColors.secondaryCyan, width: 0.8),
              ),
              child: Text(
                'E2EE',
                style: CyberTypography.hudBadge.copyWith(color: CyberColors.secondaryCyan, fontSize: 9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: CyberColors.secondaryCyan, size: 26),
            onPressed: widget.onNewMessage,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Quantum Encryption Protocol Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: CyberColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberColors.borderCyan, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: CyberColors.secondaryCyan, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'QUANTUM ENCRYPTION ACTIVE // PROTOCOL V4.2',
                    style: CyberTypography.hudCaption.copyWith(
                      color: CyberColors.secondaryCyan,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: CyberColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: CyberColors.textMuted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: CyberTypography.bodyMedium,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search encrypted frequencies...',
                        hintStyle: CyberTypography.bodySecondary,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Tab Bar (Primary / General)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0 ? CyberColors.primaryHotPink : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'PRIMARY',
                          style: CyberTypography.hudCaption.copyWith(
                            color: _selectedTab == 0 ? Colors.white : CyberColors.textMuted,
                            fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1 ? CyberColors.primaryHotPink : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'GENERAL',
                          style: CyberTypography.hudCaption.copyWith(
                            color: _selectedTab == 1 ? Colors.white : CyberColors.textMuted,
                            fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Threads List
          Expanded(
            child: filteredThreads.isEmpty
                ? Center(
                    child: Text(
                      'NO ACTIVE CHANNELS',
                      style: CyberTypography.hudHeader.copyWith(color: CyberColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredThreads.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: CyberColors.borderSubtle,
                      height: 1,
                      indent: 74,
                    ),
                    itemBuilder: (context, index) {
                      final thread = filteredThreads[index];
                      return ListTile(
                        onTap: () => widget.onSelectThread(thread.id),
                        leading: Stack(
                          children: [
                            CyberAvatar(
                              radius: 24,
                              imageUrl: thread.user.avatarUrl,
                              isVerified: thread.user.isVerified,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: CyberColors.statusOnline,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: CyberColors.bgVoid, width: 2),
                                  boxShadow: CyberColors.cyanGlowShadow(blur: 4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Text(
                              thread.user.displayName.isNotEmpty
                                  ? thread.user.displayName
                                  : thread.user.username,
                              style: CyberTypography.bodyBold,
                            ),
                            if (thread.isPinned) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.push_pin, color: CyberColors.tertiaryYellow, size: 14),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CyberTypography.bodySecondary.copyWith(
                            color: thread.unreadCount > 0 ? Colors.white : CyberColors.textMuted,
                            fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Just now',
                              style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted),
                            ),
                            if (thread.unreadCount > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: CyberColors.pinkGlow,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: CyberColors.pinkGlowShadow(blur: 6),
                                ),
                                child: Text(
                                  '${thread.unreadCount}',
                                  style: CyberTypography.hudBadge.copyWith(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
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
