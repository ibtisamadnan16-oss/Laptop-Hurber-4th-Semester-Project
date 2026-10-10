import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/models/product_model.dart';
import 'package:e_project/models/review_model.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/screens/products/product_details_screen.dart';
import 'package:e_project/widgets/write_review_dialog.dart';

void main() {
  group('Phase 11 — Reviews & Ratings Unit Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('ReviewModel contains all required review properties', () {
      final now = DateTime.now();
      final review = ReviewModel(
        id: 'rev_123',
        productId: 'hp_elite_840',
        userId: 'usr_456',
        userName: 'Muhammad Ali',
        rating: 5.0,
        comment:
            'Very good laptop. Performance and battery timing is excellent.',
        createdAt: now,
        helpfulCount: 20,
      );

      expect(review.id, equals('rev_123'));
      expect(review.productId, equals('hp_elite_840'));
      expect(review.userName, equals('Muhammad Ali'));
      expect(review.rating, equals(5.0));
      expect(review.comment,
          contains('Performance and battery timing is excellent.'));
      expect(review.createdAt, equals(now));
      expect(review.helpfulCount, equals(20));

      final map = review.toMap();
      final parsed = ReviewModel.fromMap(map);
      expect(parsed.comment, equals(review.comment));
      expect(parsed.rating, equals(5.0));
    });

    test(
        'Provider submits review, updates review list and recalculates ratings',
        () async {
      final initialReviews = provider.getReviews('hp_elite_840');
      final initialCount = initialReviews.length;

      final hpLaptop = provider.getProductById('hp_elite_840');
      expect(hpLaptop, isNotNull);
      final oldCount = hpLaptop!.reviewsCount;

      final newReview = await provider.submitReview(
        productId: 'hp_elite_840',
        rating: 5.0,
        comment:
            'Very good laptop. Performance and battery timing is excellent.',
        userName: 'Test Buyer',
      );

      expect(newReview.rating, equals(5.0));
      expect(
          newReview.comment,
          equals(
              'Very good laptop. Performance and battery timing is excellent.'));

      final updatedReviews = provider.getReviews('hp_elite_840');
      expect(updatedReviews.length, equals(initialCount + 1));
      expect(
          updatedReviews.first.comment,
          equals(
              'Very good laptop. Performance and battery timing is excellent.'));

      final updatedLaptop = provider.getProductById('hp_elite_840');
      expect(updatedLaptop!.reviewsCount, equals(oldCount + 1));
    });
  });

  group('Phase 11 — Reviews & Ratings UI Tests', () {
    testWidgets(
        'Product page displays 4.6 ⭐ and 127 Reviews and customer reviews section',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testProduct = ProductModel(
        id: 'hp_elite_840_test',
        name: 'HP EliteBook 840 G8',
        brand: 'HP',
        category: 'Business',
        specSubtitle: 'Core i5 11th Gen',
        price: 95000,
        imageUrl: 'https://example.com/hp.png',
        description: 'High performance laptop for professionals.',
        rating: 4.6,
        reviewsCount: 127,
        stock: 14,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(product: testProduct),
        ),
      );
      await tester.pump();

      expect(find.text('4.6'), findsAtLeastNWidgets(1));
      expect(find.text('⭐'), findsAtLeastNWidgets(1));

      expect(find.text('127 Reviews'), findsOneWidget);

      expect(find.text('Ratings & Reviews'), findsOneWidget);

      expect(find.text('Write Review'), findsOneWidget);

      expect(find.textContaining('Very good laptop'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'WriteReviewDialog renders 5 stars, review text field and Submit Review button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testProduct = ProductModel(
        id: 'hp_elite_840_test',
        name: 'HP EliteBook 840 G8',
        brand: 'HP',
        category: 'Business',
        price: 95000,
        imageUrl: 'https://example.com/hp.png',
        description: 'Test laptop',
        rating: 4.6,
        reviewsCount: 127,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WriteReviewDialog(product: testProduct),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Write a Review'), findsOneWidget);

      expect(find.text('Rating:'), findsOneWidget);

      expect(find.text('Review:'), findsOneWidget);

      expect(find.text('Submit Review'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField),
        'Very good laptop. Performance and battery timing is excellent.',
      );
      await tester.pump();

      expect(
        find.text(
            'Very good laptop. Performance and battery timing is excellent.'),
        findsOneWidget,
      );
    });
  });
}
