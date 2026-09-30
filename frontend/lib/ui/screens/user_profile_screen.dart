import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final bool isCurrentUser;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenSaved;
  final VoidCallback? onOpenShop;
  final VoidCallback? onBack;

  const UserProfileScreen({
    super.key,
    required this.profile,
    this.isCurrentUser = true,
    this.onToggleFollow,
    this.onOpenSettings,
    this.onOpenSaved,
    this.onOpenShop,
    this.onBack,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _highlights = [
    {'title': 'Shinjuku', 'image': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=200'},
    {'title': 'Holo Gear', 'image': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=200'},
    {'title': 'Night Drone', 'image': 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=200'},
    {'title': 'Live Sets', 'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=200'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: widget.isCurrentUser
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
        title: Row(
          children: [
            Text(
              p.username,
              style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
            ),
            if (p.isVerified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: CyberColors.secondaryCyan, size: 16),
            ],
          ],
        ),
        actions: [
          if (widget.isCurrentUser) ...[
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              tooltip: 'Saved Collections',
              onPressed: widget.onOpenSaved,
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: CyberColors.secondaryCyan),
              tooltip: 'Cyber Marketplace',
              onPressed: widget.onOpenShop,
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              tooltip: 'Settings & Privacy',
              onPressed: widget.onOpenSettings,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Avatar & Stats Row
                    Row(
                      children: [
                        CyberAvatar(
                          radius: 38,
                          imageUrl: p.avatarUrl,
                          hasStory: true,
                          isVerified: p.isVerified,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('POSTS', '${p.postsCount}'),
                              _buildStatItem('FOLLOWERS', '${(p.followersCount / 1000).toStringAsFixed(1)}K'),
                              _buildStatItem('FOLLOWING', '${p.followingCount}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display Name, Badge & Bio
                    Text(p.displayName, style: CyberTypography.titleSmall.copyWith(fontSize: 15)),
                    const SizedBox(height: 4),
                    CyberBadge(
                      text: p.badge,
                      color: CyberColors.primaryHotPink,
                      hasDot: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.bio,
                      style: CyberTypography.bodyMedium.copyWith(color: CyberColors.textPrimary),
                    ),
                    if (p.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: CyberColors.secondaryCyan, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            p.location,
                            style: CyberTypography.hudCaption.copyWith(color: CyberColors.secondaryCyan),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Action Buttons (Edit Profile vs Follow/Message)
                    if (widget.isCurrentUser)
                      Row(
                        children: [
                          Expanded(
                            child: CyberButton(
                              label: 'EDIT PROFILE',
                              isOutlined: true,
                              isSmall: true,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CyberButton(
                              label: 'SHARE PROFILE',
                              isOutlined: true,
                              isSmall: true,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: CyberButton(
                              label: p.isFollowing ? 'FOLLOWING' : 'FOLLOW',
                              isOutlined: p.isFollowing,
                              isSmall: true,
                              onPressed: widget.onToggleFollow,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CyberButton(
                              label: 'MESSAGE',
                              isSecondary: true,
                              isSmall: true,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Highlights Carousel
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _highlights.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final h = _highlights[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CyberAvatar(
                                radius: 26,
                                imageUrl: h['image'],
                                hasStory: true,
                                hasUnseenStory: false,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                h['title']!,
                                style: CyberTypography.hudCaption.copyWith(fontSize: 10),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: CyberColors.primaryHotPink,
                  indicatorWeight: 2,
                  labelColor: CyberColors.primaryHotPink,
                  unselectedLabelColor: CyberColors.textMuted,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.movie_outlined)),
                    Tab(icon: Icon(Icons.assignment_ind_outlined)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Gallery Grid
            _buildGalleryGrid(p.gallery),
            // Reels Tab
            _buildGalleryGrid(p.gallery.where((g) => g.type == 'video').toList()),
            // Tagged Tab
            _buildGalleryGrid(p.gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: CyberTypography.hudMetric.copyWith(fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted)),
      ],
    );
  }

  Widget _buildGalleryGrid(List<GalleryItem> gallery) {
    if (gallery.isEmpty) {
      return Center(
        child: Text('NO NEURAL MEDIA', style: CyberTypography.hudCaption),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: gallery.length,
      itemBuilder: (context, index) {
        final item = gallery[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: CyberColors.surfaceElevated,
                child: const Icon(Icons.image, color: CyberColors.textMuted),
              ),
            ),
            if (item.type == 'video')
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
              ),
            Positioned(
              bottom: 3,
              left: 4,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white70, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${item.likesCount}',
                    style: CyberTypography.hudCaption.copyWith(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: CyberColors.bgVoid,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
