import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class ExploreScreen extends StatefulWidget {
  final Map<String, dynamic> exploreData;
  final List<UserProfile>? availableUsers;
  final ValueChanged<String>? onTagSelected;
  final ValueChanged<String>? onItemTapped;
  final ValueChanged<UserProfile>? onSelectUser;
  final ValueChanged<UserProfile>? onChatWithUser;

  const ExploreScreen({
    super.key,
    required this.exploreData,
    this.availableUsers,
    this.onTagSelected,
    this.onItemTapped,
    this.onSelectUser,
    this.onChatWithUser,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = '#NeoTokyo';
  int _searchFilterIndex = 0; // 0: All Matrix, 1: Users // Agents, 2: Posts, 3: Tags

  final List<String> _filterTabs = [
    'ALL MATRIX',
    'USERS // AGENTS',
    'POSTS',
    'TAGS',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final allUsers = widget.availableUsers ?? userVM.allUsers;

    final tags = (widget.exploreData['trendingTags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['#NeoTokyo', '#CyberdeckMod', '#SynthwaveBeats', '#HoloFashion', '#NeuralArt'];

    final rawItems = (widget.exploreData['gridItems'] as List<dynamic>?) ?? [];

    final query = _searchController.text.trim().toLowerCase();

    // Matched Users
    final matchedUsers = allUsers.where((u) {
      if (query.isEmpty) return true;
      return u.username.toLowerCase().contains(query) ||
          u.displayName.toLowerCase().contains(query) ||
          u.bio.toLowerCase().contains(query);
    }).toList();

    // Matched Grid Items
    final matchedGridItems = rawItems.where((item) {
      if (query.isEmpty) return true;
      final id = (item['id'] ?? '').toString().toLowerCase();
      final type = (item['type'] ?? '').toString().toLowerCase();
      return id.contains(query) || type.contains(query) || _selectedTag.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Cyber Search Bar with Scanner Reticle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: CyberReticleWidget(
                cornerLength: 10,
                strokeWidth: 1.5,
                reticleColor: CyberColors.secondaryCyan,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: CyberColors.secondaryCyan, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: CyberTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search users, @handles, posts, neural tags...',
                            hintStyle: CyberTypography.bodySecondary.copyWith(fontSize: 13),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _searchController.clear()),
                          child: const Icon(Icons.close, color: CyberColors.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Search / Explore Category Filter Pills
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _filterTabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final title = _filterTabs[index];
                  final isSelected = index == _searchFilterIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _searchFilterIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CyberColors.primaryHotPink.withValues(alpha: 0.2)
                            : CyberColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? CyberColors.primaryHotPink : CyberColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        title,
                        style: CyberTypography.hudCaption.copyWith(
                          color: isSelected ? Colors.white : CyberColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. View Switcher based on Selected Filter
            Expanded(
              child: _buildBody(
                context,
                tags: tags,
                matchedUsers: matchedUsers,
                gridItems: matchedGridItems,
                query: query,
                userVM: userVM,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<String> tags,
    required List<UserProfile> matchedUsers,
    required List<dynamic> gridItems,
    required String query,
    required UserViewModel userVM,
  }) {
    // If specifically on USERS tab OR if user searched and there are matching users
    if (_searchFilterIndex == 1) {
      return _buildUsersList(context, matchedUsers, userVM);
    }

    if (_searchFilterIndex == 2) {
      return _buildGrid(gridItems);
    }

    if (_searchFilterIndex == 3) {
      return _buildTagsView(tags);
    }

    // Default "ALL MATRIX": If search query is active, show matching users top section then grid
    return CustomScrollView(
      slivers: [
        // Horizontal Trending Tags
        SliverToBoxAdapter(
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = tag == _selectedTag;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTag = tag);
                    widget.onTagSelected?.call(tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CyberColors.secondaryCyan.withValues(alpha: 0.15)
                          : CyberColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected ? CyberColors.secondaryCyan : CyberColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: CyberTypography.hudCaption.copyWith(
                        color: isSelected ? CyberColors.secondaryCyan : CyberColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Available Users Tray Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CyberColors.secondaryCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      query.isEmpty
                          ? 'AVAILABLE NEURAL AGENTS // DIRECTORY'
                          : 'MATCHED AGENTS (${matchedUsers.length})',
                      style: CyberTypography.hudCaption.copyWith(
                        color: CyberColors.secondaryCyan,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() => _searchFilterIndex = 1),
                  child: Text(
                    'VIEW ALL',
                    style: CyberTypography.hudCaption.copyWith(
                      color: CyberColors.primaryHotPink,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Available Users Horizontal Quick Strip
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: matchedUsers.isEmpty
                ? Center(
                    child: Text(
                      'No matching agents found',
                      style: CyberTypography.bodySecondary.copyWith(fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: matchedUsers.length,
                    itemBuilder: (context, index) {
                      final u = matchedUsers[index];
                      return _buildUserStripCard(u);
                    },
                  ),
          ),
        ),

        // Grid Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 14, top: 10, bottom: 6),
            child: Text(
              'NEURAL MOSAIC FEED',
              style: CyberTypography.hudCaption.copyWith(
                color: CyberColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),

        // 3x3 Staggered Grid
        if (gridItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'NO TELEMETRY MATCHES',
                style: CyberTypography.hudCaption.copyWith(color: CyberColors.textMuted),
              ),
            ),
          )
        else
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = gridItems[index];
                return _buildGridTile(item);
              },
              childCount: gridItems.length,
            ),
          ),
      ],
    );
  }

  Widget _buildUserStripCard(UserProfile u) {
    return GestureDetector(
      onTap: () => widget.onSelectUser?.call(u),
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [CyberColors.primaryHotPink, CyberColors.secondaryCyan],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: CyberColors.surfaceDark,
                    backgroundImage: NetworkImage(u.avatarUrl),
                  ),
                ),
                if (u.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: CyberColors.secondaryCyan,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 8, color: Colors.black),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '@${u.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CyberTypography.hudCaption.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              u.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CyberTypography.bodySecondary.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, List<UserProfile> users, UserViewModel userVM) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, color: CyberColors.textMuted, size: 40),
            const SizedBox(height: 8),
            Text(
              'NO NEURAL AGENTS MATCH QUERY',
              style: CyberTypography.hudCaption.copyWith(color: CyberColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(color: CyberColors.borderSubtle, height: 16),
      itemBuilder: (context, index) {
        final u = users[index];
        return InkWell(
          onTap: () => widget.onSelectUser?.call(u),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Avatar with glowing ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CyberColors.secondaryCyan, width: 1.2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: CyberColors.surfaceDark,
                    backgroundImage: NetworkImage(u.avatarUrl),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '@${u.username}',
                              style: CyberTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (u.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: CyberColors.secondaryCyan, size: 14),
                          ],
                        ],
                      ),
                      Text(
                        u.displayName,
                        style: CyberTypography.bodySecondary.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (u.bio.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          u.bio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CyberTypography.hudCaption.copyWith(
                            color: CyberColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action buttons: Chat & Follow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Direct Chat Action Button
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: CyberColors.secondaryCyan, size: 20),
                      tooltip: 'Direct Chat',
                      onPressed: () => widget.onChatWithUser?.call(u),
                    ),
                    // Follow Action Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        side: BorderSide(
                          color: u.isFollowing ? CyberColors.textMuted : CyberColors.primaryHotPink,
                        ),
                        backgroundColor: u.isFollowing
                            ? Colors.transparent
                            : CyberColors.primaryHotPink.withValues(alpha: 0.15),
                      ),
                      onPressed: () => userVM.toggleFollowUser(u.username),
                      child: Text(
                        u.isFollowing ? 'SYNCED' : 'FOLLOW',
                        style: CyberTypography.hudCaption.copyWith(
                          color: u.isFollowing ? CyberColors.textMuted : CyberColors.primaryHotPink,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('NO POSTS FOUND', style: CyberTypography.hudCaption.copyWith(color: CyberColors.textMuted)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildGridTile(items[index]),
    );
  }

  Widget _buildGridTile(dynamic item) {
    final isVideo = item['type'] == 'video';
    final imageUrl = item['imageUrl'] as String? ?? '';
    final likes = item['likesCount'] as int? ?? 0;

    return GestureDetector(
      onTap: () => widget.onItemTapped?.call(item['id'] as String),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: CyberColors.surfaceElevated,
              child: const Icon(Icons.image, color: CyberColors.textMuted),
            ),
          ),
          if (isVideo)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
            ),
          Positioned(
            bottom: 4,
            left: 6,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white70, size: 12),
                const SizedBox(width: 3),
                Text(
                  '$likes',
                  style: CyberTypography.hudCaption.copyWith(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsView(List<String> tags) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final t = tags[index];
        return ListTile(
          leading: const Icon(Icons.tag, color: CyberColors.secondaryCyan),
          title: Text(t, style: CyberTypography.bodyMedium.copyWith(color: Colors.white)),
          subtitle: Text('Trending in Neo-Tokyo Sector 4', style: CyberTypography.bodySecondary),
          onTap: () {
            setState(() {
              _selectedTag = t;
              _searchController.text = t;
              _searchFilterIndex = 0;
            });
            widget.onTagSelected?.call(t);
          },
        );
      },
    );
  }
}
