import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_learn2/providers/cart_provider.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().fetchCart();
  }

  Future<void> _checkout() async {
    setState(() => _checkingOut = true);
    try {
      await context.read<CartProvider>().placeOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order placed successfully!'),
          backgroundColor: AppColors.amberGlow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout failed'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

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
              _buildTopBar(items.length),
              Expanded(
                child: cart.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.amberGlow))
                    : items.isEmpty
                        ? _buildEmptyCart()
                        : _buildCartList(items),
              ),
              if (!cart.loading && items.isNotEmpty)
                _buildBottomBar(cart.total),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int itemCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
            ).createShader(bounds),
            child: const Text(
              'My Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 14),
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

  Widget _buildEmptyCart() {
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
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.shopping_cart_outlined,
                size: 44, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some groceries to get started',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<dynamic> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCartItem(items[index]),
    );
  }

  Widget _buildCartItem(dynamic item) {
    final cartItemId = item['id'] as int;
    final product = item['product'] as Map<String, dynamic>? ?? {};
    final name = product['name'] as String? ?? '';
    final image = product['image'] as String?;
    final price =
        double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final unit = product['unit'] as String? ?? 'piece';
    final quantity = (item['quantity'] as int?) ?? 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.amberGlow.withValues(alpha: 0.1),
            ),
            child: image != null && image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      ApiService.imageUrl(image),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.eco_rounded,
                        color:
                            AppColors.amberGlow.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                : Icon(
                    Icons.eco_rounded,
                    color: AppColors.amberGlow.withValues(alpha: 0.4),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                        colors: [
                          AppColors.brightAmber,
                          AppColors.sunbeamYellow,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'R${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/$unit',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildQuantityControls(cartItemId, quantity),
          const SizedBox(width: 8),
          _buildRemoveButton(cartItemId),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(int cartItemId, int quantity) {
    final cart = context.read<CartProvider>();

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _smallButton(
            Icons.remove_rounded,
            quantity > 1
                ? () => cart.updateQuantity(cartItemId, quantity - 1)
                : null,
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _smallButton(
            Icons.add_rounded,
            () => cart.updateQuantity(cartItemId, quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _smallButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null
                ? AppColors.amberGlow
                : AppColors.textSecondary,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(int cartItemId) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () =>
              context.read<CartProvider>().removeItem(cartItemId),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.red,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.95),
        border: Border(
          top:
              BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15)),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
                ).createShader(bounds),
                child: Text(
                  'R${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _checkingOut
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.blazeOrange, AppColors.amberGlow],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: _checkingOut
                  ? Colors.white.withValues(alpha: 0.1)
                  : null,
              boxShadow: _checkingOut
                  ? []
                  : [
                      BoxShadow(
                        color:
                            AppColors.blazeOrange.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _checkingOut ? null : _checkout,
                child: Center(
                  child: _checkingOut
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
