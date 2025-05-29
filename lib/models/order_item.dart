class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'],
    orderId: json['orderId'],
    productId: json['productId'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'productId': productId,
    'quantity': quantity,
    'price': price,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
