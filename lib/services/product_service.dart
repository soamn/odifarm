import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts() async {
    final response = await supabase
        .from('Product')
        .select('*,categoryId(*),Product_item(*)');
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> fetchProductsBySearch(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await supabase
        .from('Product')
        .select('*, categoryId(*), Product_item(*)')
        .or('name.ilike.*$query*,description.ilike.*$query*');

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final response = await supabase
        .from('Product')
        .select('*, categoryId(*), Product_item(*)')
        .eq('categoryId', categoryId);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }
}
