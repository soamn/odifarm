import 'package:odifarm/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final supabase = Supabase.instance.client;

  Future<List<Category>> fetchCategories() async {
    final response = await supabase.from('Category').select();
    return (response as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<List<Category>> fetchCategoriesByName(String query) async {
    final response = await supabase
        .from('Category')
        .select('*, Products(*)')
        .ilike('name', '%$query%');

    return (response as List).map((json) => Category.fromJson(json)).toList();
  }
}
