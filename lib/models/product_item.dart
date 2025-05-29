class ProductItem {
  String id;
  String productId;
  String sku;
  int quantity;
  double price;

  ProductItem({
    required this.id,
    required this.productId,
    required this.sku,
    required this.price,
    required this.quantity,
  });
  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      productId: json['productId'] as String,
    );
  }
}
