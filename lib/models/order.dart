import 'order_item.dart';

class Order {
  final String id;
  final String userId;
  final String? razorpayOrderId;
  final double total;
  final String status;
  final String address;
  final String phone;
  final String email;
  final List<OrderItem>? orderItems;

  Order({
    required this.id,
    required this.userId,
    this.razorpayOrderId,
    required this.total,
    this.status = 'PENDING',
    required this.address,
    required this.phone,
    required this.email,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    userId: json['userId'],
    razorpayOrderId: json['razorpayOrderId'],
    total: (json['total'] as num).toDouble(),
    status: json['status'] ?? 'PENDING',
    address: json['Address'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    orderItems: json['Order_item'] != null
        ? List<OrderItem>.from(
            json['Order_item'].map((x) => OrderItem.fromJson(x)),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'razorpayOrderId': razorpayOrderId,
    'total': total,
    'status': status,
    'Address': address,
    'phone': phone,
    'email': email,
    'Order_item': orderItems?.map((x) => x.toJson()).toList(),
  };
}
