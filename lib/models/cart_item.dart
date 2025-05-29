import 'package:odifarm/models/cart_prduct.dart';

class CartItem {
  final String id;
  final String cartId;
  final int quantity;
  final double price;
  final CartProduct productId;

  CartItem({
    required this.id,
    required this.cartId,
    required this.quantity,
    required this.price,
    required this.productId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    cartId: json['cartId'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
    productId: CartProduct.fromJson(json['productId']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cartId': cartId,
    'quantity': quantity,
    'price': price,
    'productId': productId.toJson(),
  };
}
