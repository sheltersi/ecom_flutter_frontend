import 'package:flutter/material.dart';
import 'package:flutter_learn2/extensions/date_extension.dart';
import 'package:flutter_learn2/models/order.dart';
import 'package:flutter_learn2/models/order_item.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/widgets/app_back_button.dart';
import 'package:flutter_learn2/widgets/gradient_text.dart';

/// Detailed view of a single order: status card, item list with line totals, and an order summary section.
/// Receives an [orderId] and fetches the order from the API.
class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
  }

  /// Fetches a single order by [widget.orderId]. On error, shows a snackbar and pops back.
  Future<void> _fetchOrder() async {
    try {
      final data = await ApiService.getOrder(widget.orderId);
      if (mounted) setState(() => _order = Order.fromJson(data));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load order'),
            backgroundColor: AppColors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              Color(0xFF2D0A00),
              Color(0xFF3D1A00),
              Color(0xFF2D0A00),
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.amberGlow),
              )
            : SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 20),
                            _buildItemsList(),
                            const SizedBox(height: 24),
                            _buildSummaryCard(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Top bar with back button and "Order #ID" title.
  Widget _buildTopBar() {
    final id = _order?.id ?? widget.orderId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          Text(
            'Order #$id',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static const _statusColors = {
    'pending': AppColors.amberGlow,
    'confirmed': AppColors.brightAmber,
    'delivered': AppColors.sunbeamYellow,
    'cancelled': AppColors.red,
  };

  static const _statusIcons = {
    'pending': Icons.schedule_rounded,
    'confirmed': Icons.check_circle_outline_rounded,
    'delivered': Icons.local_shipping_rounded,
    'cancelled': Icons.cancel_outlined,
  };

  /// Status card showing a colored icon circle, the capitalized status text, and the formatted date.
  Widget _buildStatusCard() {
    final order = _order!;
    final statusColor = _statusColors[order.status] ?? AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.15),
              border: Border.all(
                  color: statusColor.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(
              _statusIcons[order.status] ?? Icons.receipt_long_rounded,
              color: statusColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.status[0].toUpperCase() + order.status.substring(1),
            style: TextStyle(
              color: statusColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.createdAt.toFormattedDateTime(),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// List of ordered items: image, name, unit price, quantity, and line total.
  Widget _buildItemsList() {
    final items = _order!.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${items.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(_buildOrderItem),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.amberGlow.withValues(alpha: 0.1),
            ),
            child: product.image != null && product.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ApiService.imageUrl(product.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.eco_rounded,
                        color: AppColors.amberGlow.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                : Icon(
                    Icons.eco_rounded,
                    color: AppColors.amberGlow.withValues(alpha: 0.4),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'R${item.price.toStringAsFixed(2)} / ${product.unit}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'x${item.quantity}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          GradientText(
            'R${item.lineTotal.toStringAsFixed(2)}',
            colors: const [AppColors.brightAmber, AppColors.sunbeamYellow],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Order summary section: subtotal (with item count), free delivery, divider, and gradient total.
  Widget _buildSummaryCard() {
    final order = _order!;
    final itemCount =
        order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal ($itemCount items)',
              'R${order.total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('Delivery', 'Free'),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GradientText(
                'R${order.total.toStringAsFixed(2)}',
                colors: const [AppColors.brightAmber, AppColors.sunbeamYellow],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A single row in the summary card (label left, value right).
  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
