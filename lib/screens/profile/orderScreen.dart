import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../orders/order_details_screen.dart';
import '../products/product_listing_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';

  final List<String> _filterTabs = ['All', 'Active', 'Delivered', 'Cancelled'];

  Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream() {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return const Stream.empty();
      return FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("orders")
          .orderBy("createdAt", descending: true)
          .snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ProductProvider();

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: const Text(
              "📦 My Orders",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _ordersStream(),
            builder: (context, snap) {
              final Map<String, OrderModel> allOrdersMap = {};

              for (final o in provider.orders) {
                allOrdersMap[o.id] = o;
              }

              if (snap.hasData && snap.data!.docs.isNotEmpty) {
                for (final doc in snap.data!.docs) {
                  if (!allOrdersMap.containsKey(doc.id)) {
                    final data = Map<String, dynamic>.from(doc.data());
                    allOrdersMap[doc.id] =
                        OrderModel.fromMap(data, docId: doc.id);
                  }
                }
              }

              final allOrders = allOrdersMap.values.toList();

              if (allOrders.isEmpty) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                return _buildEmptyOrders(context);
              }

              final filteredOrders = allOrders.where((order) {
                switch (_selectedFilter) {
                  case 'Active':
                    return order.status != 'Delivered' &&
                        order.status != 'Cancelled';
                  case 'Delivered':
                    return order.status == 'Delivered';
                  case 'Cancelled':
                    return order.status == 'Cancelled';
                  case 'All':
                  default:
                    return true;
                }
              }).toList();

              return Column(
                children: [
                  Container(
                    height: 52,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.surface,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterTabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tab = _filterTabs[index];
                        final isSelected = _selectedFilter == tab;
                        return ChoiceChip(
                          label: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = tab);
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredOrders.isEmpty
                        ? Center(
                            child: Text(
                              'No $_selectedFilter orders found.',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, i) {
                              final order = filteredOrders[i];
                              return _buildOrderCard(context, order);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.local_mall_outlined,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't placed any laptop orders yet. Start exploring now!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProductListingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Explore Laptops"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_outlined,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Order #${order.id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: order.statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(order.statusIcon,
                          size: 13, color: order.statusColor),
                      const SizedBox(width: 4),
                      Text(
                        order.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: order.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Placed on ${order.orderDate.toString().split(' ')[0]} • ${order.city}",
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Divider(color: AppColors.border, height: 20),
            ...order.products.take(2).map((item) {
              final name = item['name'] ?? 'Laptop';
              final qty = item['quantity'] ?? item['qty'] ?? 1;
              final price = (item['price'] as num?)?.toDouble() ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.laptop,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "$qty × Rs. ${price.round()}",
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              );
            }),
            if (order.products.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  '+ ${order.products.length - 2} more item(s)',
                  style:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            const Divider(color: AppColors.border, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Amount",
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      "View Tracking",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: AppColors.accent),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
