import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  List<Product> cartItems = [];
  List<OrderHistory> orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0077B6),
        elevation: 0,
        title: Text(
          '🛍️ Mini Katalog',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // 🏪 Store Selector
          PopupMenuButton<ApiSource>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            offset: const Offset(0, 50),
            onSelected: (source) {
              ApiService.currentSource = source;
              setState(() => _isLoading = true);
              _loadProducts();
            },
            itemBuilder: (_) => ApiSource.values.map((source) {
              final isSelected = ApiService.currentSource == source;
              return PopupMenuItem(
                value: source,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0077B6).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(source.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(
                        source.displayName,
                        style: GoogleFonts.poppins(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF0077B6)
                              : Colors.black87,
                        ),
                      ),
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check_rounded,
                            color: Color(0xFF0077B6), size: 18),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(ApiService.currentSource.emoji,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    ApiService.currentSource.displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),

          // 🛒 Cart
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded,
                    color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cartItems: cartItems,
                        orderHistory: orderHistory,
                        onOrderPlaced: (order) {
                          setState(() {
                            orderHistory.add(order);
                            cartItems.clear();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF0077B6)),
      )
          : RefreshIndicator(
        onRefresh: _loadProducts,
        color: const Color(0xFF0077B6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 24),
              _buildSectionTitle('🗂️ Categories'),
              const SizedBox(height: 12),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildSectionTitle('✨ Featured Products'),
              const SizedBox(height: 12),
              _buildFeaturedProducts(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: const _AnimatedBanner(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0077B6),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();

    // Kategori ikon ve renk eşleştirmesi
    final categoryConfig = {
      'TechMart': {'icon': Icons.computer_rounded, 'color': const Color(0xFF0077B6)},
      'electronics': {'icon': Icons.electric_bolt_rounded, 'color': const Color(0xFF7B2FBE)},
      'jewelery': {'icon': Icons.diamond_rounded, 'color': const Color(0xFFE91E8C)},
      'men\'s clothing': {'icon': Icons.checkroom_rounded, 'color': const Color(0xFF0097A7)},
      'women\'s clothing': {'icon': Icons.dry_cleaning_rounded, 'color': const Color(0xFFE64A19)},
      'smartphones': {'icon': Icons.smartphone_rounded, 'color': const Color(0xFF1565C0)},
      'laptops': {'icon': Icons.laptop_rounded, 'color': const Color(0xFF2E7D32)},
      'fragrances': {'icon': Icons.water_drop_rounded, 'color': const Color(0xFFAD1457)},
      'skincare': {'icon': Icons.face_rounded, 'color': const Color(0xFF6A1B9A)},
      'groceries': {'icon': Icons.shopping_basket_rounded, 'color': const Color(0xFF558B2F)},
      'home-decoration': {'icon': Icons.home_rounded, 'color': const Color(0xFFEF6C00)},
    };

    IconData getIcon(String cat) {
      return (categoryConfig[cat]?['icon'] as IconData?) ?? Icons.category_rounded;
    }

    Color getColor(String cat) {
      return (categoryConfig[cat]?['color'] as Color?) ?? const Color(0xFF0077B6);
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final label = isAll ? 'All' : categories[index - 1];
          final color = isAll ? const Color(0xFF0077B6) : getColor(label);
          final icon = isAll ? Icons.apps_rounded : getIcon(label);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    products: isAll
                        ? _products
                        : _products
                        .where((p) => p.category == label)
                        .toList(),
                    cartItems: cartItems,
                    onCartUpdate: (updated) =>
                        setState(() => cartItems = updated),
                    title: isAll ? 'All Products' : label,
                    orderHistory: orderHistory,
                    onOrderPlaced: (order) {
                      setState(() {
                        orderHistory.add(order);
                        cartItems.clear();
                      });
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    final featured = _products.take(6).toList();
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final product = featured[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    products: _products,
                    cartItems: cartItems,
                    onCartUpdate: (updated) =>
                        setState(() => cartItems = updated),
                    title: 'All Products',
                    orderHistory: orderHistory,
                    onOrderPlaced: (order) {
                      setState(() {
                        orderHistory.add(order);
                        cartItems.clear();
                      });
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0077B6).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFE0F4FF),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0077B6),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFE0F4FF),
                        child: const Icon(Icons.image_rounded,
                            color: Color(0xFF0077B6), size: 40),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0077B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 🔷 Animated Banner
class _AnimatedBanner extends StatefulWidget {
  const _AnimatedBanner();

  @override
  State<_AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<_AnimatedBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: const Offset(0.08, 0),
    ).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: 'https://wantapi.com/assets/banner.png',
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)]),
              ),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)]),
              ),
              child: const Center(
                  child: Icon(Icons.store_rounded,
                      size: 60, color: Colors.white)),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF0077B6).withOpacity(0.75),
                Colors.transparent,
                const Color(0xFF00B4D8).withOpacity(0.3),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -20,
              right: _controller.value * 200 - 50,
              child: Container(
                width: 100,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ]),
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _controller.value * -4),
                  child: child,
                ),
                child: Text(
                  'Welcome! 👋',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _controller.value * -2),
                  child: child,
                ),
                child: Text(
                  'Discover the best products ✨',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 1))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -20,
          bottom: -20,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: 0.9 + _controller.value * 0.2,
              child: child,
            ),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: 0.85 + _controller.value * 0.15,
              child: child,
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}