import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_collections.dart';
import '../models/product_model.dart';
import '../utils/dummy_data.dart';

class ProductService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static final Map<String, _CachedResult> _queryCache = {};
  static const Duration cacheDuration = Duration(minutes: 5);

  Query<Map<String, dynamic>>? buildOptimizedQuery({
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
    String? category,
    String? brand,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) {
    try {
      Query<Map<String, dynamic>> query = _db.collection(Fc.laptops);

      if (brand != null && brand.isNotEmpty && brand != 'All') {
        query = query.where('brand', isEqualTo: brand);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (sortBy == 'price_low_high' || sortBy == 'priceAsc') {
        query = query.orderBy('price', descending: false);
      } else if (sortBy == 'price_high_low' || sortBy == 'priceDesc') {
        query = query.orderBy('price', descending: true);
      } else if (sortBy == 'best_rated') {
        query = query.orderBy('rating', descending: true);
      } else if (sortBy == 'newest') {
        query = query.orderBy('isLatest', descending: true);
      } else {
        query = query.orderBy('popularity', descending: true);
      }

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      return query.limit(limit);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> fetchOptimizedLaptops({
    int limit = 10,
    DocumentSnapshot? startAfterDoc,
    String? category,
    String? brand,
    String? sortBy,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '$category-$brand-$sortBy-$limit-${startAfterDoc?.id ?? 'start'}';

    if (!forceRefresh && _queryCache.containsKey(cacheKey)) {
      final cached = _queryCache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < cacheDuration) {
        return cached.items;
      }
    }

    try {
      final query = buildOptimizedQuery(
        limit: limit,
        startAfterDoc: startAfterDoc,
        category: category,
        brand: brand,
        sortBy: sortBy,
      );

      if (query != null) {
        final snapshot = await query.get().timeout(const Duration(seconds: 2));
        final items = snapshot.docs.map((doc) {
          return ProductModel.fromMap(doc.id, doc.data());
        }).toList();

        if (items.isNotEmpty) {
          _queryCache[cacheKey] =
              _CachedResult(items: items, timestamp: DateTime.now());
          return items;
        }
      }
    } catch (_) {}

    var fallback = List<ProductModel>.from(DummyData.products);
    if (brand != null && brand.isNotEmpty && brand != 'All') {
      fallback = fallback
          .where((p) => p.brand.toLowerCase() == brand.toLowerCase())
          .toList();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      fallback = fallback
          .where(
              (p) => p.category.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
    final limited = fallback.take(limit).toList();
    _queryCache[cacheKey] =
        _CachedResult(items: limited, timestamp: DateTime.now());
    return limited;
  }

  static void clearCache() {
    _queryCache.clear();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> laptopsStream({
    int limit = 20,
    String? brand,
    String? category,
  }) {
    try {
      Query<Map<String, dynamic>> query = _db.collection(Fc.laptops);
      if (brand != null && brand.isNotEmpty && brand != 'All') {
        query = query.where('brand', isEqualTo: brand);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      return query.limit(limit).snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchesStream({
    String? brand,
    String? type,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) {
    try {
      Query<Map<String, dynamic>> q = _db.collection(Fc.watches);

      if (brand != null && brand.isNotEmpty)
        q = q.where('brand', isEqualTo: brand);
      if (type != null && type.isNotEmpty) q = q.where('type', isEqualTo: type);
      if (minPrice != null)
        q = q.where('price', isGreaterThanOrEqualTo: minPrice);
      if (maxPrice != null) q = q.where('price', isLessThanOrEqualTo: maxPrice);

      if (sortBy == 'priceAsc') {
        q = q.orderBy('price');
      } else if (sortBy == 'priceDesc') {
        q = q.orderBy('price', descending: true);
      } else {
        q = q.orderBy('popularity', descending: true);
      }

      return q.snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getWatch(String id) {
    try {
      return _db.collection(Fc.watches).doc(id).get();
    } catch (_) {
      return Future.value(null);
    }
  }
}

class _CachedResult {
  final List<ProductModel> items;
  final DateTime timestamp;

  _CachedResult({required this.items, required this.timestamp});
}
