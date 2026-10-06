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
  final Function(Map<String, dynamic> updates)? onUpdateProfile;
  final Function(String username)? onSwitchPersona;
  final List<Map<String, dynamic>>? availableRoles;
  final VoidCallback? onMessage;
  final Function(GalleryItem item)? onPostSelected;

  const UserProfileScreen({
    super.key,
    required this.profile,
    this.isCurrentUser = true,
    this.onToggleFollow,
    this.onOpenSettings,
    this.onOpenSaved,
    this.onOpenShop,
    this.onBack,
    this.onUpdateProfile,
    this.onSwitchPersona,
    this.availableRoles,
    this.onMessage,
    this.onPostSelected,
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

  void _showEditProfileModal(BuildContext context, UserProfile p) {
    final nameCtrl = TextEditingController(text: p.displayName);
    final bioCtrl = TextEditingController(text: p.bio);
    final locCtrl = TextEditingController(text: p.location);
    bool isPrivateVal = p.isPrivate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: CyberColors.surfaceModal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: CyberColors.secondaryCyan, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CyberColors.borderHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EDIT NEURAL IDENTITY',
                      style: CyberTypography.hudHeader.copyWith(
                        color: CyberColors.secondaryCyan,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: CyberColors.textSecondary, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('DISPLAY NAME', style: CyberTypography.hudCaption.copyWith(fontSize: 10)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  style: CyberTypography.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CyberColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.primaryHotPink),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text('BIO / NEURAL STATUS', style: CyberTypography.hudCaption.copyWith(fontSize: 10)),
                const SizedBox(height: 6),
                TextField(
                  controller: bioCtrl,
                  maxLines: 2,
                  style: CyberTypography.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CyberColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.primaryHotPink),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                Text('SECTOR / LOCATION', style: CyberTypography.hudCaption.copyWith(fontSize: 10)),
                const SizedBox(height: 6),
                TextField(
                  controller: locCtrl,
                  style: CyberTypography.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CyberColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: CyberColors.primaryHotPink),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                // Account Privacy Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CyberColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: CyberColors.tertiaryYellow, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Private Account Node', style: CyberTypography.bodyBold.copyWith(fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              'When private, only approved nodes can decrypt your feed & gallery',
                              style: CyberTypography.hudCaption.copyWith(color: CyberColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isPrivateVal,
                        activeColor: CyberColors.secondaryCyan,
                        onChanged: (v) {
                          setModalState(() {
                            isPrivateVal = v;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CyberButton(
                    label: 'SAVE IDENTITY UPDATES',
                    onPressed: () {
                      widget.onUpdateProfile?.call({
                        'displayName': nameCtrl.text.trim(),
                        'bio': bioCtrl.text.trim(),
                        'location': locCtrl.text.trim(),
                        'isPrivate': isPrivateVal,
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: CyberColors.surfaceModal,
                          content: Text('Neural identity updated successfully! ⚡', style: CyberTypography.bodyMedium),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareProfileModal(BuildContext context, UserProfile p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: CyberColors.surfaceModal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: CyberColors.primaryHotPink, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CyberColors.borderHighlight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'TRANSMIT NEURAL PROFILE',
              style: CyberTypography.hudHeader.copyWith(
                color: CyberColors.primaryHotPink,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            CyberAvatar(
              radius: 40,
              imageUrl: p.avatarUrl,
              hasStory: true,
              isVerified: p.isVerified,
            ),
            const SizedBox(height: 10),
            Text(
              '@${p.username}',
              style: CyberTypography.titleMedium.copyWith(color: CyberColors.secondaryCyan),
            ),
            const SizedBox(height: 4),
            Text(
              p.displayName,
              style: CyberTypography.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            CyberBadge(
              text: p.badge,
              color: CyberColors.secondaryCyan,
              hasDot: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CyberButton(
                    label: 'COPY NEURAL LINK',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: CyberColors.surfaceModal,
                          content: Text('Copied https://tokyo.gram/@${p.username} to clipboard! ⚡',
                              style: CyberTypography.bodyMedium),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CyberButton(
                    label: 'DONE',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            if (p.isPrivate) ...[
              const SizedBox(width: 5),
              const Icon(Icons.lock, color: CyberColors.tertiaryYellow, size: 14),
            ],
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
              onPressed: () => _showShareProfileModal(context, p),
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
                    if (widget.isCurrentUser) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CyberButton(
                              label: 'EDIT PROFILE',
                              isOutlined: true,
                              isSmall: true,
                              onPressed: () => _showEditProfileModal(context, p),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CyberButton(
                              label: 'SHARE PROFILE',
                              isOutlined: true,
                              isSmall: true,
                              onPressed: () => _showShareProfileModal(context, p),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Persona Switcher Chips
                      Text(
                        'QUICK SWITCH NEURAL PERSONA',
                        style: CyberTypography.hudCaption.copyWith(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: CyberColors.secondaryCyan,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildRoleChip('cyber_ren', 'Creator', p.username == 'cyber_ren'),
                            const SizedBox(width: 6),
                            _buildRoleChip('neon_kaito', 'Modder', p.username == 'neon_kaito'),
                            const SizedBox(width: 6),
                            _buildRoleChip('kira_synth', 'Streamer', p.username == 'kira_synth'),
                            const SizedBox(width: 6),
                            _buildRoleChip('neotech_admin', 'Merchant', p.username == 'neotech_admin'),
                            const SizedBox(width: 6),
                            _buildRoleChip('anon_mesh', 'Guest', p.username == 'anon_mesh'),
                          ],
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: _buildProfileFollowButton(p),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CyberButton(
                              label: 'MESSAGE',
                              isSecondary: true,
                              isSmall: true,
                              onPressed: widget.onMessage,
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
            if (widget.isCurrentUser || !p.isPrivate || p.isFollowing)
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
        body: (!widget.isCurrentUser && p.isPrivate && !p.isFollowing)
            ? _buildPrivateAccountLock(p)
            : TabBarView(
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

  Widget _buildProfileFollowButton(UserProfile p) {
    if (p.isFollowing) {
      return CyberButton(
        label: 'FOLLOWING',
        isOutlined: true,
        isSmall: true,
        onPressed: widget.onToggleFollow,
      );
    }
    if (p.isPrivate) {
      if (p.isFollowRequested) {
        return CyberButton(
          label: 'REQUESTED',
          isOutlined: true,
          isSmall: true,
          onPressed: widget.onToggleFollow,
        );
      }
      return CyberButton(
        label: 'REQUEST ACCESS',
        isSmall: true,
        onPressed: widget.onToggleFollow,
      );
    }
    return CyberButton(
      label: 'FOLLOW',
      isSmall: true,
      onPressed: widget.onToggleFollow,
    );
  }

  Widget _buildPrivateAccountLock(UserProfile p) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Holographic Lock Reticle with glow
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CyberColors.surfaceDark,
                border: Border.all(
                  color: CyberColors.tertiaryYellow,
                  width: 2,
                ),
                boxShadow: CyberColors.yellowGlowShadow(blur: 24, spread: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 42,
                  color: CyberColors.tertiaryYellow,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'THIS ACCOUNT IS PRIVATE',
              style: CyberTypography.hudHeader.copyWith(
                fontSize: 16,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Follow this node to view their media, holographic reels, and telemetry streams.',
              style: CyberTypography.bodySecondary.copyWith(
                color: CyberColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: _buildProfileFollowButton(p),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: CyberColors.surfaceModal,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: CyberColors.borderSubtle,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 13, color: CyberColors.secondaryCyan),
                  const SizedBox(width: 6),
                  Text(
                    'QUANTUM 4096-BIT ENCRYPTION',
                    style: CyberTypography.hudCaption.copyWith(
                      color: CyberColors.secondaryCyan,
                      fontSize: 9,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String username, String roleLabel, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        if (!isCurrent) {
          widget.onSwitchPersona?.call(username);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: CyberColors.surfaceModal,
              duration: const Duration(seconds: 2),
              content: Text('Switched persona to @$username ($roleLabel) ⚡',
                  style: CyberTypography.bodyMedium),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent
              ? CyberColors.primaryHotPink.withValues(alpha: 0.25)
              : CyberColors.surfaceDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isCurrent ? CyberColors.primaryHotPink : CyberColors.borderSubtle,
            width: 1,
          ),
          boxShadow: isCurrent ? CyberColors.pinkGlowShadow(blur: 6) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent) ...[
              const Icon(Icons.check, color: CyberColors.primaryHotPink, size: 12),
              const SizedBox(width: 4),
            ],
            Text(
              '@$username',
              style: CyberTypography.hudCaption.copyWith(
                color: isCurrent ? Colors.white : CyberColors.textSecondary,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
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
        return GestureDetector(
          onTap: () => widget.onPostSelected?.call(item),
          child: Stack(
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
          ),
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
