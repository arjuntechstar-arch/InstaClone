import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class ExploreScreen extends StatefulWidget {
  final Map<String, dynamic> exploreData;
  final ValueChanged<String>? onTagSelected;
  final ValueChanged<String>? onItemTapped;

  const ExploreScreen({
    super.key,
    required this.exploreData,
    this.onTagSelected,
    this.onItemTapped,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = '#NeoTokyo';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = (widget.exploreData['trendingTags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['#NeoTokyo', '#CyberdeckMod', '#SynthwaveBeats', '#HoloFashion', '#NeuralArt'];

    final items = (widget.exploreData['gridItems'] as List<dynamic>?) ?? [
      {'id': 'e1', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500', 'likesCount': 1420},
      {'id': 'e2', 'type': 'video', 'imageUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500', 'likesCount': 3890},
      {'id': 'e3', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=500', 'likesCount': 2400},
      {'id': 'e4', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=500', 'likesCount': 5120},
      {'id': 'e5', 'type': 'video', 'imageUrl': 'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?w=500', 'likesCount': 9200},
      {'id': 'e6', 'type': 'image', 'imageUrl': 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?w=500', 'likesCount': 3100},
    ];

    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Cyber Search Bar with Scanner Reticle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: CyberReticleWidget(
                cornerLength: 10,
                strokeWidth: 1.5,
                reticleColor: CyberColors.secondaryCyan,
                child: Container(
                  height: 44,
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
                          style: CyberTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search Neo-Tokyo neural mesh...',
                            hintStyle: CyberTypography.bodySecondary,
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
                          onTap: () {
                            setState(() => _searchController.clear());
                          },
                          child: const Icon(Icons.close, color: CyberColors.textSecondary, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Horizontal Trending Tags Chips
            SizedBox(
              height: 38,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CyberColors.primaryHotPink.withValues(alpha: 0.2)
                            : CyberColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? CyberColors.primaryHotPink
                              : CyberColors.borderSubtle,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? CyberColors.pinkGlowShadow(blur: 8)
                            : null,
                      ),
                      child: Text(
                        tag,
                        style: CyberTypography.hudCaption.copyWith(
                          color: isSelected ? Colors.white : CyberColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. Staggered Mosaic / Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
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

                        // Video Badge indicator
                        if (isVideo)
                          const Positioned(
                            top: 6,
                            right: 6,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                        // Likes overlay footer
                        Positioned(
                          bottom: 4,
                          left: 6,
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.white70, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '$likes',
                                style: CyberTypography.hudCaption.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
