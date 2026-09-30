import 'package:flutter/material.dart';
import '../../data/models/collection_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class SavedCollectionsScreen extends StatelessWidget {
  final List<CollectionItem> collections;
  final VoidCallback onAddCollection;
  final ValueChanged<String> onSelectCollection;
  final VoidCallback onBack;

  const SavedCollectionsScreen({
    super.key,
    required this.collections,
    required this.onAddCollection,
    required this.onSelectCollection,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        title: Text(
          'SAVED VAULT',
          style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: CyberColors.secondaryCyan, size: 26),
            tooltip: 'New Collection',
            onPressed: onAddCollection,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final col = collections[index];
          return GestureDetector(
            onTap: () => onSelectCollection(col.id),
            child: CyberCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                          child: Image.network(
                            col.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: CyberColors.surfaceElevated,
                              child: const Icon(Icons.folder, color: CyberColors.textMuted, size: 36),
                            ),
                          ),
                        ),
                        if (col.isPrivate)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CyberColors.bgVoid.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.lock, size: 12, color: CyberColors.secondaryCyan),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          col.name,
                          style: CyberTypography.bodyBold.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${col.count} items',
                          style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: CyberColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
