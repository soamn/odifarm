import 'cart_item.dart';

class Cart {
  final String? id;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem>? cartItems;
  

  Cart({
    this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'],
        userId: json['userId'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        cartItems: json['Cart_item'] != null
            ? List<CartItem>.from(json['Cart_item'].map((x) => CartItem.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'Cart_item': cartItems?.map((x) => x.toJson()).toList(),
      };
}
