import 'package:flutter/material.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await ApiService.getOrders();
      if (mounted) setState(() => _orders = orders);
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 16),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
            ).createShader(bounds),
            child: const Text(
              'My Orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }

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

  Widget _buildOrdersList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final id = order['id'] as int? ?? 0;
    final total = double.tryParse(order['total']?.toString() ?? '0') ?? 0;
    final status = order['status'] as String? ?? 'pending';
    final createdAt = order['created_at'] as String? ?? '';
    final items = (order['items'] as List<dynamic>?) ?? [];

    final statusColors = {
      'pending': AppColors.amberGlow,
      'confirmed': AppColors.brightAmber,
      'delivered': AppColors.sunbeamYellow,
      'cancelled': AppColors.red,
    };
    final statusColor = statusColors[status] ?? AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => OrderDetailScreen(orderId: id),
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
                    'Order #$id',
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
                      status[0].toUpperCase() + status.substring(1),
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
              ...items.take(3).map((item) {
                final product =
                    item['product'] as Map<String, dynamic>? ?? {};
                final name = product['name'] as String? ?? '';
                final qty = (item['quantity'] as int?) ?? 0;
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
                          name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                      Text(
                        'x$qty',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              if (items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${items.length - 3} more items',
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
                    _formatDate(createdAt),
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        AppColors.brightAmber,
                        AppColors.sunbeamYellow,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'R${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
