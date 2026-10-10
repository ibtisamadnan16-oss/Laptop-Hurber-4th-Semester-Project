import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';

void main() {
  group('Phase 3 - Home Page & Product Listings Tests', () {
    final provider = ProductProvider();

    test('Required Categories exist in catalog', () {
      final categoryTitles = provider.categories.map((c) => c.title).toList();
      expect(categoryTitles, contains('Gaming'));
      expect(categoryTitles, contains('Business'));
      expect(categoryTitles, contains('Student'));
      expect(categoryTitles, contains('Ultrabook'));
      expect(categoryTitles, contains('Workstation'));
      expect(categoryTitles, contains('Accessories'));
    });

    test('Required Brands exist in catalog', () {
      final brands = provider.brands;
      expect(brands, contains('HP'));
      expect(brands, contains('Dell'));
      expect(brands, contains('Lenovo'));
      expect(brands, contains('Apple'));
      expect(brands, contains('Asus'));
      expect(brands, contains('Acer'));
      expect(brands, contains('MSI'));
    });

    test('HP EliteBook 840 wireframe card details match specifications', () {
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));
      expect(hpLaptop.name, 'HP EliteBook 840 G8');
      expect(hpLaptop.brand, 'HP');
      expect(hpLaptop.specSubtitle, 'Core i5 11th Gen');
      expect(hpLaptop.formattedPrice, 'Rs. 95,000');
      expect(hpLaptop.rating, 4.5);
    });

    test('Home Page Collections (Featured, Latest, Popular) return valid items',
        () {
      final featured = provider.featuredLaptops;
      final latest = provider.latestLaptops;
      final popular = provider.popularProducts;

      expect(featured.isNotEmpty, isTrue);
      expect(latest.isNotEmpty, isTrue);
      expect(popular.isNotEmpty, isTrue);

      for (final item in featured) {
        expect(item.formattedPrice.startsWith('Rs. '), isTrue);
      }
    });

    test('Brand and Category filter testing', () {
      final hpGaming =
          provider.filterProducts(category: 'Gaming', brand: 'Asus');
      expect(
          hpGaming.every((p) =>
              p.brand.toLowerCase() == 'asus' &&
              p.category.toLowerCase().contains('gaming')),
          isTrue);
    });
  });
}
