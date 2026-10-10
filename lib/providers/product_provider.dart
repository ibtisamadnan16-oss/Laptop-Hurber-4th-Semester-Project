import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../services/notification_service.dart';
import '../utils/dummy_data.dart';

class ProductProvider extends ChangeNotifier {
  static final ProductProvider _instance = ProductProvider._internal();
  factory ProductProvider() => _instance;
  ProductProvider._internal() {
    _products = List.from(DummyData.products);
    _categories = List.from(DummyData.categories);
    _brands = List.from(DummyData.brands);
    _seedDemoOrders();
  }

  late List<ProductModel> _products;
  late List<CategoryModel> _categories;
  late List<String> _brands;
  final Set<String> _wishlistIds = {};
  final Map<String, int> _cart = {};
  final List<OrderModel> _orders = [];
  final Map<String, List<ReviewModel>> _reviews = {};

  List<ProductModel> get products => List.unmodifiable(_products);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<String> get brands => List.unmodifiable(_brands);
  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);
  Map<String, int> get cart => Map.unmodifiable(_cart);
  List<OrderModel> get orders => List.unmodifiable(_orders);

  int get cartCount => _cart.values.fold(0, (total, qty) => total + qty);
  int get wishlistCount => _wishlistIds.length;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _pageSize = 6;
  DateTime? _lastFetchTime;
  static const Duration cacheTtl = Duration(minutes: 5);

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get isCacheValid =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < cacheTtl;

  bool get hasMoreProducts => (_currentPage * _pageSize) < _products.length;

  List<ProductModel> get paginatedProducts =>
      _products.take(_currentPage * _pageSize).toList();

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setPageSize(int size) {
    _pageSize = size;
    notifyListeners();
  }

  void resetPagination() {
    _currentPage = 1;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMoreProducts(
      {Duration latency = const Duration(milliseconds: 300)}) async {
    if (_isLoadingMore || !hasMoreProducts) return;
    _isLoadingMore = true;
    notifyListeners();

    if (latency.inMilliseconds > 0) {
      await Future.delayed(latency);
    }

    _currentPage++;
    _isLoadingMore = false;
    notifyListeners();
  }

  List<ProductModel> paginateList(
    List<ProductModel> list, {
    int? page,
    int? limit,
  }) {
    final effectiveLimit = limit ?? _pageSize;
    final effectivePage = page ?? _currentPage;
    final count = effectivePage * effectiveLimit;
    if (count >= list.length) {
      return List.unmodifiable(list);
    }
    return List.unmodifiable(list.take(count));
  }

  bool hasMoreInList(List<ProductModel> list, {int? page, int? limit}) {
    final effectiveLimit = limit ?? _pageSize;
    final effectivePage = page ?? _currentPage;
    return (effectivePage * effectiveLimit) < list.length;
  }

  Future<List<ProductModel>> fetchProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && isCacheValid && _products.isNotEmpty) {
      return products;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snap = await FirebaseFirestore.instance
          .collection('laptops')
          .limit(50)
          .get();

      if (snap.docs.isNotEmpty) {
        final List<ProductModel> remote = [];
        for (final doc in snap.docs) {
          try {
            remote.add(ProductModel.fromMap(doc.id, doc.data()));
          } catch (_) {}
        }
        if (remote.isNotEmpty) {
          _products = remote;
        }
      }
      _lastFetchTime = DateTime.now();
    } catch (_) {
      _lastFetchTime = DateTime.now();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return products;
  }

  List<ProductModel> get featuredLaptops =>
      _products.where((p) => p.isFeatured).toList();

  List<ProductModel> get latestLaptops =>
      _products.where((p) => p.isLatest).toList();

  List<ProductModel> get popularProducts => List.from(_products)
    ..sort((a, b) => b.popularity.compareTo(a.popularity));

  List<ProductModel> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);
  bool isWishlisted(String productId) => isInWishlist(productId);
  int cartQuantity(String productId) => _cart[productId] ?? 0;

  void addToWishlist(String productId) {
    if (!_wishlistIds.contains(productId)) {
      _wishlistIds.add(productId);
      _syncWishlistToFirestore(productId, true);
      notifyListeners();
    }
  }

  void removeFromWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      _syncWishlistToFirestore(productId, false);
      notifyListeners();
    }
  }

  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      _syncWishlistToFirestore(productId, false);
    } else {
      _wishlistIds.add(productId);
      _syncWishlistToFirestore(productId, true);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistIds.clear();
    _clearFirestoreWishlist();
    notifyListeners();
  }

  List<CartItemModel> get cartItems {
    final list = <CartItemModel>[];
    _cart.forEach((productId, qty) {
      final p = getProductById(productId);
      if (p != null) {
        list.add(CartItemModel(product: p, quantity: qty));
      }
    });
    return list;
  }

  double get cartSubtotal {
    double total = 0;
    _cart.forEach((productId, qty) {
      final p = getProductById(productId);
      if (p != null) {
        total += p.price * qty;
      }
    });
    return total;
  }

  double get cartShipping => cartSubtotal > 0 ? 500.0 : 0.0;

  double get cartTax => cartSubtotal > 0 ? 2000.0 : 0.0;

  double get cartTotal => cartSubtotal + cartShipping + cartTax;

  String _formatCurrency(double amount) {
    final str = amount.round().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return 'Rs. ${buffer.toString().split('').reversed.join('')}';
  }

  String get formattedSubtotal => _formatCurrency(cartSubtotal);
  String get formattedShipping => _formatCurrency(cartShipping);
  String get formattedTax => _formatCurrency(cartTax);
  String get formattedTotal => _formatCurrency(cartTotal);

  bool isProductAvailable(String productId) {
    final product = getProductById(productId);
    return product != null && product.stock > 0;
  }

  bool addToCart(String productId, [int quantity = 1]) {
    final product = getProductById(productId);
    if (product != null && product.stock <= 0) {
      return false;
    }

    final current = _cart[productId] ?? 0;
    final maxStock = product?.stockQuantity ?? 99;
    if (current + quantity > maxStock) {
      _cart[productId] = maxStock;
    } else {
      _cart[productId] = current + quantity;
    }
    _syncToFirestore(productId, _cart[productId]!);
    notifyListeners();
    return true;
  }

  void removeFromCart(String productId) {
    _cart.remove(productId);
    _syncToFirestore(productId, 0);
    notifyListeners();
  }

  void updateCartQty(String productId, int quantity) {
    if (quantity <= 0) {
      _cart.remove(productId);
      _syncToFirestore(productId, 0);
    } else {
      _cart[productId] = quantity;
      _syncToFirestore(productId, quantity);
    }
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final current = _cart[productId] ?? 0;
    final product = getProductById(productId);
    final maxStock = product?.stockQuantity ?? 99;
    if (current < maxStock) {
      _cart[productId] = current + 1;
      _syncToFirestore(productId, current + 1);
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final current = _cart[productId] ?? 0;
    if (current > 1) {
      _cart[productId] = current - 1;
      _syncToFirestore(productId, current - 1);
      notifyListeners();
    } else if (current == 1) {
      removeFromCart(productId);
    }
  }

  void clearCart() {
    _cart.clear();
    _clearFirestoreCart();
    notifyListeners();
  }

  Future<OrderModel> placeOrder({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required String paymentMethod,
  }) async {
    if (_cart.isEmpty) {
      throw 'Cart is empty. Please add items before placing an order.';
    }

    final nextNumber = 1004 + _orders.length;
    final orderId = 'LH-$nextNumber';
    String uid = 'guest_user';
    try {
      uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
    } catch (_) {}

    final itemsMap = cartItems.map((item) => item.toMap()).toList();
    final subtotal = cartSubtotal;
    final shipping = cartShipping;
    final tax = cartTax;
    final total = cartTotal;

    final order = OrderModel(
      id: orderId,
      userId: uid,
      fullName: fullName,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      paymentMethod: paymentMethod,
      items: itemsMap,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      total: total,
      createdAt: DateTime.now(),
      status: 'Pending',
    );

    _orders.insert(0, order);
    _cart.clear();
    _clearFirestoreCart();

    _syncOrderToFirestore(order);

    notifyListeners();
    return order;
  }

  void _syncOrderToFirestore(OrderModel order) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final db = FirebaseFirestore.instance;

      db
          .collection('orders')
          .doc(order.id)
          .set(order.toMap())
          .catchError((_) {});

      if (uid != null) {
        db
            .collection('users')
            .doc(uid)
            .collection('orders')
            .doc(order.id)
            .set(order.toMap())
            .catchError((_) {});
      }
    } catch (_) {}
  }

  OrderModel? getOrderById(String orderId) {
    try {
      final clean = orderId.replaceAll('LH', '').replaceAll('-', '');
      return _orders.firstWhere((o) =>
          o.id == orderId ||
          o.id.replaceAll('LH', '').replaceAll('-', '') == clean);
    } catch (_) {
      return null;
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final idx = _orders.indexWhere((o) =>
        o.id == orderId ||
        o.id == orderId.replaceFirst('LH', '').replaceFirst('-', '') ||
        'LH${o.id}' == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: newStatus);
      _syncOrderToFirestore(_orders[idx]);
      try {
        NotificationService().sendOrderStatusNotification(
          orderId: _orders[idx].orderId,
          status: newStatus,
        );
      } catch (_) {}
      notifyListeners();
    }
  }

  void addProduct(ProductModel product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(ProductModel product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _wishlistIds.remove(productId);
    _cart.remove(productId);
    notifyListeners();
  }

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((c) => c.id == categoryId || c.title == categoryId);
    notifyListeners();
  }

  void addBrand(String brand) {
    if (!_brands.contains(brand)) {
      _brands.add(brand);
      notifyListeners();
    }
  }

  void deleteBrand(String brand) {
    _brands.remove(brand);
    notifyListeners();
  }

  Map<String, List<ReviewModel>> get allReviews => Map.unmodifiable(_reviews);

  void deleteReview(String productId, String reviewId) {
    if (_reviews.containsKey(productId)) {
      _reviews[productId]!.removeWhere((r) => r.id == reviewId);
      final prodIdx = _products.indexWhere((p) => p.id == productId);
      if (prodIdx != -1) {
        final remaining = _reviews[productId]!;
        final newCount = remaining.length;
        final newRating = remaining.isEmpty
            ? 0.0
            : remaining.fold(0.0, (acc, r) => acc + r.rating) / newCount;
        _products[prodIdx] = _products[prodIdx].copyWith(
          rating: double.parse(newRating.toStringAsFixed(1)),
          reviewsCount: newCount,
        );
      }
      notifyListeners();
    }
  }

  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, 'Cancelled');
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  void _seedDemoOrders() {
    if (_orders.isNotEmpty) return;
    _orders.addAll([
      OrderModel(
        id: '1003',
        userId: 'demo_user',
        fullName: 'Muhammad Ali',
        phone: '0300 1234567',
        address: 'House 14, Block 6, PECHS',
        city: 'Karachi',
        postalCode: '75400',
        paymentMethod: 'Cash on Delivery',
        items: [
          {
            'productId': 'p3',
            'name': 'Lenovo ThinkPad X1 Carbon',
            'price': 135000.0,
            'quantity': 1,
            'imageUrl': DummyData.products.length > 2
                ? DummyData.products[2].imageUrl
                : '',
          }
        ],
        subtotal: 135000.0,
        shipping: 500.0,
        tax: 2000.0,
        total: 137500.0,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'Processing',
      ),
      OrderModel(
        id: '1002',
        userId: 'demo_user',
        fullName: 'Muhammad Ali',
        phone: '0300 1234567',
        address: 'House 14, Block 6, PECHS',
        city: 'Karachi',
        postalCode: '75400',
        paymentMethod: 'Cash on Delivery',
        items: [
          {
            'productId': 'p1',
            'name': 'HP EliteBook 840 G8',
            'price': 95000.0,
            'quantity': 1,
            'imageUrl': DummyData.products.first.imageUrl,
          }
        ],
        subtotal: 95000.0,
        shipping: 500.0,
        tax: 2000.0,
        total: 97500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Shipped',
      ),
      OrderModel(
        id: '1001',
        userId: 'demo_user',
        fullName: 'Muhammad Ali',
        phone: '0300 1234567',
        address: 'House 14, Block 6, PECHS',
        city: 'Karachi',
        postalCode: '75400',
        paymentMethod: 'Debit/Credit Card',
        items: [
          {
            'productId': 'p2',
            'name': 'Dell Latitude 7420',
            'price': 110000.0,
            'quantity': 1,
            'imageUrl': DummyData.products.length > 1
                ? DummyData.products[1].imageUrl
                : '',
          }
        ],
        subtotal: 110000.0,
        shipping: 500.0,
        tax: 2000.0,
        total: 112500.0,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'Delivered',
      ),
    ]);
  }

  void _syncToFirestore(String productId, int qty) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId);
      if (qty <= 0) {
        ref.delete().catchError((_) {});
      } else {
        final p = getProductById(productId);
        ref.set({
          'productId': productId,
          'qty': qty,
          'name': p?.name ?? '',
          'price': p?.price ?? 0,
          'imageUrl': p?.imageUrl ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      }
    } catch (_) {}
  }

  void _clearFirestoreCart() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');
      col.get().then((snap) {
        for (final doc in snap.docs) {
          doc.reference.delete().catchError((_) {});
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  void _syncWishlistToFirestore(String productId, bool isAdded) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(productId);
      if (!isAdded) {
        ref.delete().catchError((_) {});
      } else {
        final p = getProductById(productId);
        ref.set({
          'productId': productId,
          'name': p?.name ?? '',
          'price': p?.price ?? 0,
          'rating': p?.rating ?? 4.5,
          'imageUrl': p?.imageUrl ?? '',
          'brand': p?.brand ?? '',
          'savedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      }
    } catch (_) {}
  }

  void _clearFirestoreWishlist() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wishlist');
      col.get().then((snap) {
        for (final doc in snap.docs) {
          doc.reference.delete().catchError((_) {});
        }
      }).catchError((_) {});
    } catch (_) {}
  }

  List<ProductModel> filterProducts({
    String? searchQuery,
    String? category,
    String? brand,
    Set<String>? selectedBrands,
    double? minPrice,
    double? maxPrice,
    Set<String>? selectedRams,
    Set<String>? selectedStorages,
    Set<String>? selectedProcessors,
    Set<String>? selectedScreenSizes,
    double? minRating,
    String? sortBy,
  }) {
    return _products.where((item) {
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryTerms =
            searchQuery.toLowerCase().trim().split(RegExp(r'\s+'));
        final searchableText =
            '${item.name} ${item.brand} ${item.category} ${item.specSubtitle} ${item.resolvedProcessor} ${item.resolvedRam} ${item.resolvedStorage} ${item.description}'
                .toLowerCase();

        final matchesAllTerms =
            queryTerms.every((term) => searchableText.contains(term));
        if (!matchesAllTerms) return false;
      }

      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all') {
        if (!item.category.toLowerCase().contains(category.toLowerCase())) {
          return false;
        }
      }

      if (brand != null && brand.isNotEmpty && brand.toLowerCase() != 'all') {
        if (item.brand.toLowerCase() != brand.toLowerCase()) return false;
      }
      if (selectedBrands != null &&
          selectedBrands.isNotEmpty &&
          !selectedBrands.contains('All')) {
        final brandMatches = selectedBrands
            .any((b) => b.toLowerCase() == item.brand.toLowerCase());
        if (!brandMatches) return false;
      }

      if (minPrice != null && item.price < minPrice) return false;
      if (maxPrice != null && item.price > maxPrice) return false;

      if (selectedRams != null && selectedRams.isNotEmpty) {
        final ramText = '${item.ram} ${item.resolvedRam}'.toLowerCase();
        final matchesRam = selectedRams.any((r) {
          final clean = r.replaceAll(' ', '').toLowerCase();
          return ramText.contains(clean) || ramText.contains(r.toLowerCase());
        });
        if (!matchesRam) return false;
      }

      if (selectedStorages != null && selectedStorages.isNotEmpty) {
        final storageText =
            '${item.storage} ${item.resolvedStorage}'.toLowerCase();
        final matchesStorage = selectedStorages.any((s) {
          final clean = s.replaceAll(' ', '').toLowerCase();
          return storageText.contains(clean) ||
              storageText.contains(s.toLowerCase());
        });
        if (!matchesStorage) return false;
      }

      if (selectedProcessors != null && selectedProcessors.isNotEmpty) {
        final procText =
            '${item.processor} ${item.resolvedProcessor} ${item.specSubtitle}'
                .toLowerCase();
        final matchesProc = selectedProcessors.any((p) {
          final lower = p.toLowerCase();
          if (lower.contains('apple') ||
              lower.contains('m-series') ||
              lower.contains('m2') ||
              lower.contains('m3')) {
            return procText.contains('m2') ||
                procText.contains('m3') ||
                procText.contains('apple');
          }
          if (lower.contains('ryzen')) {
            return procText.contains('ryzen') || procText.contains('amd');
          }
          return procText.contains(lower.replaceAll(' ', '')) ||
              procText.contains(lower);
        });
        if (!matchesProc) return false;
      }

      if (selectedScreenSizes != null && selectedScreenSizes.isNotEmpty) {
        final screenText =
            '${item.screenSize} ${item.resolvedScreenSize}'.toLowerCase();
        final matchesScreen = selectedScreenSizes.any((size) {
          if (size.contains('13') || size.contains('14')) {
            return screenText.contains('13.') ||
                screenText.contains('14.') ||
                screenText.contains('13"') ||
                screenText.contains('14"');
          }
          if (size.contains('15') || size.contains('16')) {
            return screenText.contains('15.') ||
                screenText.contains('16.') ||
                screenText.contains('15"') ||
                screenText.contains('16"');
          }
          if (size.contains('17')) {
            return screenText.contains('17.') || screenText.contains('17"');
          }
          return screenText.contains(size.toLowerCase());
        });
        if (!matchesScreen) return false;
      }

      if (minRating != null && item.rating < minRating) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        switch (sortBy) {
          case 'price_low_high':
            return a.price.compareTo(b.price);
          case 'price_high_low':
            return b.price.compareTo(a.price);
          case 'newest':
            if (a.isLatest && !b.isLatest) return -1;
            if (!a.isLatest && b.isLatest) return 1;
            return b.popularity.compareTo(a.popularity);
          case 'best_rated':
            return b.rating.compareTo(a.rating);
          case 'popular':
          default:
            return b.popularity.compareTo(a.popularity);
        }
      });
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ReviewModel> getReviews(String productId) {
    if (!_reviews.containsKey(productId)) {
      _reviews[productId] = [
        ReviewModel(
          id: 'rev_${productId}_1',
          productId: productId,
          userId: 'user_ali',
          userName: 'Muhammad Ali',
          rating: 5.0,
          comment:
              'Very good laptop. Performance and battery timing is excellent.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          helpfulCount: 24,
        ),
        ReviewModel(
          id: 'rev_${productId}_2',
          productId: productId,
          userId: 'user_sara',
          userName: 'Sara Ahmed',
          rating: 5.0,
          comment:
              'Display is super crisp and colors are vibrant. The keyboard is comfortable for extended coding sessions.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          helpfulCount: 16,
        ),
        ReviewModel(
          id: 'rev_${productId}_3',
          productId: productId,
          userId: 'user_hassan',
          userName: 'Hassan Raza',
          rating: 4.0,
          comment:
              'Fast boot time and solid thermals. Highly recommended for business and student tasks.',
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          helpfulCount: 9,
        ),
      ];
    }
    return List.unmodifiable(_reviews[productId]!);
  }

  bool hasUserPurchasedProduct(String productId) {
    for (final order in _orders) {
      if (order.status != 'Cancelled') {
        final matches = order.items.any((item) =>
            item['productId'] == productId ||
            (item['name'] != null &&
                getProductById(productId)?.name == item['name']));
        if (matches) return true;
      }
    }
    return false;
  }

  Future<ReviewModel> submitReview({
    required String productId,
    required double rating,
    required String comment,
    String? userName,
  }) async {
    getReviews(productId);
    final list = _reviews[productId] ?? [];

    String? authorName = userName;
    String uid = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (authorName == null && user != null) {
        authorName = user.displayName != null && user.displayName!.isNotEmpty
            ? user.displayName
            : (user.email != null ? user.email!.split('@')[0] : 'Customer');
        uid = user.uid;
      }
    } catch (_) {}
    authorName ??= 'Customer';

    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      userId: uid,
      userName: authorName,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
      helpfulCount: 0,
    );

    list.insert(0, newReview);
    _reviews[productId] = list;

    final pIdx = _products.indexWhere((p) => p.id == productId);
    if (pIdx != -1) {
      final oldProduct = _products[pIdx];
      final newCount = oldProduct.reviewsCount + 1;
      final newRating = double.parse(
          (((oldProduct.rating * oldProduct.reviewsCount) + rating) / newCount)
              .toStringAsFixed(1));

      _products[pIdx] = ProductModel(
        id: oldProduct.id,
        name: oldProduct.name,
        brand: oldProduct.brand,
        category: oldProduct.category,
        specSubtitle: oldProduct.specSubtitle,
        price: oldProduct.price,
        originalPrice: oldProduct.originalPrice,
        imageUrl: oldProduct.imageUrl,
        images: oldProduct.images,
        description: oldProduct.description,
        rating: newRating,
        reviewsCount: newCount,
        stock: oldProduct.stock,
        isFeatured: oldProduct.isFeatured,
        isLatest: oldProduct.isLatest,
        popularity: oldProduct.popularity,
        specifications: oldProduct.specifications,
        processor: oldProduct.processor,
        ram: oldProduct.ram,
        storage: oldProduct.storage,
        gpu: oldProduct.gpu,
        screenSize: oldProduct.screenSize,
        operatingSystem: oldProduct.operatingSystem,
      );
    }

    try {
      FirebaseFirestore.instance
          .collection('reviews')
          .doc(productId)
          .collection('items')
          .doc(newReview.id)
          .set(newReview.toMap())
          .catchError((_) {});
    } catch (_) {}

    notifyListeners();
    return newReview;
  }
}
