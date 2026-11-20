import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../app_drawer.dart';
import 'home_screen.dart';
import '../detail/detail_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/shimmer_loading.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({Key? key}) : super(key: key);

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  int _selectedIndex = 1; // Tab Kategori aktif
  final Color primaryGreen = const Color(0xFF266E31);
  final Color bgColor = const Color(0xFFF7F9F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildChips(),
              const SizedBox(height: 24),
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  String categoryName = productProvider.selectedCategoryId == 'Semua' 
                      ? 'Semua Jajanan' 
                      : (productProvider.selectedCategoryId == 'Kue Basah' ? 'Aneka Kue Basah' : productProvider.selectedCategoryId);
                  
                  String subtitle = 'Pilihan jajanan pasar segar hari ini';
                  if (productProvider.selectedCategoryId == 'Gorengan') {
                    subtitle = 'Gurih, renyah, dan selalu nikmat';
                  } else if (productProvider.selectedCategoryId == 'Manis') {
                    subtitle = 'Jajanan manis legit untuk ceriakan harimu';
                  } else if (productProvider.selectedCategoryId == 'Kue Kering') {
                    subtitle = 'Renyah dan cocok untuk teman minum teh';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 16),
              _buildProductGrid(),
              const SizedBox(height: 24),
              _buildPromoBanner(),
              const SizedBox(height: 40), // Jarak tambahan untuk FAB
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Builder(builder: (context) {
        return IconButton(
          icon: Icon(Icons.menu, color: primaryGreen, size: 28),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      }),
      title: Text(
        'Warung Jajan',
        style: GoogleFonts.merriweather(
          color: primaryGreen,
          fontWeight: FontWeight.w900,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: primaryGreen, size: 28),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ProductSearchDelegate(context.read<ProductProvider>()),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey.withOpacity(0.2),
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildChips() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('Semua', productProvider),
              const SizedBox(width: 8),
              _buildChip('Kue Basah', productProvider),
              const SizedBox(width: 8),
              _buildChip('Kue Kering', productProvider),
              const SizedBox(width: 8),
              _buildChip('Gorengan', productProvider),
            ],
          ),
        );
      }
    );
  }

  Widget _buildChip(String label, ProductProvider provider) {
    bool isSelected = provider.selectedCategoryId == label;
    return GestureDetector(
      onTap: () {
        provider.selectCategory(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return StreamBuilder<List<ProductModel>>(
          stream: productProvider.watchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ProductGridShimmer();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }
            
            final products = snapshot.data ?? [];
            
            if (products.isEmpty) {
              return const Center(child: Text('Tidak ada produk.'));
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(product);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final bool isAvailable = product.isAvailable && product.stock > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(product.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 110, color: Colors.grey))
                    : Image.asset(product.imageUrl.isNotEmpty ? product.imageUrl : 'assets/images/kue lapis rainbow.jpeg', height: 110, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 110, color: Colors.grey)),
              ),
              if (!isAvailable)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'HABIS',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? const Color(0xFF333333) : Colors.grey.shade500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.tasteTag,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(Habis)',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rp ${product.price}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isAvailable ? primaryGreen : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (_) => DetailScreen(product: product)),
                             );
                          },
                          icon: Icon(isAvailable ? Icons.info_outline : Icons.cancel_outlined, size: 14),
                          label: Text(
                            isAvailable ? 'Detail' : 'Stok Habis',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable ? primaryGreen : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAB9), // Warna peach/salem
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promo Sarapan!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  'Dapatkan diskon 20% untuk pembelian minimal 3 porsi kue basah sebelum jam 10 pagi.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.home_outlined, 'Beranda'),
          _buildNavItem(1, Icons.category, 'Kategori'),
          _buildNavCartItem(2, Icons.shopping_cart_outlined, 'Keranjang', 2),
          _buildNavItem(3, Icons.person_outline, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ProfileScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNavCartItem(int index, IconData icon, String label, int badgeCount) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const CartScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 24,
                ),
                if (badgeCount > 0 && !isSelected)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final ProductProvider provider;
  ProductSearchDelegate(this.provider);

  @override
  String get searchFieldLabel => 'Cari jajan favoritmu...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Ketik untuk mencari produk',
          style: GoogleFonts.inter(color: Colors.grey.shade600),
        ),
      );
    }
    return StreamBuilder<List<ProductModel>>(
      stream: provider.watchSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF266E31)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Produk tidak ditemukan',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final product = snapshot.data![index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 60, height: 60, color: Colors.grey))
                    : Image.asset(product.imageUrl.isNotEmpty ? product.imageUrl : 'assets/images/kue lapis rainbow.jpeg', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 60, height: 60, color: Colors.grey)),
              ),
              title: Text(
                product.name,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Rp ${product.price}',
                style: GoogleFonts.inter(color: const Color(0xFF266E31), fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: product)));
              },
            );
          },
        );
      }
    );
  }
}
