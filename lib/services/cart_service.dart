import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

/// Semua operasi keranjang: carts/{uid}/items/{productId}
/// Dipakai oleh CartProvider — bukan langsung oleh Cart Screen.
class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _itemsRef(String uid) =>
      _firestore.collection('carts').doc(uid).collection('items');

  /// Dipakai Cart Screen (StreamBuilder) supaya isi keranjang selalu real-time.
  Stream<List<CartItemModel>> getCartItems(String uid) {
    return _itemsRef(uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Dipakai dari Product Detail Screen (tombol "Tambahkan ke Keranjang").
  /// Kalau produk sudah ada di cart, tinggal tambah qty-nya.
  Future<void> addToCart(String uid, ProductModel product, {int qty = 1}) async {
    final docRef = _itemsRef(uid).doc(product.id);
    final doc = await docRef.get();

    if (doc.exists) {
      final currentQty = (doc.data() as Map<String, dynamic>)['quantity'] ?? 0;
      await docRef.update({'quantity': currentQty + qty});
    } else {
      await docRef.set({
        'name': product.name,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'quantity': qty,
      });
    }
  }

  /// Dipakai tombol stepper +/- di Cart Screen.
  Future<void> updateQuantity(String uid, String productId, int newQty) async {
    if (newQty <= 0) {
      await removeFromCart(uid, productId);
      return;
    }
    await _itemsRef(uid).doc(productId).update({'quantity': newQty});
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _itemsRef(uid).doc(productId).delete();
  }

  /// Dipanggil OrderService setelah checkout berhasil, supaya cart kosong lagi.
  Future<void> clearCart(String uid) async {
    final snapshot = await _itemsRef(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
