import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';

class DetailScreen extends StatefulWidget {
  final ProductModel product;
  const DetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;
  String _selectedVariant = '';
  bool _useAlatMakan = false;

  final Color primaryGreen = const Color(0xFF2E7D32);
  final Color bgColor = const Color(0xFFF7F9F2);

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }
  }

  List<Map<String, dynamic>> _getDynamicFeatures() {
    String category = widget.product.categoryId.toLowerCase();
    String name = widget.product.name.toLowerCase();

    if (category == 'gorengan' || name.contains('tahu') || name.contains('goreng') || name.contains('pedas')) {
      return [
        {
          'icon': Icons.local_fire_department_outlined,
          'title': 'Gurih & Renyah',
          'subtitle': 'Tekstur renyah di luar dengan isian nikmat.',
        },
        {
          'icon': Icons.inventory_2_outlined,
          'title': 'Dibuat Fresh',
          'subtitle': 'Baru digoreng ketika pesanan Anda masuk.',
        },
      ];
    } else if (category == 'manis' || name.contains('klepon') || name.contains('putu') || name.contains('lupis')) {
      return [
        {
          'icon': Icons.eco_outlined,
          'title': 'Pandan Asli',
          'subtitle': 'Tanpa pewarna buatan, 100% perasan daun pandan.',
        },
        {
          'icon': Icons.inventory_2_outlined,
          'title': 'Dibuat Fresh',
          'subtitle': 'Dikukus langsung saat pesanan masuk.',
        },
      ];
    } else {
      return [
        {
          'icon': Icons.verified_outlined,
          'title': 'Bahan Premium',
          'subtitle': 'Dibuat dari bahan baku pilihan berkualitas tinggi.',
        },
        {
          'icon': Icons.inventory_2_outlined,
          'title': 'Dibuat Fresh',
          'subtitle': 'Disiapkan langsung saat pesanan masuk.',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = _getDynamicFeatures();
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Jajanan',
          style: GoogleFonts.merriweather(
            color: primaryGreen,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: widget.product.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        widget.product.imageUrl.isNotEmpty ? widget.product.imageUrl : 'assets/images/putu ayu.jpeg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                ),
                
                // Overlapping Content Card
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.product.tasteTag,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_border, color: Color(0xFF8D6E63), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.product.rating} (${widget.product.reviewCount}+)',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF5D4037),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Title
                        Text(
                          widget.product.name,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Price
                        Text(
                          'Rp ${widget.product.price}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          widget.product.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (widget.product.variants.isNotEmpty) ...[
                          Text(
                            'Pilih Varian',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: widget.product.variants.map((v) {
                              return _buildVariantOption(v);
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Alat Makan
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                          ),
                          child: CheckboxListTile(
                            value: _useAlatMakan,
                            onChanged: (val) {
                              setState(() {
                                _useAlatMakan = val ?? false;
                              });
                            },
                            activeColor: primaryGreen,
                            title: Text(
                              'Alat Makan',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Tambahkan sendok & garpu kayu',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            secondary: const Icon(Icons.restaurant, color: Color(0xFF8D6E63)),
                            controlAffinity: ListTileControlAffinity.trailing,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Mengapa Anda Akan Menyukainya
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mengapa Anda Akan Menyukainya',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                features[0]['icon'],
                                features[0]['title'],
                                features[0]['subtitle'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureCard(
                                features[1]['icon'],
                                features[1]['title'],
                                features[1]['subtitle'],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100), // Spacing for bottom bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Quantity Selector
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            color: const Color(0xFF1A1A1A),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Text(
                            '$_quantity ${widget.product.categoryId == 'Kue Kering' ? 'Toples' : 'Porsi'}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            color: primaryGreen,
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Add to Cart Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final authProvider = context.read<AuthProvider>();
                            final uid = authProvider.currentUser?.uid;
                            if (uid == null) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Silakan login terlebih dahulu!')),
                               );
                               return;
                            }
                            
                            final cartProvider = context.read<CartProvider>();
                            cartProvider.addToCart(uid, widget.product, qty: _quantity);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${widget.product.name} ditambahkan ke keranjang!'),
                                backgroundColor: primaryGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_basket_outlined, size: 20),
                          label: Text(
                            '+ Keranjang',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantOption(String variantName) {
    bool isSelected = _selectedVariant == variantName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVariant = variantName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          variantName,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primaryGreen : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
