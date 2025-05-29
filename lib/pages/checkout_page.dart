import 'package:flutter/material.dart';
import 'package:odifarm/notifiers/cart_notifier.dart';
import 'package:odifarm/services/order_service.dart';
import 'package:odifarm/services/user_service.dart';
import 'package:odifarm/services/payment_service.dart';
import 'package:odifarm/models/order_item.dart';
import 'package:odifarm/models/user.dart';
import 'package:odifarm/models/payment.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  UserModel? user;
  bool isLoading = true;
  bool paymentSuccess = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final email = UserService().supabase.auth.currentUser?.email;
    if (email != null) {
      final fetchedUser = await UserService().fetchUserData(email);
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
    }
  }

  void _openRazorpay(double total) async {
    final cart = Provider.of<CartNotifier>(context, listen: false).cart;
    if (cart == null || user == null) return;
    final orderItems =
        cart.cartItems
            ?.map(
              (item) => OrderItem(
                id: '',
                orderId: '',
                productId: item.productId.id,
                quantity: item.quantity,
                price: item.price,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            )
            .toList() ??
        [];
    String? orderId;
    try {
      orderId = await OrderService().createOrderAndReturnId(
        address: user!.addressline1 ?? '',
        phone: user!.phone ?? '',
        email: user!.email,
        userId: user!.id,
        total: total,
        orderItems: orderItems,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create order: $e')));
      return;
    }
    var options = {
      'key': 'rzp_test_CEWQxgrJYYCHsP',
      'amount': (total * 100).toInt(),
      'name': 'Odi Farm',
      'description': 'Order Payment',
      'order_id': orderId,
      'prefill': {'contact': user?.phone ?? '', 'email': user?.email ?? ''},
      'currency': 'INR',
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Update order status and store payment info
      await OrderService().updateOrderPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      // Create payment entry in DB
      final payment = Payment(
        id: '', // Let backend generate or ignore
        orderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
        amount: 0, // You can pass the actual amount if available
        provider: 'razorpay',
        status: 'SUCCESSFUL',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await PaymentService().createPayment(payment: payment);
      setState(() {
        paymentSuccess = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order/payment: $e')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Razorpay error: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet selected: ${response.walletName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartNotifier>(context).cart;
    final total =
        cart?.cartItems?.fold<double>(
          0.0,
          (sum, item) => sum + (item.price * item.quantity),
        ) ??
        0.0;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (paymentSuccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Payment successful! Order placed.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (user != null) ...[
              Text(user!.firstName ?? ''),
              Text(user!.lastName ?? ''),
              Text(user!.addressline1 ?? ''),
              Text(user!.addressline2 ?? ''),
              Text('${user!.city ?? ''}, ${user!.state ?? ''}'),
              Text(user!.zipCode ?? ''),
              const SizedBox(height: 20),
            ],
            const Text(
              'Order Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...?cart?.cartItems?.map(
              (item) => ListTile(
                title: Text(item.productId.name),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('₹${total.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: total > 0 ? () => _openRazorpay(total) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Pay with Razorpay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
