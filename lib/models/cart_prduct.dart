class CartProduct {
  final String id;
  final String name;
  final String image;
  final String description;
  final bool isFeatured;

  CartProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.isFeatured,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      isFeatured: json['IsFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'IsFeatured': isFeatured,
    };
  }
}
