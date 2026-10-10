import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';

void main() {
  group('Phase 5 — Search Queries Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('Search: "HP EliteBook" finds HP EliteBook 840 G8', () {
      final results = provider.filterProducts(searchQuery: 'HP EliteBook');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((p) => p.name.contains('HP EliteBook')), isTrue);
      expect(results.first.brand, equals('HP'));
    });

    test('Search: "Dell Latitude" finds Dell Latitude 7420', () {
      final results = provider.filterProducts(searchQuery: 'Dell Latitude');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((p) => p.name.contains('Dell Latitude')), isTrue);
      expect(results.first.brand, equals('Dell'));
    });

    test('Search: "MacBook" finds Apple MacBook Air M2', () {
      final results = provider.filterProducts(searchQuery: 'MacBook');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((p) => p.name.contains('MacBook')), isTrue);
      expect(results.first.brand, equals('Apple'));
    });

    test('Search: "Lenovo ThinkPad" finds Lenovo ThinkPad X1 Carbon', () {
      final results = provider.filterProducts(searchQuery: 'Lenovo ThinkPad');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((p) => p.name.contains('ThinkPad')), isTrue);
      expect(results.first.brand, equals('Lenovo'));
    });
  });

  group('Phase 5 — Multi-Filter Testing', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('Filter by Brand: HP only', () {
      final results = provider.filterProducts(selectedBrands: {'HP'});
      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.brand.toLowerCase() == 'hp'), isTrue);
    });

    test('Filter by Multiple Brands: HP and Dell', () {
      final results = provider.filterProducts(selectedBrands: {'HP', 'Dell'});
      expect(results.isNotEmpty, isTrue);
      expect(
          results.every((p) => p.brand == 'HP' || p.brand == 'Dell'), isTrue);
      expect(results.any((p) => p.brand == 'HP'), isTrue);
      expect(results.any((p) => p.brand == 'Dell'), isTrue);
    });

    test('Filter by RAM: 16 GB', () {
      final results = provider.filterProducts(selectedRams: {'16 GB'});
      expect(results.isNotEmpty, isTrue);
      expect(
          results.every(
              (p) => p.resolvedRam.contains('16') || p.ram.contains('16')),
          isTrue);
    });

    test('Filter by RAM: 32 GB', () {
      final results = provider.filterProducts(selectedRams: {'32 GB'});
      expect(results.isNotEmpty, isTrue);
      expect(
          results.every(
              (p) => p.resolvedRam.contains('32') || p.ram.contains('32')),
          isTrue);
    });

    test('Filter by Storage: 512 GB', () {
      final results = provider.filterProducts(selectedStorages: {'512 GB'});
      expect(results.isNotEmpty, isTrue);
      expect(
          results.every((p) =>
              p.resolvedStorage.contains('512') || p.storage.contains('512')),
          isTrue);
    });

    test('Filter by Processor: Apple M-Series', () {
      final results =
          provider.filterProducts(selectedProcessors: {'Apple M-Series'});
      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.brand == 'Apple'), isTrue);
    });

    test('Filter by Price Range: Rs. 80,000 to Rs. 150,000', () {
      final results =
          provider.filterProducts(minPrice: 80000, maxPrice: 150000);
      expect(results.isNotEmpty, isTrue);
      expect(
          results.every((p) => p.price >= 80000 && p.price <= 150000), isTrue);
    });

    test('Filter by Minimum Rating: 4.5 and above', () {
      final results = provider.filterProducts(minRating: 4.5);
      expect(results.isNotEmpty, isTrue);
      expect(results.every((p) => p.rating >= 4.5), isTrue);
    });
  });

  group('Phase 5 — Sorting Testing', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('Sort: Price Low -> High', () {
      final results = provider.filterProducts(sortBy: 'price_low_high');
      expect(results.length, greaterThan(1));
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price, lessThanOrEqualTo(results[i + 1].price));
      }
    });

    test('Sort: Price High -> Low', () {
      final results = provider.filterProducts(sortBy: 'price_high_low');
      expect(results.length, greaterThan(1));
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].price, greaterThanOrEqualTo(results[i + 1].price));
      }
    });

    test('Sort: Best Rated', () {
      final results = provider.filterProducts(sortBy: 'best_rated');
      expect(results.length, greaterThan(1));
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].rating, greaterThanOrEqualTo(results[i + 1].rating));
      }
    });

    test('Sort: Newest', () {
      final results = provider.filterProducts(sortBy: 'newest');
      expect(results.isNotEmpty, isTrue);

      expect(results.first.isLatest, isTrue);
    });

    test('Sort: Popular', () {
      final results = provider.filterProducts(sortBy: 'popular');
      expect(results.length, greaterThan(1));
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].popularity,
            greaterThanOrEqualTo(results[i + 1].popularity));
      }
    });
  });
}
