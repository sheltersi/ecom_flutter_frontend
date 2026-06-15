import 'package:flutter/material.dart';
import 'package:flutter_learn2/extensions/date_extension.dart';
import 'package:flutter_learn2/models/order.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/order_detail_screen.dart';
import 'package:flutter_learn2/widgets/app_back_button.dart';
import 'package:flutter_learn2/widgets/gradient_text.dart';

/// Displays a scrollable list of past orders. Each card shows the order ID, status badge,
/// up to 3 product previews, date, and total. Tapping a card opens the order detail screen.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  /// Fetches all orders from the API. Shows a red snackbar on failure.
  Future<void> _fetchOrders() async {
    try {
      final data = await ApiService.getOrders();
      if (mounted) {
        setState(() {
          _orders = data
              .map((o) => Order.fromJson(o as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load orders'),
            backgroundColor: AppColors.red,
          ),
        );
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
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.amberGlow))
                    : _orders.isEmpty
                        ? _buildEmpty()
                        : _buildOrdersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top bar with back button and gradient "My Orders" title.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          const GradientText(
            'My Orders',
            colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state with icon and message shown when there are no orders.
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 44,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed orders will appear here',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Scrollable list of order cards with separators.
  Widget _buildOrdersList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
    );
  }

  static const _statusColors = {
    'pending': AppColors.amberGlow,
    'confirmed': AppColors.brightAmber,
    'delivered': AppColors.sunbeamYellow,
    'cancelled': AppColors.red,
  };

  /// Tappable order summary card: order ID, colored status badge, first 3 item previews, date, and gradient total.
  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColors[order.status] ?? AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => OrderDetailScreen(orderId: order.id),
              transitionsBuilder: (_, a, _, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      order.status[0].toUpperCase() + order.status.substring(1),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...order.items.take(3).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              AppColors.amberGlow.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Icon(Icons.eco_rounded,
                              size: 18,
                              color: AppColors.amberGlow
                                  .withValues(alpha: 0.4)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              if (order.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${order.items.length - 3} more items',
                    style: TextStyle(
                        color: AppColors.brightAmber, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.createdAt.toFormattedDate(),
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  GradientText(
                    'R${order.total.toStringAsFixed(2)}',
                    colors: const [
                      AppColors.brightAmber,
                      AppColors.sunbeamYellow,
                    ],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
