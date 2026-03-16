class Product {
  final int id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Fiyat parse — "$999" veya 9.99 formatlarını destekler
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      final str = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(str) ?? 0.0;
    }

    // Görsel
    String imageUrl = json['image'] ?? json['thumbnail'] ?? '';

    // Kategori
    String category = '';
    if (json['category'] is String) {
      category = json['category'];
    } else if (json['category'] is Map) {
      category = json['category']['name'] ?? '';
    } else if (json['specs'] != null) {
      // WantAPI için specs'ten kategori çıkar
      category = 'TechMart';
    }

    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      price: parsePrice(json['price']),
      image: imageUrl,
      category: category,
      description: json['description'] ?? json['tagline'] ?? '',
    );
  }
}