import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

enum ApiSource { all, techmart, fashionhub, megastore }

extension ApiSourceExtension on ApiSource {
  String get displayName {
    switch (this) {
      case ApiSource.all:
        return 'All';
      case ApiSource.techmart:
        return 'TechMart';
      case ApiSource.fashionhub:
        return 'FashionHub';
      case ApiSource.megastore:
        return 'MegaStore';
    }
  }

  String get emoji {
    switch (this) {
      case ApiSource.all:
        return '🏬';
      case ApiSource.techmart:
        return '💻';
      case ApiSource.fashionhub:
        return '👗';
      case ApiSource.megastore:
        return '🏪';
    }
  }
}

class ApiService {
  static ApiSource currentSource = ApiSource.all;

  static Future<List<Product>> getProducts() async {
    switch (currentSource) {
      case ApiSource.all:
        return await _getAllProducts();
      case ApiSource.techmart:
        return await _getWantApiProducts();
      case ApiSource.fashionhub:
        return await _getFakeStoreProducts();
      case ApiSource.megastore:
        return await _getDummyJsonProducts();
    }
  }

  // Tüm mağazalardan çek
  static Future<List<Product>> _getAllProducts() async {
    final results = await Future.wait([
      _getWantApiProducts().catchError((_) => <Product>[]),
      _getFakeStoreProducts().catchError((_) => <Product>[]),
      _getDummyJsonProducts().catchError((_) => <Product>[]),
    ]);
    return results.expand((list) => list).toList();
  }

  // TechMart — WantAPI
  static Future<List<Product>> _getWantApiProducts() async {
    final response = await http.get(
      Uri.parse('https://wantapi.com/products.php'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((e) {
        e['category'] = 'TechMart';
        return Product.fromJson(e);
      }).toList();
    }
    throw Exception('TechMart yüklenemedi');
  }

  // FashionHub — FakeStore
  static Future<List<Product>> _getFakeStoreProducts() async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('FashionHub yüklenemedi');
  }

  // MegaStore — DummyJSON
  static Future<List<Product>> _getDummyJsonProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products?limit=30'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> products = data['products'];
      return products.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('MegaStore yüklenemedi');
  }

  static String getBannerUrl() {
    return 'https://wantapi.com/assets/banner.png';
  }
}