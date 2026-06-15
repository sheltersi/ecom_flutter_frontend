import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_learn2/models/category.dart';
import 'package:flutter_learn2/models/product.dart';
import 'package:flutter_learn2/models/user.dart';
import 'package:flutter_learn2/providers/auth_provider.dart';
import 'package:flutter_learn2/providers/cart_provider.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/login_screen.dart';
import 'package:flutter_learn2/screens/cart_screen.dart';
import 'package:flutter_learn2/screens/orders_screen.dart';
import 'package:flutter_learn2/screens/product_details_screen.dart';
import 'package:flutter_learn2/widgets/app_icon_button.dart';
import 'package:flutter_learn2/widgets/gradient_text.dart';

/// Main product browsing screen with category chips, search bar, and a 2-column product grid.
/// Also provides access to cart, orders, and logout via the top bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<Product> _products = [];
  int? _selectedCategoryId;
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    context.read<CartProvider>().fetchCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads categories and products in parallel. On failure, logs out and returns to login.
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.getProducts(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = (results[0] as List<dynamic>)
            .map((c) => Category.fromJson(c as Map<String, dynamic>))
            .toList();
        final productsData = results[1] as Map<String, dynamic>;
        final rawProducts = productsData['data'] as List<dynamic>? ?? [];
        _products = rawProducts
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        context.read<AuthProvider>().logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  /// Fetches products optionally filtered by category or search term.
  Future<void> _fetchProducts({int? categoryId, String? search}) async {
    final data = await ApiService.getProducts(
      categoryId: categoryId,
      search: search,
    );
    if (mounted) {
      setState(() {
        final rawProducts = data['data'] as List<dynamic>? ?? [];
        _products = rawProducts
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
      });
    }
  }

  /// Filters products by category when a chip is tapped.
  void _onCategoryTap(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _searchController.clear();
    _fetchProducts(categoryId: categoryId);
  }

  /// Searches products when the user submits a query in the search bar.
  void _onSearchSubmitted(String query) {
    setState(() => _selectedCategoryId = null);
    _fetchProducts(search: query);
  }

  /// Logs out the user and clears the navigation stack back to LoginScreen.
  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// Navigates to the product details screen with a fade transition.
  void _openProduct(Product product) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ProductDetailsScreen(productId: product.id),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Opens the cart screen with a fade transition.
  void _openCart() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CartScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Opens the orders history screen with a fade transition.
  void _openOrders() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const OrdersScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cartCount = context.watch<CartProvider>().count;

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
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.amberGlow),
                )
              : Column(
                  children: [
                    _buildTopBar(user, cartCount),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildProductGrid()),
                  ],
                ),
        ),
      ),
    );
  }

  /// Top bar with app logo, greeting, orders button, cart badge, and logout button.
  Widget _buildTopBar(User? user, int cartCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.amberGlow, AppColors.brightAmber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientText(
                'FreshCart',
                colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Hello, ${(user?.name ?? '').split(' ').first}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          AppIconButton(icon: Icons.receipt_long_outlined, onTap: _openOrders),
          const SizedBox(width: 8),
          _buildCartButton(cartCount),
          const SizedBox(width: 8),
          AppIconButton(icon: Icons.logout_rounded, onTap: _logout),
        ],
      ),
    );
  }

  /// Cart icon button with a badge showing the item count.
  Widget _buildCartButton(int count) {
    return GestureDetector(
      onTap: _openCart,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.blazeOrange, AppColors.amberGlow],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Search text field with a clear button that appears when text is entered.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onSubmitted: _onSearchSubmitted,
          decoration: InputDecoration(
            hintText: 'Search groceries...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.25),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchSubmitted('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  /// Horizontally scrolling row of category filter chips (first chip is "All").
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) return _buildChip('All', null);
          final cat = _categories[index - 1];
          return _buildChip(cat.name, cat.id);
        },
      ),
    );
  }

  /// Single category chip with animated gradient selection style.
  Widget _buildChip(String label, int? categoryId) {
    final isSelected =
        categoryId == null && _selectedCategoryId == null ||
        categoryId != null && categoryId == _selectedCategoryId;

    return GestureDetector(
      onTap: () => _onCategoryTap(categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.amberGlow, AppColors.brightAmber],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.amberGlow.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 2-column grid of product cards, or a "No products found" message when empty.
  Widget _buildProductGrid() {
    if (_products.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) => _buildProductCard(_products[index]),
    );
  }

  /// Individual product card with image, category label, name, and gradient-colored price.
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _openProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: AppColors.amberGlow.withValues(alpha: 0.08),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product.image != null && product.image!.isNotEmpty
                        ? Image.network(
                            ApiService.imageUrl(product.image!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.eco_rounded,
                              size: 40,
                              color: AppColors.amberGlow.withValues(alpha: 0.4),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.eco_rounded,
                              size: 40,
                              color: AppColors.amberGlow.withValues(alpha: 0.4),
                            ),
                          ),
                  ),
                  const Positioned(top: 8, right: 8, child: _AddButton()),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null)
                      Text(
                        product.category!.name,
                        style: TextStyle(
                          color: AppColors.brightAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientText(
                          'R${product.price.toStringAsFixed(2)}',
                          colors: const [
                            AppColors.brightAmber,
                            AppColors.sunbeamYellow,
                          ],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/${product.unit}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small amber circular add button overlayed on product card images.
class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.amberGlow,
        boxShadow: [
          BoxShadow(
            color: AppColors.amberGlow.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
    );
  }
}
