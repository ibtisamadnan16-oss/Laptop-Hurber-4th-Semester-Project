import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/write_review_dialog.dart';
import '../../widgets/app_cached_image.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = ProductProvider();

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final liveOrder = provider.getOrderById(order.id) ?? order;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              liveOrder.id.startsWith('LH')
                  ? 'Order #${liveOrder.id}'
                  : 'Order #LH${liveOrder.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusBanner(liveOrder),
              const SizedBox(height: 18),
              _buildTrackingTimeline(liveOrder),
              const SizedBox(height: 20),
              _buildProductsCard(context, provider, liveOrder),
              const SizedBox(height: 20),
              _buildShippingCard(liveOrder),
              const SizedBox(height: 20),
              _buildCostSummaryCard(liveOrder),
              const SizedBox(height: 24),
              if (liveOrder.status == 'Pending' ||
                  liveOrder.status == 'Confirmed') ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _confirmCancelOrder(context, provider, liveOrder),
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppColors.error, size: 18),
                    label: const Text(
                      'Cancel Order',
                      style: TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(OrderModel liveOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: liveOrder.statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: liveOrder.statusColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: liveOrder.statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(liveOrder.statusIcon,
                color: liveOrder.statusColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${liveOrder.status}',
                  style: TextStyle(
                    color: liveOrder.statusColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order #${liveOrder.id} • Placed on ${liveOrder.orderDate.toString().split(' ')[0]}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(OrderModel liveOrder) {
    if (liveOrder.status == 'Cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.error, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This order was cancelled and will not be processed.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Tracking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(OrderModel.trackingSteps.length, (index) {
              final isCompleted = liveOrder.isStepCompleted(index);
              final isCurrent = index == liveOrder.currentStepIndex;
              final isLast = index == OrderModel.trackingSteps.length - 1;
              final symbol = liveOrder.stepSymbol(index);
              final formattedStep = liveOrder.formattedStep(index);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (isCurrent
                                  ? AppColors.primary
                                  : AppColors.success)
                              : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? (isCurrent
                                    ? AppColors.primary
                                    : AppColors.success)
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.white
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: index < liveOrder.currentStepIndex
                              ? AppColors.success
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        formattedStep,
                        style: TextStyle(
                          color:
                              isCompleted ? Colors.white : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CURRENT',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(
      BuildContext context, ProductProvider provider, OrderModel liveOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products Ordered',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${liveOrder.products.length} items',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...liveOrder.products.map((item) {
            final name = item['name'] ?? 'Laptop';
            final qty = item['quantity'] ?? item['qty'] ?? 1;
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final imageUrl = item['imageUrl'] as String?;
            final prodId = item['productId']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFF1B1B26),
                          child: AppCachedImage(
                            imageUrl: imageUrl ?? '',
                            fit: BoxFit.cover,
                            memCacheWidth: 100,
                            memCacheHeight: 100,
                            errorWidget: const Icon(
                              Icons.laptop,
                              size: 24,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qty: $qty × Rs. ${price.round()}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${(qty * price).round()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final matchedProd = provider.getProductById(prodId) ??
                            provider.products.firstWhere(
                              (p) =>
                                  p.name.toLowerCase() ==
                                  name.toString().toLowerCase(),
                              orElse: () => ProductModel(
                                id: prodId.isNotEmpty
                                    ? prodId
                                    : 'prod_${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                brand: 'HP',
                                category: 'Laptops',
                                price: price,
                                imageUrl: imageUrl ?? '',
                                description: 'Purchased Laptop',
                              ),
                            );
                        WriteReviewDialog.show(context, matchedProd);
                      },
                      icon: const Icon(Icons.star_outline_rounded,
                          size: 16, color: Colors.amber),
                      label: const Text(
                        'Rate & Review Product',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShippingCard(OrderModel liveOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Shipping Address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            liveOrder.fullName,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            liveOrder.phone,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            liveOrder.shippingAddress,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummaryCard(OrderModel liveOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Method:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  liveOrder.paymentMethod,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: 20),
          _buildRow('Subtotal', 'Rs. ${liveOrder.subtotal.round()}'),
          const SizedBox(height: 6),
          _buildRow('Shipping', 'Rs. ${liveOrder.shipping.round()}'),
          const SizedBox(height: 6),
          _buildRow('Tax', 'Rs. ${liveOrder.tax.round()}'),
          const Divider(color: AppColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                liveOrder.formattedTotal,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _confirmCancelOrder(
      BuildContext context, ProductProvider provider, OrderModel liveOrder) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Order?',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to cancel order #${liveOrder.id}?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Order',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.cancelOrder(liveOrder.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order #${liveOrder.id} cancelled'),
                    backgroundColor: AppColors.surfaceLight,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Confirm Cancellation',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
