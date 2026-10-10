import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/categories/categories_screen.dart';
import 'screens/products/product_listing_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/profile/orderScreen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const LaptopHarborApp());

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));

    NotificationService().initializeFCM().catchError((e) {
      debugPrint('Notification init notice: $e');
    });

    _seedProductsIfEmpty().catchError((e) {
      debugPrint('Product seeding notice: $e');
    });
  } catch (e, st) {
    debugPrint('Firebase initialization or product seeding notice: $e\n$st');
  }
}

Future<void> _seedProductsIfEmpty() async {
  if (!kDebugMode) return;

  try {
    final col = FirebaseFirestore.instance.collection('products');
    final snapshot =
        await col.limit(1).get().timeout(const Duration(seconds: 3));
    if (snapshot.docs.isNotEmpty) return;

    final samples = <Map<String, dynamic>>[
      {
        'name': 'MSI GF63 Thin',
        'brand': 'MSI',
        'price': 899.99,
        'description':
            '15.6" FHD, Intel i5-11400H, 8GB RAM, 512GB SSD, RTX 3050',
        'imageUrl':
            'https://pisces.bbystatic.com/image2/BestBuy_US/images/products/6529/6529925_sd.jpg',
        'type': 'Gaming Laptop',
        'popularity': 88,
      },
      {
        'name': 'MacBook Air M2',
        'brand': 'Apple',
        'price': 1199.00,
        'description': '13.6" Liquid Retina, M2 chip, 8GB RAM, 256GB SSD',
        'imageUrl':
            'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-select-20220606?wid=452&hei=420&fmt=jpeg&qlt=95&.v=1653084303665',
        'type': 'Ultrabook',
        'popularity': 95,
      },
      {
        'name': 'Dell XPS 15',
        'brand': 'Dell',
        'price': 1599.99,
        'description':
            '15.6" 4K OLED, Intel i7-12700H, 16GB RAM, 1TB SSD, RTX 3050 Ti',
        'imageUrl':
            'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/notebooks/xps-notebooks/xps-15-9520/media-gallery/black/laptop-xps-15-9520-t-black-gallery-4.psd?fmt=png-alpha&pscan=auto&scl=1&hei=402&wid=402&qlt=100,1&resMode=sharp2&size=402,402',
        'type': 'Premium Laptop',
        'popularity': 92,
      },
      {
        'name': 'Lenovo ThinkPad X1 Carbon',
        'brand': 'Lenovo',
        'price': 1399.99,
        'description': '14" QHD, Intel i7-1165G7, 16GB RAM, 512GB SSD',
        'imageUrl':
            'https://p1-ofp.static.pub/medias/bWFzdGVyfHJvb3R8MTY1NDcyfGltYWdlL3BuZ3xoOTIvaGZkLzk3NzY3NDc0MzM5ODIucG5nfDZiZjFhZmJlOGZiNGU3ZWU2YzM0ODRhZjQ1ZWM3ZDQxZGZhYzk0ZTBlNjJjOWNmZWE5YjNjZDQ0ZWRkNDVlMmU/lenovo-laptop-thinkpad-x1-carbon-gen-9-14-subseries-hero.png',
        'type': 'Business Laptop',
        'popularity': 89,
      },
      {
        'name': 'ASUS ROG Strix G15',
        'brand': 'ASUS',
        'price': 1299.99,
        'description':
            '15.6" FHD 144Hz, AMD Ryzen 9, 16GB RAM, 1TB SSD, RTX 3060',
        'imageUrl':
            'https://dlcdnwebimgs.asus.com/gain/F7AB0626-7422-4505-82E2-5F7F5AC169CA/w717/h525',
        'type': 'Gaming Laptop',
        'popularity': 94,
      },
      {
        'name': 'HP Spectre x360',
        'brand': 'HP',
        'price': 1399.99,
        'description':
            '14" 4K OLED, Intel i7-1165G7, 16GB RAM, 1TB SSD, 2-in-1 Design',
        'imageUrl':
            'https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c08194087.png',
        'type': 'Premium 2-in-1',
        'popularity': 91,
      },
    ];

    for (final product in samples) {
      await col.add(product);
    }

    debugPrint('Added ${samples.length} sample products to Firestore.');
  } catch (e) {
    debugPrint('Product seeding catch: $e');
  }
}

class LaptopHarborApp extends StatelessWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LaptopHarbor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/products': (context) => const ProductListingScreen(),
        '/cart': (context) => const CartScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/orders': (context) => const OrdersScreen(),
      },
    );
  }
}

typedef WatchHubApp = LaptopHarborApp;
