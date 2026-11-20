import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

/// Disimpan di Firestore: orders/{orderId}
/// Field sesuai Checkout Screen: alamat, metode pengiriman, metode pembayaran,
/// ringkasan (subtotal, ongkir, total).
class OrderModel {
  final String id;
  final String uid;
  final List<CartItemModel> items;
  final String shippingAddress;
  final String shippingMethod;   // "Reguler" | "Instant"
  final String paymentMethod;    // "DANA" | "GoPay" | "OVO" | "Transfer Bank"
  final int subtotal;
  final int shippingCost;
  final int total;
  final String status;          // "Menunggu Pembayaran" | "Diproses" | "Dikirim" | "Selesai" | "Dibatalkan"
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String? paymentProofUrl; // URL bukti transfer (opsional)

  OrderModel({
    required this.id,
    required this.uid,
    required this.items,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    this.status = 'Menunggu Pembayaran',
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.paymentProofUrl,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel(
                productId: e['productId'] ?? '',
                name: e['name'] ?? '',
                imageUrl: e['imageUrl'] ?? '',
                price: (e['price'] ?? 0) as int,
                quantity: (e['quantity'] ?? 1) as int,
              ))
          .toList(),
      shippingAddress: data['shippingAddress'] ?? '',
      shippingMethod: data['shippingMethod'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      subtotal: (data['subtotal'] ?? 0) as int,
      shippingCost: (data['shippingCost'] ?? 0) as int,
      total: (data['total'] ?? 0) as int,
      status: data['status'] ?? 'Menunggu Pembayaran',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentProofUrl: data['paymentProofUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'items': items
          .map((e) => {
                'productId': e.productId,
                'name': e.name,
                'imageUrl': e.imageUrl,
                'price': e.price,
                'quantity': e.quantity,
              })
          .toList(),
      'shippingAddress': shippingAddress,
      'shippingMethod': shippingMethod,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
      if (paymentProofUrl != null) 'paymentProofUrl': paymentProofUrl,
    };
  }
}
