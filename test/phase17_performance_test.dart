import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/services/product_service.dart';
import 'package:e_project/widgets/app_cached_image.dart';
import 'package:e_project/screens/home/home_screen.dart';
import 'package:e_project/screens/products/product_listing_screen.dart';

void main() {
  group('Phase 17 — Pagination Logic Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      provider.resetPagination();
    });

    test('Initial pagination state conforms to default pageSize of 6', () {
      expect(provider.currentPage, equals(1));
      expect(provider.pageSize, equals(6));
      expect(provider.paginatedProducts.length, equals(6));
      expect(provider.hasMoreProducts, isTrue);
    });

    test('loadMoreProducts increments currentPage and loads next product slice',
        () async {
      expect(provider.currentPage, equals(1));
      final initialCount = provider.paginatedProducts.length;
      expect(initialCount, equals(6));

      await provider.loadMoreProducts(latency: Duration.zero);

      expect(provider.currentPage, equals(2));
      expect(provider.paginatedProducts.length, greaterThan(initialCount));
    });

    test('resetPagination restores pagination to page 1', () async {
      await provider.loadMoreProducts(latency: Duration.zero);
      expect(provider.currentPage, equals(2));

      provider.resetPagination();
      expect(provider.currentPage, equals(1));
      expect(provider.paginatedProducts.length, equals(6));
    });

    test('paginateList correctly slices arbitrary filtered product lists', () {
      final all = provider.products;
      final slice1 = provider.paginateList(all, page: 1, limit: 4);
      expect(slice1.length, equals(4));

      final slice2 = provider.paginateList(all, page: 2, limit: 4);
      expect(slice2.length, equals(8));

      expect(provider.hasMoreInList(all, page: 1, limit: 4), isTrue);
    });
  });

  group('Phase 17 — In-Memory Caching & Sub-Second Response (<1-2s Target)',
      () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
      ProductService.clearCache();
    });

    test(
        'In-memory cache prevents redundant fetches and fulfills < 1–2s response target',
        () async {
      final stopwatch = Stopwatch()..start();

      final products1 = await provider.fetchProducts();
      expect(products1.isNotEmpty, isTrue);
      expect(provider.isCacheValid, isTrue);

      final cacheFetchWatch = Stopwatch()..start();
      final products2 = await provider.fetchProducts(forceRefresh: false);
      cacheFetchWatch.stop();

      stopwatch.stop();

      expect(products2.length, equals(products1.length));

      expect(cacheFetchWatch.elapsedMilliseconds, lessThan(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test(
        'ProductService caches query results to avoid unnecessary Firestore reads',
        () async {
      final service = ProductService();

      final firstCall = await service.fetchOptimizedLaptops(
        category: 'Gaming',
        limit: 4,
      );
      expect(firstCall.isNotEmpty, isTrue);

      final secondCallWatch = Stopwatch()..start();
      final secondCall = await service.fetchOptimizedLaptops(
        category: 'Gaming',
        limit: 4,
        forceRefresh: false,
      );
      secondCallWatch.stop();

      expect(secondCall.length, equals(firstCall.length));
      expect(secondCallWatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Phase 17 — Loading Indicators & CircularProgressIndicator UI Tests',
      () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    testWidgets('CircularProgressIndicator renders on HomeScreen when loading',
        (tester) async {
      provider.setLoading(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading laptops...'), findsOneWidget);

      provider.setLoading(false);
      await tester.pump();
      expect(find.text('Loading laptops...'), findsNothing);
    });

    testWidgets(
        'CircularProgressIndicator renders on ProductListingScreen when loading',
        (tester) async {
      provider.setLoading(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductListingScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading laptops...'), findsOneWidget);

      provider.setLoading(false);
      await tester.pump();
      expect(find.text('Loading laptops...'), findsNothing);
    });

    testWidgets(
        'AppCachedImage renders memory-bounded image widget with fallback icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCachedImage(
              imageUrl: '',
              memCacheWidth: 400,
              memCacheHeight: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.laptop_chromebook), findsOneWidget);
    });

    testWidgets(
        'ProductListingScreen renders Load More button or pagination indicator for large catalogs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductListingScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Load More Laptops'), findsOneWidget);

      await tester.tap(find.text('Load More Laptops'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Load More Laptops'), findsNothing);
    });
  });
}
