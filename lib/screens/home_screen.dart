import 'package:flutter/material.dart';
import 'package:flutter_learn2/services/api_service.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/screens/login_screen.dart';
import 'package:flutter_learn2/screens/cart_screen.dart';
import 'package:flutter_learn2/screens/orders_screen.dart';
import 'package:flutter_learn2/screens/product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  int? _selectedCategoryId;
  bool _loading = true;
  final _searchController = TextEditingController();

  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchCartCount();
  }

  @override
  void dispose() {
    // frees memory
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getUser(),
        ApiService.getCategories(),
        ApiService.getProducts(),
      ]);

      if (!mounted) return;

      setState(() {
        _user = results[0] as Map<String, dynamic>;
        _categories = results[1] as List<dynamic>;
        final productsData = results[2] as Map<String, dynamic>;
        _products = productsData['data'] as List<dynamic>? ?? [];
      });
    } catch (_) {
      if (mounted) _logout();
      return;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchProducts({int? categoryId, String? search}) async {
    final data = await ApiService.getProducts(
      categoryId: categoryId,
      search: search,
    );
    if (mounted) {
      setState(() {
        _products = data['data'] as List<dynamic>? ?? [];
      });
    }
  }

  void _onCategoryTap(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _searchController.clear();
    _fetchProducts(categoryId: categoryId);
  }

  void _onSearchSubmitted(String query) {
    setState(() => _selectedCategoryId = null);
    _fetchProducts(search: query);
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openProduct(Map<String, dynamic> product) async {
    final id = product['id'] as int?;
    if (id == null) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => ProductDetailsScreen(productId: id),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _fetchCartCount();
  }

  void _openCart() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CartScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _fetchCartCount();
  }

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

  Future<void> _fetchCartCount() async {
    try {
      final items = await ApiService.getCart();
      if (mounted) setState(() => _cartCount = items.length);
    } catch (_) {}
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
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.amberGlow),
                )
              : Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _buildProductGrid(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
            child: const Icon(Icons.shopping_bag_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
                ).createShader(bounds),
                child: const Text(
                  'FreshCart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Text(
                'Hello, ${(_user?['name'] as String? ?? '').split(' ').first}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildIconButton(Icons.receipt_long_outlined, _openOrders),
          const SizedBox(width: 8),
          _buildCartButton(),
          const SizedBox(width: 8),
          _buildIconButton(Icons.logout_rounded, _logout),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
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
              child: Icon(Icons.shopping_cart_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
            if (_cartCount > 0)
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
                      _cartCount > 9 ? '9+' : '$_cartCount',
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
      ),
    );
  }

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
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchSubmitted('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (v) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip('All', null);
          }
          final cat = _categories[index - 1] as Map<String, dynamic>;
          return _buildChip(cat['name'] as String? ?? '', cat['id'] as int?);
        },
      ),
    );
  }

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
      itemBuilder: (context, index) {
        final product = _products[index] as Map<String, dynamic>;
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final name = product['name'] as String? ?? '';
    final price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final unit = product['unit'] as String? ?? 'piece';
    final category = product['category'] as Map<String, dynamic>?;

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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      color: AppColors.amberGlow.withValues(alpha: 0.08),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: product['image'] != null &&
                            (product['image'] as String).isNotEmpty
                        ? Image.network(
                            ApiService.imageUrl(product['image'] as String),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.eco_rounded,
                              size: 40,
                              color:
                                  AppColors.amberGlow.withValues(alpha: 0.4),
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
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
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category != null)
                      Text(
                        category['name'] as String? ?? '',
                        style: TextStyle(
                          color: AppColors.brightAmber,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      name,
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
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
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
                        Text(
                          '/$unit',
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
