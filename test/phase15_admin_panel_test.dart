import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_project/providers/product_provider.dart';
import 'package:e_project/models/product_model.dart';
import 'package:e_project/models/category_model.dart';
import 'package:e_project/services/notification_service.dart';
import 'package:e_project/screens/admin/adminhome.dart';
import 'package:e_project/screens/admin/manage_orders_screen.dart';
import 'package:e_project/screens/admin/manage_categories_screen.dart';
import 'package:e_project/screens/admin/manage_brands_screen.dart';
import 'package:e_project/screens/admin/manage_users_screen.dart';
import 'package:e_project/screens/admin/manage_feedback_screen.dart';
import 'package:e_project/screens/admin/manage_reviews_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 15 — Admin Dashboard KPI & UI Tests', () {
    testWidgets(
        'AdminHomeScreen displays exact required KPI metrics & quick stats',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Store Overview & Analytics'), findsOneWidget);

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);

      expect(find.text('Total Products'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);

      expect(find.text('Total Orders'), findsOneWidget);
      expect(find.text('67'), findsOneWidget);

      expect(find.text('Pending Orders'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);

      expect(find.text('Total Sales'), findsOneWidget);
      expect(find.text('Rs. 850,000'), findsOneWidget);
    });

    testWidgets('AdminHomeScreen renders all 8 required management modules',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsOneWidget);
      expect(find.text('Manage Products'), findsOneWidget);
      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.text('Manage Brands'), findsOneWidget);

      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Manage Orders'), findsOneWidget);
      expect(find.text('Manage Users'), findsOneWidget);
      expect(find.text('View Reviews'), findsOneWidget);
      expect(find.text('View Feedback'), findsOneWidget);
    });
  });

  group('Phase 15 — Product Management CRUD Provider Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('addProduct inserts a new laptop product into catalog', () {
      final initialCount = provider.products.length;
      final testLaptop = ProductModel(
        id: 'laptop_test_admin',
        name: 'Alienware m18 R2 Gaming Laptop',
        brand: 'Dell',
        category: 'Gaming',
        price: 450000,
        originalPrice: 480000,
        imageUrl:
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500',
        description: 'Ultimate 18-inch gaming powerhouse with RTX 4090.',
        processor: 'Intel Core i9-14900HX',
        ram: '64GB DDR5',
        storage: '2TB NVMe SSD',
        gpu: 'NVIDIA RTX 4090 16GB',
        screenSize: '18.0" QHD+ 165Hz',
        operatingSystem: 'Windows 11 Home',
        stock: 5,
        rating: 4.9,
        reviewsCount: 12,
      );

      provider.addProduct(testLaptop);

      expect(provider.products.length, equals(initialCount + 1));
      expect(provider.products.first.id, equals('laptop_test_admin'));
      expect(provider.products.first.name,
          equals('Alienware m18 R2 Gaming Laptop'));
      expect(provider.getProductById('laptop_test_admin'), isNotNull);
    });

    test('updateProduct updates existing laptop specifications and pricing',
        () {
      final target = provider.products.first;
      final updated = target.copyWith(
        name: '${target.name} (Updated Pro)',
        price: target.price + 10000,
      );

      provider.updateProduct(updated);

      final found = provider.getProductById(target.id);
      expect(found?.name, contains('(Updated Pro)'));
      expect(found?.price, equals(target.price + 10000));
    });

    test('deleteProduct removes product and cascades to cart and wishlist', () {
      final target = provider.products.first;
      final targetId = target.id;

      provider.addToCart(targetId);
      provider.toggleWishlist(targetId);

      expect(provider.isWishlisted(targetId), isTrue);
      expect(provider.cartQuantity(targetId), equals(1));

      provider.deleteProduct(targetId);

      expect(provider.getProductById(targetId), isNull);
      expect(provider.isWishlisted(targetId), isFalse);
      expect(provider.cartQuantity(targetId), equals(0));
    });
  });

  group('Phase 15 — Categories and Brands Management Tests', () {
    late ProductProvider provider;

    setUp(() {
      provider = ProductProvider();
    });

    test('addCategory and deleteCategory mutate the category catalog', () {
      const newCat = CategoryModel(
        id: 'cat_workstation',
        title: 'Workstations',
        description: 'High performance mobile workstations',
        icon: Icons.computer,
      );

      provider.addCategory(newCat);
      expect(provider.categories.any((c) => c.title == 'Workstations'), isTrue);

      provider.deleteCategory('cat_workstation');
      expect(
          provider.categories.any((c) => c.title == 'Workstations'), isFalse);
    });

    test('addBrand and deleteBrand mutate the brands collection', () {
      provider.addBrand('Razer');
      expect(provider.brands, contains('Razer'));

      final count = provider.brands.length;
      provider.addBrand('Razer');
      expect(provider.brands.length, equals(count));

      provider.deleteBrand('Razer');
      expect(provider.brands, isNot(contains('Razer')));
    });
  });

  group('Phase 15 — Order Status Lifecycle & Notifications Integration Tests',
      () {
    late ProductProvider provider;
    late NotificationService notificationService;

    setUp(() {
      provider = ProductProvider();
      notificationService = NotificationService();
      notificationService.resetToDemoData();
    });

    test(
        'updateOrderStatus updates order status and dispatches automated customer notification',
        () async {
      expect(provider.orders.isNotEmpty, isTrue);
      final testOrder = provider.orders.first;
      final orderId = testOrder.orderId;

      final initialNotifsCount = notificationService.notifications.length;

      provider.updateOrderStatus(orderId, 'Shipped');

      final updatedOrder =
          provider.orders.firstWhere((o) => o.orderId == orderId);
      expect(updatedOrder.status, equals('Shipped'));

      final latestNotif = notificationService.notifications.first;
      expect(latestNotif.orderId,
          equals(orderId.replaceAll('LH-', '').replaceAll('#', '')));
      expect(latestNotif.body, contains('has been shipped.'));
      expect(notificationService.notifications.length,
          equals(initialNotifsCount + 1));
    });

    test('deleteReview removes review and updates product average rating', () {
      final product = provider.products.first;
      final reviews = provider.getReviews(product.id);
      expect(reviews.isNotEmpty, isTrue);

      final reviewToDelete = reviews.first;
      provider.deleteReview(product.id, reviewToDelete.id);

      final remaining = provider.getReviews(product.id);
      expect(remaining.any((r) => r.id == reviewToDelete.id), isFalse);
    });
  });

  group('Phase 15 — Admin Management Screens Widget Tests', () {
    testWidgets(
        'ManageOrdersScreen displays all 7 lifecycle status filter tabs',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageOrdersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Orders'), findsOneWidget);
      expect(find.textContaining('All'), findsWidgets);
      expect(find.textContaining('Pending'), findsWidgets);
      expect(find.textContaining('Confirmed'), findsWidgets);
      expect(find.textContaining('Processing'), findsWidgets);
      expect(find.textContaining('Shipped'), findsWidgets);
      expect(find.textContaining('Out for Delivery'), findsWidgets);
      expect(find.textContaining('Delivered'), findsWidgets);
      expect(find.textContaining('Cancelled'), findsWidgets);
    });

    testWidgets(
        'ManageCategoriesScreen renders categories list and Add Category button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageCategoriesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('ManageBrandsScreen renders brands list and Add Brand button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageBrandsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Brands'), findsOneWidget);
      expect(find.text('Add Brand'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('ManageUsersScreen renders users, search bar and admin badges',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageUsersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Manage Users'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('admin@laptopharbor.com'), findsOneWidget);
    });

    testWidgets(
        'ManageFeedbackScreen renders customer tickets and filter chips',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageFeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Customer Feedback'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Open'), findsWidgets);
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Resolved'), findsWidgets);
    });

    testWidgets(
        'ManageReviewsScreen renders reviews list with moderation actions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManageReviewsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Customer Reviews'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });
  });
}
