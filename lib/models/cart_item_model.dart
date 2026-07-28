import 'package:cloud_firestore/cloud_firestore.dart';

/// 1 item di dalam keranjang, disimpan di:
/// Firestore: carts/{uid}/items/{productId}
/// Sesuai mockup Cart Screen: nama produk, gambar, harga satuan, qty (stepper +/-).
class CartItemModel {
  final String productId;
  final String name;
  final String imageUrl;
  final int price;    // harga satuan saat ditambahkan
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      productId: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0) as int,
      quantity: (data['quantity'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}
