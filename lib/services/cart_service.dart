import 'package:odifarm/models/cart.dart';
import 'package:odifarm/services/auth_service.dart';
import 'package:odifarm/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CartService {
  final supabase = Supabase.instance.client;

  Future<Cart?> fetchCart() async {
    final email = await AuthService().fetchUserByemail();
    final user = await UserService().fetchUserData(email);
    if (user == null) {
      return null; // No user found
    }
    final response = await supabase
        .from('Cart')
        .select(
          '*, Cart_item(*,productId(*))',
        ) // also fetching nested Cart_item list
        .eq('userId', user.id)
        .maybeSingle(); // expect zero or one cart for this user

    if (response == null) {
      return null; // no cart found
    }
    return Cart.fromJson(response);
  }

  Future<int> fetchCartLength() async {
    final email = await AuthService().fetchUserByemail();
    final user = await UserService().fetchUserData(email);
    if (user == null) {
      return 0; // No user found
    }
    final response = await supabase
        .from('Cart')
        .select('Cart_item(quantity)')
        .eq('userId', user.id)
        .maybeSingle();

    if (response == null) {
      return 0; // No cart found
    }

    final List<dynamic>? items = response['Cart_item'];
    if (items == null || items.isEmpty) {
      return 0; // Cart is empty
    }

    // Sum the quantity of all cart items
    int totalQuantity = 0;
    for (var item in items) {
      totalQuantity += (item['quantity'] as int);
    }

    return totalQuantity;
  }

  Future<void> increaseQuantity(String cartItemId) async {
    final response = await supabase
        .from('Cart_item')
        .select('quantity')
        .eq('id', cartItemId)
        .maybeSingle();

    if (response == null) throw Exception("Cart item not found");

    final currentQty = response['quantity'] as int;

    final updateResponse = await supabase
        .from('Cart_item')
        .update({'quantity': currentQty + 1})
        .eq('id', cartItemId);

    if (updateResponse.error != null) {
      throw Exception("Failed to increase quantity");
    }
  }

  Future<void> decreaseQuantity(String cartItemId) async {
    final response = await supabase
        .from('Cart_item')
        .select('quantity')
        .eq('id', cartItemId)
        .maybeSingle();

    if (response == null) throw Exception("Cart item not found");

    final currentQty = response['quantity'] as int;

    if (currentQty > 1) {
      final updateResponse = await supabase
          .from('Cart_item')
          .update({'quantity': currentQty - 1})
          .eq('id', cartItemId);

      if (updateResponse.error != null) {
        throw Exception("Failed to decrease quantity");
      }
    } else {
      // If quantity is 1, remove the item
      await removeItem(cartItemId);
    }
  }

  Future<void> removeItem(String cartItemId) async {
    final deleteResponse = await supabase
        .from('Cart_item')
        .delete()
        .eq('id', cartItemId);

    if (deleteResponse.error != null) {
      throw Exception("Failed to remove item from cart");
    }
  }

  Future<void> addToCart({
    required String userId,
    required String productId,
    required int quantity,
    required double price,
  }) async {
    final uuid = Uuid();
    final cartResponse = await supabase
        .from('Cart') // lowercase
        .select('id')
        .eq('userId', userId) // lowercase snake_case
        .maybeSingle();

    String cartId;

    if (cartResponse == null) {
      // No cart, create one
      final createCartResponse = await supabase
          .from('Cart')
          .insert({'userId': userId, 'id': uuid.v4()})
          .select('id')
          .maybeSingle();

      if (createCartResponse == null || createCartResponse['id'] == null) {
        throw Exception('Failed to create cart');
      }
      cartId = createCartResponse['id'];
    } else {
      cartId = cartResponse['id'];
    }

    // Check if the product is already in the cart
    final existingItem = await supabase
        .from('Cart_item')
        .select('id, quantity')
        .eq('cartId', cartId)
        .eq('productId', productId)
        .maybeSingle();

    if (existingItem == null) {
      // Insert new cart item
      final insertResponse = await supabase
          .from('Cart_item')
          .insert({
            'id': uuid.v4(),
            'cartId': cartId,
            'productId': productId,
            'quantity': quantity,
            'price': price,
          })
          .select()
          .maybeSingle();

      if (insertResponse == null) {
        throw Exception('Failed to add product to cart');
      }
    } else {
      // Update quantity of existing item
      final newQuantity = (existingItem['quantity'] as int) + quantity;

      final updateResponse = await supabase
          .from('Cart_item')
          .update({'quantity': newQuantity})
          .eq('id', existingItem['id'])
          .select()
          .maybeSingle();

      if (updateResponse == null) {
        throw Exception('Failed to update cart item quantity');
      }
    }
  }
}
