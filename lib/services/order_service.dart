import 'package:odifarm/models/order.dart';
import 'package:odifarm/models/order_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  Future<List<Order>> fetchOrders() async {
    final response = await supabase
        .from('Order')
        .select('*,Order_item(*),ShippingAddressId(*)');
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  Future<void> createOrder({
    required String userId,
    required double total,
    String status = "PENDING",
    required String address,
    required String phone,
    required String email,
    required List<OrderItem> orderItems,
  }) async {
    final String orderId = const Uuid().v4();
    final orderResponse = await supabase
        .from('Order')
        .insert({
          'id': orderId,
          'userId': userId,
          'total': total,
          'status': status,
          'Address': address,
          'phone': phone,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        })
        .select('id')
        .maybeSingle();

    if (orderResponse == null || orderResponse['id'] == null) {
      throw Exception('Failed to create order');
    }

    // Prepare list of order items
    final List<Map<String, dynamic>> items = orderItems.map((item) {
      return {
        'id': const Uuid().v4(), // Generate unique id for each order item
        'orderId': orderId,
        'productId': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }).toList();

    // Insert order items
    final itemsResponse = await supabase.from('Order_item').insert(items);

    if (itemsResponse.error != null) {
      throw Exception(
        'Failed to create order items: ${itemsResponse.error!.message}',
      );
    }
  }

  Future<String> createOrderAndReturnId({
    required String userId,
    required double total,
    String status = "PENDING",
    required String address,
    required String phone,
    required String email,
    required List<OrderItem> orderItems,
  }) async {
    final String orderId = const Uuid().v4();
    final orderResponse = await supabase
        .from('Order')
        .insert({
          'id': orderId,
          'userId': userId,
          'total': total,
          'status': status,
          'Address': address,
          'phone': phone,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        })
        .select('id')
        .maybeSingle();
    if (orderResponse == null || orderResponse['id'] == null) {
      throw Exception('Failed to create order');
    }
    final List<Map<String, dynamic>> items = orderItems.map((item) {
      return {
        'id': const Uuid().v4(), // Generate unique id for each order item
        'orderId': orderId,
        'productId': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }).toList();
    await supabase.from('Order_item').insert(items);
    return orderId;
  }

  Future<void> updateOrderPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    // Find the order by razorpayOrderId
    final order = await supabase
        .from('Order')
        .select('id')
        .eq('razorpayOrderId', razorpayOrderId)
        .maybeSingle();
    if (order == null || order['id'] == null) {
      throw Exception('Order not found');
    }
    final String orderId = order['id'];
    // Only update order status, do not insert payment here
    await supabase
        .from('Order')
        .update({'status': 'SUCCESSFUL'})
        .eq('id', orderId);
  }
}
