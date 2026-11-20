import 'package:cloud_firestore/cloud_firestore.dart';

/// Merepresentasikan 1 dokumen di collection Firestore: products/{id}
///
/// Field disesuaikan dengan yang tampil di mockup:
/// - Home & Product List: nama, harga, gambar, tag rasa (mis. "Manis", "Gurih")
/// - Product Detail: deskripsi, rating, varian (3pcs/10pcs), jumlah terjual
class ProductModel {
  final String id;
  final String name;              // "Onde-Onde"
  final String description;       // deskripsi panjang di Product Detail
  final int price;                // dalam Rupiah, contoh: 15000
  final String imageUrl;
  final String categoryId;        // relasi ke categories/{id}: "Kue Basah", dst
  final String tasteTag;          // "Manis" | "Gurih" | "Gurih & Manis" | "Premium"
  final double rating;            // contoh 4.9
  final int reviewCount;          // contoh 200
  final int sold;                 // jumlah terjual, opsional dipakai di badge "Terlaris"
  final List<String> variants;    // contoh ["3 Pcs", "10 Pcs"]
  final bool isAvailable;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.tasteTag,
    this.rating = 0,
    this.reviewCount = 0,
    this.sold = 0,
    this.variants = const [],
    this.isAvailable = true,
    this.stock = 50,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0) as int,
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      tasteTag: data['tasteTag'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0) as int,
      sold: (data['sold'] ?? 0) as int,
      variants: List<String>.from(data['variants'] ?? []),
      isAvailable: (data['isAvailable'] as bool?) ?? true,
      stock: (data['stock'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'tasteTag': tasteTag,
      'rating': rating,
      'reviewCount': reviewCount,
      'sold': sold,
      'variants': variants,
      'isAvailable': isAvailable,
      'stock': stock,
    };
  }
}
