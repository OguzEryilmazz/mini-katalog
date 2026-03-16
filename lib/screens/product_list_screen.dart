import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

class ProductListScreen extends StatefulWidget {
  final List<Product> products;
  final List<Product> cartItems;
  final Function(List<Product>) onCartUpdate;
  final String title;
  final List<OrderHistory> orderHistory;
  final Function(OrderHistory) onOrderPlaced;

  const ProductListScreen({
    super.key,
    required this.products,
    required this.cartItems,
    required this.onCartUpdate,
    required this.title,
    required this.orderHistory,
    required this.onOrderPlaced,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late List<Product> _filtered;
  late List<Product> _cartItems;

  @override
  void initState() {
    super.initState();
    _filtered = widget.products;
    _cartItems = List.from(widget.cartItems);
  }

  void _onSearch(String value) {
    setState(() {
      _filtered = widget.products
          .where((p) =>
          p.title.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(Product product) {
    setState(() => _cartItems.add(product));
    widget.onCartUpdate(_cartItems);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.title} added to cart!',
                style: GoogleFonts.poppins(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0077B6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
                        cartItems: _cartItems,
                        orderHistory: widget.orderHistory,
                        onOrderPlaced: (order) {
                          widget.onOrderPlaced(order);
                          setState(() => _cartItems.clear());
                        },
                      ),
                    ),
                  );
                },
              ),
              if (_cartItems.isNotEmpty)
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
                      '${_cartItems.length}',
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
      body: Column(
        children: [
          // 🔍 Search Box
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0077B6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              onChanged: _onSearch,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: '🔍 Search products...',
                hintStyle:
                GoogleFonts.poppins(color: Colors.white60),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} products found',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0077B6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 64, color: Color(0xFF00B4D8)),
                  const SizedBox(height: 12),
                  Text(
                    'No products found',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0077B6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_filtered[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              cartItems: _cartItems,
              onCartUpdate: (updated) {
                setState(() => _cartItems = updated);
                widget.onCartUpdate(_cartItems);
              },
              orderHistory: widget.orderHistory,
              onOrderPlaced: (order) {
                widget.onOrderPlaced(order);
                setState(() => _cartItems.clear());
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFE0F4FF),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF0077B6), strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFE0F4FF),
                        child: const Icon(Icons.image_rounded,
                            color: Color(0xFF0077B6), size: 40),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B6).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.category,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
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
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0077B6)),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFF0077B6),
                              Color(0xFF00B4D8)
                            ]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}