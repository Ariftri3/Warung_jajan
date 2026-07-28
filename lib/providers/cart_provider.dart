import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// Dipakai Cart Screen & Checkout Screen. Hitung subtotal/total otomatis,
/// TIDAK hardcode (sesuai syarat tugas poin 6).
class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> items = [];

  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Panggil sekali setelah user login (mis. di initState Home Screen)
  /// untuk mulai dengarkan perubahan cart secara real-time.
  void listenToCart(String uid) {
    _cartService.getCartItems(uid).listen((cartItems) {
      items = cartItems;
      notifyListeners();
    });
  }

  Future<void> addToCart(String uid, ProductModel product, {int qty = 1}) async {
    await _cartService.addToCart(uid, product, qty: qty);
  }

  Future<void> updateQuantity(String uid, String productId, int newQty) async {
    await _cartService.updateQuantity(uid, productId, newQty);
  }

  Future<void> removeItem(String uid, String productId) async {
    await _cartService.removeFromCart(uid, productId);
  }

  Future<void> clearCart(String uid) async {
    await _cartService.clearCart(uid);
  }
}
