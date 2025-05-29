import 'package:flutter/foundation.dart';
import 'package:odifarm/services/cart_service.dart';
import 'package:odifarm/models/cart.dart';
import 'package:odifarm/models/cart_item.dart';

class CartNotifier extends ChangeNotifier {
  Cart? _cart;
  int _cartCount = 0;

  Cart? get cart => _cart;
  int get cartCount => _cartCount;

  Future<void> fetchCart() async {
    _cart = await CartService().fetchCart();
    _cartCount =
        _cart?.cartItems?.fold<int>(0, (sum, item) => sum + item.quantity) ?? 0;
    notifyListeners();
  }

  Future<void> increaseQuantity(String itemId) async {
    // Update local state first for instant UI
    if (_cart != null && _cart!.cartItems != null) {
      final idx = _cart!.cartItems!.indexWhere((item) => item.id == itemId);
      if (idx != -1) {
        final item = _cart!.cartItems![idx];
        _cart!.cartItems![idx] = CartItem(
          id: item.id,
          cartId: item.cartId,
          quantity: item.quantity + 1,
          price: item.price,
          productId: item.productId,
        );
        _cartCount++;
        notifyListeners();
      }
    }
    await CartService().increaseQuantity(itemId);
    await fetchCart();
  }

  Future<void> decreaseQuantity(String itemId) async {
    // Update local state first for instant UI
    if (_cart != null && _cart!.cartItems != null) {
      final idx = _cart!.cartItems!.indexWhere((item) => item.id == itemId);
      if (idx != -1) {
        final item = _cart!.cartItems![idx];
        if (item.quantity > 1) {
          _cart!.cartItems![idx] = CartItem(
            id: item.id,
            cartId: item.cartId,
            quantity: item.quantity - 1,
            price: item.price,
            productId: item.productId,
          );
          _cartCount--;
        } else {
          _cart!.cartItems!.removeAt(idx);
          _cartCount--;
        }
        notifyListeners();
      }
    }
    await CartService().decreaseQuantity(itemId);
    await fetchCart();
  }

  Future<void> removeItem(String itemId) async {
    // Update local state first for instant UI
    if (_cart != null && _cart!.cartItems != null) {
      final idx = _cart!.cartItems!.indexWhere((item) => item.id == itemId);
      if (idx != -1) {
        final item = _cart!.cartItems![idx];
        _cartCount -= item.quantity;
        _cart!.cartItems!.removeAt(idx);
        notifyListeners();
      }
    }
    await CartService().removeItem(itemId);
    await fetchCart();
  }

  // Optionally, for direct add-to-cart support
  Future<void> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    required double price,
  }) async {
    await CartService().addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
      price: price,
    );
    await fetchCart();
  }
}
