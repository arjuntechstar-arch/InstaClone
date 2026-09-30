/// Models for Cyber Shop Marketplace & Drops
class ShopProduct {
  final String id;
  final String title;
  final double price;
  final String brand;
  final String imageUrl;
  final bool inStock;
  final bool isWishlisted;
  final String category;
  final double rating;

  const ShopProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.brand,
    required this.imageUrl,
    this.inStock = true,
    this.isWishlisted = false,
    this.category = 'Techwear',
    this.rating = 4.8,
  });

  ShopProduct copyWith({
    String? id,
    String? title,
    double? price,
    String? brand,
    String? imageUrl,
    bool? inStock,
    bool? isWishlisted,
    String? category,
    double? rating,
  }) {
    return ShopProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      category: category ?? this.category,
      rating: rating ?? this.rating,
    );
  }

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      brand: json['brand'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      inStock: json['inStock'] as bool? ?? true,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
      category: json['category'] as String? ?? 'Techwear',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'brand': brand,
    'imageUrl': imageUrl,
    'inStock': inStock,
    'isWishlisted': isWishlisted,
    'category': category,
    'rating': rating,
  };
}
