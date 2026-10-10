import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/screens/products/product_details_screen.dart';
import 'package:e_project/providers/product_provider.dart';

void main() {
  group('Phase 4 — Product Details Model & Specs Tests', () {
    final provider = ProductProvider();
    final hpLaptop = provider.products
        .firstWhere((p) => p.name.contains('HP EliteBook 840'));

    test('HP EliteBook 840 has multiple images in gallery', () {
      expect(hpLaptop.allImages.length, greaterThan(1));
    });

    test('All required specs are present and resolved', () {
      expect(hpLaptop.resolvedProcessor, contains('Core i5'));
      expect(hpLaptop.resolvedRam, contains('16GB'));
      expect(hpLaptop.resolvedStorage, contains('512GB'));
      expect(hpLaptop.resolvedGpu, contains('Iris Xe'));
      expect(hpLaptop.resolvedScreenSize, contains('14.0"'));
      expect(hpLaptop.resolvedOS, contains('Windows 11'));
      expect(hpLaptop.brand, 'HP');
      expect(hpLaptop.stock, 14);
      expect(hpLaptop.rating, 4.5);
      expect(hpLaptop.description.isNotEmpty, isTrue);
      expect(hpLaptop.formattedPrice, 'Rs. 95,000');
    });
  });

  group('Phase 4 — Product Details Widget Tests', () {
    testWidgets('ProductDetailsScreen displays all required info and buttons',
        (WidgetTester tester) async {
      final provider = ProductProvider();
      final hpLaptop = provider.products
          .firstWhere((p) => p.name.contains('HP EliteBook 840'));

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(product: hpLaptop),
        ),
      );

      expect(find.text('HP EliteBook 840 G8'), findsOneWidget);
      expect(find.text('Brand: HP'), findsOneWidget);

      expect(find.text('Rs. 95,000'), findsOneWidget);

      expect(find.textContaining('In Stock'), findsOneWidget);

      expect(find.text('Processor'), findsOneWidget);
      expect(find.text('RAM'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Graphics (GPU)'), findsOneWidget);
      expect(find.text('Screen Size'), findsOneWidget);
      expect(find.text('Operating System'), findsOneWidget);

      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.text('Add to Wishlist'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
    });
  });
}
