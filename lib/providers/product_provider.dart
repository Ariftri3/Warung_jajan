import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// Dipakai Home Screen & Product List Screen untuk menampilkan data produk.
class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  String selectedCategoryId = 'Semua';

  /// Panggil ini dari Home Screen: Provider.of<ProductProvider>(context).getProducts()
  /// atau langsung pakai StreamBuilder(stream: productProvider.watchProducts()).
  Stream<List<ProductModel>> watchProducts() {
    if (selectedCategoryId == 'Semua') {
      return _productService.getAllProducts();
    }
    return _productService.getProductsByCategory(selectedCategoryId);
  }

  Stream<List<ProductModel>> watchSearch(String keyword) {
    return _productService.searchProducts(keyword);
  }

  void selectCategory(String categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<ProductModel> getProductDetail(String productId) {
    return _productService.getProductById(productId);
  }
}
