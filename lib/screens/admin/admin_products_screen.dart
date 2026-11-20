import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../models/product_model.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/shimmer_loading.dart';
import 'admin_drawer.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final Color primaryGreen = const Color(0xFF1B4D24);
  final Color bgColor = const Color(0xFFF7F9F2);

  Future<void> _toggleAvailability(String productId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'isAvailable': !currentStatus,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditProductSheet(ProductModel product) {
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Jajanan: ${product.name}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Stok',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final int? newPrice = int.tryParse(priceController.text.trim());
                    final int? newStock = int.tryParse(stockController.text.trim());

                    if (newPrice == null || newStock == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harga dan stok harus berupa angka valid!')),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance.collection('products').doc(product.id).update({
                        'price': newPrice,
                        'stock': newStock,
                        'isAvailable': newStock > 0,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu berhasil diperbarui!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ImgBB API key - ganti dengan API key milik kamu dari imgbb.com
  static const String _imgbbApiKey = '9e6a02d6da99bb00bdd612910437e62b';

  Future<String?> _uploadImageToImgBB(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
        body: {'image': base64Image},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _showAddProductSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Kue Basah';
    String selectedTag = 'Manis';
    XFile? pickedImage;
    bool isUploadingImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage(ImageSource source) async {
              final picker = ImagePicker();
              final file = await picker.pickImage(
                source: source,
                maxWidth: 800,
                maxHeight: 800,
                imageQuality: 85,
              );
              if (file != null) {
                setModalState(() => pickedImage = file);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Menu Jajan Baru',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),

                    // ── FOTO PRODUK ──────────────────────────────────────
                    Text(
                      'Foto Produk',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (_) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library_outlined),
                                    title: const Text('Pilih dari Galeri'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  if (!kIsWeb)
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt_outlined),
                                      title: const Text('Ambil Foto dari Kamera'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        pickImage(ImageSource.camera);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: pickedImage != null ? primaryGreen : Colors.grey.shade300,
                              width: pickedImage != null ? 2 : 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: pickedImage != null
                                ? (kIsWeb
                                    ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                                    : Image.file(File(pickedImage!.path), fit: BoxFit.cover))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey.shade400),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Ketuk untuk\nupload foto',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (pickedImage != null)
                      Center(
                        child: TextButton.icon(
                          onPressed: () => setModalState(() => pickedImage = null),
                          icon: const Icon(Icons.close, size: 14, color: Colors.red),
                          label: Text('Hapus foto', style: GoogleFonts.inter(fontSize: 12, color: Colors.red)),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // ── FORM FIELDS ──────────────────────────────────────
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Jajanan',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Kue Basah', child: Text('Kue Basah')),
                        DropdownMenuItem(value: 'Kue Kering', child: Text('Kue Kering')),
                        DropdownMenuItem(value: 'Gorengan', child: Text('Gorengan')),
                        DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedTag,
                      decoration: InputDecoration(
                        labelText: 'Rasa / Tag',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Manis', child: Text('Manis')),
                        DropdownMenuItem(value: 'Gurih', child: Text('Gurih')),
                        DropdownMenuItem(value: 'Gurih & Manis', child: Text('Gurih & Manis')),
                        DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedTag = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Singkat',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isUploadingImage
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final price = int.tryParse(priceController.text.trim());
                                final desc = descController.text.trim();

                                if (name.isEmpty || price == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lengkapi nama dan harga jajanan!')),
                                  );
                                  return;
                                }

                                // Upload foto jika ada
                                String imageUrl = 'assets/images/kue lapis rainbow.jpeg';
                                if (pickedImage != null) {
                                  setModalState(() => isUploadingImage = true);
                                  final uploadedUrl = await _uploadImageToImgBB(pickedImage!);
                                  setModalState(() => isUploadingImage = false);
                                  if (uploadedUrl != null) {
                                    imageUrl = uploadedUrl;
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Gagal upload foto, menggunakan gambar default.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                }

                                try {
                                  final newProduct = ProductModel(
                                    id: '',
                                    name: name,
                                    description: desc.isEmpty ? 'Jajanan khas Nusantara lezat dan higienis.' : desc,
                                    price: price,
                                    imageUrl: imageUrl,
                                    categoryId: selectedCategory,
                                    tasteTag: selectedTag,
                                    rating: 5.0,
                                    reviewCount: 1,
                                    sold: 0,
                                    isAvailable: true,
                                    stock: 50,
                                  );

                                  await FirebaseFirestore.instance.collection('products').add(newProduct.toMap());

                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Jajanan baru berhasil ditambahkan!')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal menambahkan: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        child: isUploadingImage
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Simpan Menu Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AdminDrawer(activeMenu: 'products'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: primaryGreen, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Menu & Stok',
              style: GoogleFonts.inter(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Panel Penjual / Admin',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
        onPressed: _showAddProductSheet,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductListShimmer();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada produk jajan.'));
          }

          final products = snapshot.data!.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductRow(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductRow(ProductModel product) {
    final bool isAvailable = product.isAvailable && product.stock > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: product.imageUrl.startsWith('http')
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.fastfood, color: Colors.grey)),
                    )
                  : Image.asset(
                      product.imageUrl.isNotEmpty ? product.imageUrl : 'assets/images/kue lapis rainbow.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.fastfood, color: Colors.grey)),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.categoryId} • ${CurrencyFormatter.format(product.price)}',
                  style: GoogleFonts.inter(color: primaryGreen, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${product.stock} pcs',
                  style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                onPressed: () => _showEditProductSheet(product),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAvailable ? 'Tersedia' : 'Habis',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: isAvailable,
                      activeColor: Colors.green,
                      onChanged: (val) => _toggleAvailability(product.id, isAvailable),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
