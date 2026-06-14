import 'package:flutter/material.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _product;
  bool _loading = true;
  int _quantity = 1;
  bool _addingToCart = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _fetchProduct();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchProduct() async {
    try {
      final data = await ApiService.getProduct(widget.productId);
      if (mounted) setState(() => _product = data);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load product'),
            backgroundColor: AppColors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToCart() async {
    setState(() => _addingToCart = true);
    try {
      await ApiService.addToCart(
        productId: widget.productId,
        quantity: _quantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_quantity added to cart'),
          backgroundColor: AppColors.amberGlow,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingToCart = false);
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
                child: CircularProgressIndicator(color: AppColors.amberGlow),
              )
            : FadeTransition(
                opacity: _fadeAnim,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildImageSection(),
                              _buildProductInfo(),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildBackButton(),
          const Spacer(),
          _buildIconButton(Icons.share_outlined, () {}),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
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
          onTap: onTap,
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final image = _product?['image'] as String?;
    final stock = _product?['stock'] as int? ?? 0;
    final category = _product?['category'] as Map<String, dynamic>?;

    return Column(
      children: [
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                AppColors.amberGlow.withValues(alpha: 0.15),
                AppColors.blazeOrange.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            children: [
              Center(
                child: image != null && image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          ApiService.imageUrl(image),
                          fit: BoxFit.contain,
                          height: 180,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.eco_rounded,
                            size: 80,
                            color: AppColors.amberGlow.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: AppColors.amberGlow.withValues(alpha: 0.5),
                      ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _buildBadge(
                  stock > 0 ? 'In Stock' : 'Out of Stock',
                  stock > 0 ? AppColors.sunbeamYellow : AppColors.red,
                ),
              ),
              if (category != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildBadge(
                    category['name'] as String? ?? '',
                    AppColors.brightAmber,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final name = _product?['name'] as String? ?? '';
    final price = double.tryParse(_product?['price']?.toString() ?? '0') ?? 0;
    final unit = _product?['unit'] as String? ?? 'piece';
    final description = _product?['description'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
            ).createShader(bounds),
            child: Text(
              'R${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'per $unit',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final stock = _product?['stock'] as int? ?? 0;
    final isOutOfStock = stock <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          _buildQuantitySelector(),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isOutOfStock
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.blazeOrange, AppColors.amberGlow],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isOutOfStock
                    ? Colors.white.withValues(alpha: 0.08)
                    : null,
                boxShadow: isOutOfStock
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.blazeOrange.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isOutOfStock || _addingToCart ? null : _addToCart,
                  child: Center(
                    child: _addingToCart
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOutOfStock
                                    ? Icons.block
                                    : Icons.shopping_cart_rounded,
                                color: isOutOfStock
                                    ? AppColors.textSecondary
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? AppColors.textSecondary
                                      : Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  Widget _buildQuantitySelector() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _quantityButton(
            Icons.remove_rounded,
            _quantity > 1 ? () => setState(() => _quantity--) : null,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _quantityButton(
            Icons.add_rounded,
            () => setState(() => _quantity++),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 52,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onTap != null
                ? AppColors.amberGlow
                : AppColors.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
