import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/login_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'home/kategori_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF327940);
    final Color textColor = const Color(0xFF2A3A4A);
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // Header Profile Dinamis
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 26, left: 20, right: 20),
            color: primaryGreen,
            child: currentUser == null
                ? Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_outline, color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tamu',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Silakan masuk',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String displayName = currentUser.displayName ?? 'Pengguna';
                      String email = currentUser.email ?? '';

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null) {
                          if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
                            displayName = data['name'];
                          }
                          if (data['email'] != null && data['email'].toString().trim().isNotEmpty) {
                            email = data['email'];
                          }
                        }
                      }

                      final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

                      return Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white70, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                if (currentUser != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      final bool isAdmin = data != null &&
                          (data['role'] == 'admin' ||
                              (currentUser.email != null && currentUser.email!.contains('admin')));
                      if (!isAdmin) return const SizedBox.shrink();

                      return Column(
                        children: [
                          _buildAdminButton(context),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Divider(color: Color(0xFFF0F0F0)),
                          ),
                        ],
                      );
                    },
                  ),
                _buildMenuItem(Icons.home_outlined, 'Beranda', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(0);
                }),
                _buildMenuItem(Icons.grid_view_outlined, 'Kategori', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(1);
                }),
                _buildMenuItem(Icons.shopping_cart_outlined, 'Keranjang', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(2);
                }),
                _buildMenuItem(Icons.location_on_outlined, 'Alamat Saya', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(3);
                }),
                _buildMenuItem(Icons.local_offer_outlined, 'Promo', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  _showPromoBottomSheet(context, primaryGreen);
                }),
                _buildMenuItem(Icons.settings_outlined, 'Pengaturan', primaryGreen, textColor, () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(3);
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
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

  Widget _buildAdminButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B4D24).withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B4D24),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.storefront, color: Colors.white, size: 20),
        ),
        title: Text(
          'Mode Penjual (Admin)',
          style: GoogleFonts.inter(
            color: const Color(0xFF1B4D24),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Kelola pesanan & stok jajanan',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade700),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1B4D24)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        },
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
                subtitle: const Text('Beli minimal 10 Pcs Gorengan, dapat diskon 20%!'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delivery_dining, color: Colors.orange, size: 32),
                title: Text('Gratis Ongkir', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                subtitle: const Text('Gratis ongkir untuk pemesanan di atas Rp 50.000 (maks. 5km)'),
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
