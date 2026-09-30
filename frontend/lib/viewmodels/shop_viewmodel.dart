import 'package:flutter/foundation.dart';
import '../data/models/shop_model.dart';
import '../data/models/collection_model.dart';
import '../data/repositories/social_repositories.dart';

class ShopViewModel extends ChangeNotifier {
  final ShopRepository _shopRepo;
  final CollectionRepository _colRepo;

  ShopViewModel({
    ShopRepository? shopRepo,
    CollectionRepository? colRepo,
  })  : _shopRepo = shopRepo ?? ShopRepository(),
        _colRepo = colRepo ?? CollectionRepository();

  List<ShopProduct> _products = [];
  List<ShopProduct> get products => _products;

  List<CollectionItem> _collections = [];
  List<CollectionItem> get collections => _collections;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _shopRepo.fetchProducts(),
        _colRepo.fetchCollections(),
      ]);
      _products = results[0] as List<ShopProduct>;
      _collections = results[1] as List<CollectionItem>;
    } catch (e) {
      debugPrint('[ShopViewModel] init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<ShopProduct> get filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  void toggleWishlist(String productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _products[idx];
      _products[idx] = p.copyWith(isWishlisted: !p.isWishlisted);
      notifyListeners();
    }
  }
}
