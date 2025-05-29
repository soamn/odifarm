import 'package:flutter/material.dart';
import 'package:odifarm/notifiers/cart_notifier.dart';
import 'package:provider/provider.dart';
import 'package:odifarm/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<CartNotifier>(context, listen: false).fetchCart();
  }

  void _updateQuantity(BuildContext context, String itemId, int delta) async {
    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
    if (delta == 1) {
      await cartNotifier.increaseQuantity(itemId);
    } else if (delta == -1) {
      await cartNotifier.decreaseQuantity(itemId);
    }
  }

  void _removeItem(BuildContext context, String itemId) async {
    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
    await cartNotifier.removeItem(itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cartNotifier, _) {
        final cart = cartNotifier.cart;
        final cartItems = cart?.cartItems ?? [];
        double total = cartItems.fold(
          0,
          (sum, item) => sum + (item.quantity * item.price),
        );
        if (cart == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Cart"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                            leading: item.productId.image.isNotEmpty
                                ? Image.network(
                                    item.productId.image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(item.productId.name),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: item.quantity > 1
                                      ? () => _updateQuantity(
                                          context,
                                          item.id,
                                          -1,
                                        )
                                      : null,
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _updateQuantity(context, item.id, 1),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "₹ ${(item.price * item.quantity).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      _removeItem(context, item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₹ ${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckoutPage(),
                                        ),
                                      );
                                    },
                              child: const Text("Checkout"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
