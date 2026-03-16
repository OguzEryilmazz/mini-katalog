import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'order_history_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final List<OrderHistory> orderHistory;
  final Function(OrderHistory) onOrderPlaced;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.orderHistory,
    required this.onOrderPlaced,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Product> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  double get _totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.price);

  void _removeItem(int index) {
    setState(() => _cartItems.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Item removed',
                style: GoogleFonts.poppins(fontSize: 13)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkout() {
    final order = OrderHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
      items: List.from(_cartItems),
      total: _totalPrice,
      date: DateTime.now(),
      store: ApiService.currentSource.displayName,
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Placed! 🎉',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0077B6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order of \$${_totalPrice.toStringAsFixed(2)}\nhas been confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  widget.onOrderPlaced(order);
                  setState(() => _cartItems.clear());
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Great! 🛍️',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          '🛒 My Cart',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _cartItems.clear()),
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.white70, size: 20),
              label: Text(
                'Clear',
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 13),
              ),
            ),
          // Geçmiş butonu
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderHistoryScreen(
                      orders: widget.orderHistory),
                ),
              );
            },
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 64, color: Color(0xFF0077B6)),
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0077B6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring products!',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0077B6).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '🛍️ Start Shopping',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final product = _cartItems[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeItem(index),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded,
                        color: Colors.white, size: 28),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0077B6)
                              .withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20)),
                          child: CachedNetworkImage(
                            imageUrl: product.image,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                                color: const Color(0xFFE0F4FF)),
                            errorWidget: (context, url, error) =>
                                Container(
                                  color: const Color(0xFFE0F4FF),
                                  child: const Icon(Icons.image_rounded,
                                      color: Color(0xFF0077B6)),
                                ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0077B6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Alt özet
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077B6).withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _summaryRow('Items', '${_cartItems.length}'),
                const SizedBox(height: 8),
                _summaryRow('Subtotal',
                    '\$${_totalPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _summaryRow('Shipping', 'Free 🎁'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0077B6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _checkout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0077B6),
                          Color(0xFF00B4D8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0077B6)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment_rounded,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Place Order',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.black54)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }
}