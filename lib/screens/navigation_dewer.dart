import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'home/kategori_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class NavigationDewer extends StatelessWidget {
  const NavigationDewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF327940); // Warna hijau untuk header dan ikon
    final Color textColor = const Color(0xFF2A3A4A); // Warna abu-abu gelap kebiruan untuk teks

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, // Untuk menghindari tint default Material 3
      child: Column(
        children: [
          // Header Profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            color: primaryGreen,
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_outline, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arif',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'arif@email.com',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildMenuItem(Icons.home_outlined, 'Beranda', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                }),
                _buildMenuItem(Icons.grid_view_outlined, 'Kategori', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KategoriScreen()));
                }),
                _buildMenuItem(Icons.shopping_cart_outlined, 'Keranjang', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                }),
                _buildMenuItem(Icons.location_on_outlined, 'Alamat Saya', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }),
                _buildMenuItem(Icons.local_offer_outlined, 'Promo', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  _showPromoBottomSheet(context, primaryGreen);
                }),
                _buildMenuItem(Icons.settings_outlined, 'Pengaturan', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Divider(color: Color(0xFFF0F0F0), thickness: 1),
                ),
                
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.logout, color: Color(0xFFE53935), size: 24),
                  title: Text(
                    'Keluar',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE53935),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Tutup drawer
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconColor, Color textColor, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini akan segera hadir!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPromoBottomSheet(BuildContext context, Color primaryGreen) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promo Menarik Hari Ini! 🎉',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_offer, color: Colors.green, size: 32),
                title: Text('Diskon 20% Gorengan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Text('Beli minimal 10 Pcs Gorengan, dapat diskon 20%!'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delivery_dining, color: Colors.orange, size: 32),
                title: Text('Gratis Ongkir', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: Text('Gratis ongkir untuk pemesanan di atas Rp 50.000 (maks. 5km)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
