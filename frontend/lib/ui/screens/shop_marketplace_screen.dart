import 'package:flutter/material.dart';
import '../../data/models/shop_model.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class ShopMarketplaceScreen extends StatelessWidget {
  final List<ShopProduct> products;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<String> onToggleWishlist;
  final VoidCallback onBack;

  const ShopMarketplaceScreen({
    super.key,
    required this.products,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.onToggleWishlist,
    required this.onBack,
  });

  static const List<String> categories = ['All', 'Optics', 'Techwear', 'Neural Rig', 'Cyberdeck'];

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
          'CYBER MARKETPLACE',
          style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: CyberColors.secondaryCyan),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: CyberColors.primaryHotPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();

                return GestureDetector(
                  onTap: () => onSelectCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CyberColors.secondaryCyan.withValues(alpha: 0.2)
                          : CyberColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? CyberColors.secondaryCyan
                            : CyberColors.borderSubtle,
                        width: 1,
                      ),
                      boxShadow: isSelected ? CyberColors.cyanGlowShadow(blur: 6) : null,
                    ),
                    child: Text(
                      cat,
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
          const SizedBox(height: 10),

          // Product Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text(
                      'NO CYBER DROPS IN THIS SECTOR',
                      style: CyberTypography.hudCaption.copyWith(color: CyberColors.textMuted),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return CyberCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: CyberColors.surfaceElevated,
                                        child: const Icon(Icons.shopping_bag, color: CyberColors.textMuted),
                                      ),
                                    ),
                                  ),
                                  // In Stock chip
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: CyberBadge(
                                      text: product.inStock ? 'IN STOCK' : 'PRE-ORDER',
                                      color: product.inStock ? CyberColors.secondaryCyan : CyberColors.tertiaryYellow,
                                    ),
                                  ),
                                  // Wishlist button
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => onToggleWishlist(product.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: CyberColors.bgVoid.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          product.isWishlisted ? Icons.favorite : Icons.favorite_border,
                                          size: 16,
                                          color: product.isWishlisted ? CyberColors.primaryHotPink : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Product Info
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.brand.toUpperCase(),
                                    style: CyberTypography.hudCaption.copyWith(fontSize: 9, color: CyberColors.textMuted),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.title,
                                    style: CyberTypography.bodyBold.copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: CyberTypography.hudMetric.copyWith(
                                          color: CyberColors.secondaryCyan,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: CyberColors.tertiaryYellow, size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${product.rating}',
                                            style: CyberTypography.hudCaption.copyWith(fontSize: 10, color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ],
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
    );
  }
}
