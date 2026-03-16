import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';


class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final List<Product> cartItems;
  final Function(List<Product>) onCartUpdate;
  final List<OrderHistory> orderHistory;
  final Function(OrderHistory) onOrderPlaced;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cartItems,
    required this.onCartUpdate,
    required this.orderHistory,
    required this.onOrderPlaced,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late List<Product> _cartItems;
  bool _isWishlisted = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  void _addToCart() {
    setState(() {
      for (int i = 0; i < _quantity; i++) {
        _cartItems.add(widget.product);
      }
    });
    widget.onCartUpdate(_cartItems);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '$_quantity adet sepete eklendi!',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0077B6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: CustomScrollView(
        slivers: [
          // 🔷 Üst Görsel Alan (SliverAppBar)
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF0077B6),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isWishlisted ? Colors.pink : Colors.white,
                ),
                onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_rounded,
                        color: Colors.white, size: 26),
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
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.product.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFE0F4FF),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0077B6),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFE0F4FF),
                      child: const Icon(Icons.image_rounded,
                          color: Color(0xFF0077B6), size: 80),
                    ),
                  ),
                  // Alt gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFFF0F9FF),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔷 İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Ürün adı
                  Text(
                    widget.product.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Fiyat & Miktar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fiyat',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0077B6),
                            ),
                          ),
                        ],
                      ),

                      // Miktar seçici
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0077B6).withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _quantityButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0077B6),
                                ),
                              ),
                            ),
                            _quantityButton(
                              icon: Icons.add_rounded,
                              onTap: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Açıklama başlık
                  Text(
                    '📋 Ürün Açıklaması',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0077B6),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Açıklama
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0077B6).withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.product.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔷 Alt Sepet Butonu
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Toplam fiyat
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '\$${(widget.product.price * _quantity).toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0077B6),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // Sepete ekle butonu
            Expanded(
              child: GestureDetector(
                onTap: _addToCart,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0077B6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sepete Ekle',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}