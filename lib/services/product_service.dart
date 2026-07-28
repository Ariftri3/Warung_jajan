import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Semua query terkait produk & kategori ada di sini.
/// Home Screen & Product List Screen memanggil ini lewat ProductProvider.
class ProductService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  /// Dipakai di Home Screen bagian "Paling Populer".
  Stream<List<ProductModel>> getAllProducts() {
    return _productsRef.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Dipakai saat user tap kategori (mis. "Kue Basah") di Home/Product List.
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    return _productsRef
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Dipakai di Product Detail Screen.
  Future<ProductModel> getProductById(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    return ProductModel.fromFirestore(doc);
  }

  /// Dipakai Search Bar di Home Screen (pencarian sederhana di sisi client,
  /// cukup untuk skala tugas kuliah — untuk skala besar sebaiknya pakai Algolia).
  Stream<List<ProductModel>> searchProducts(String keyword) {
    return _productsRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) => p.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList());
  }

  // ==== CRUD tambahan supaya syarat tugas "fungsi CRUD" terpenuhi ====

  Future<void> addProduct(ProductModel product) async {
    await _productsRef.add(product.toMap());
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _productsRef.doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }
}
