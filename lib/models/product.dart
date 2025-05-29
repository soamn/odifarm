import 'package:odifarm/models/category.dart';
import 'package:odifarm/models/product_item.dart';

class Product {
  String id;
  String name;
  String image;
  String description;
  bool isFeatured;
  List<ProductItem> productItems;
  Category category;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.isFeatured,
    required this.productItems,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isFeatured: json['IsFeatured'] as bool? ?? false,
      category: json['categoryId'] != null
          ? Category.fromJson(json['categoryId'] as Map<String, dynamic>)
          : Category(id: '', name: '',image: ''),

      productItems:
          (json['Product_item'] as List<dynamic>?)
              ?.map(
                (item) => ProductItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
