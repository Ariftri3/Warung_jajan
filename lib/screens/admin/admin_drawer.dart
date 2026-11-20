import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import '../auth/login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';

class AdminDrawer extends StatelessWidget {
  final String activeMenu; // 'orders' | 'products'
  const AdminDrawer({super.key, this.activeMenu = 'orders'});

  @override
  Widget build(BuildContext context) {
    const Color adminHeaderColor = Color(0xFF1B4D24);
    const Color textColor = Color(0xFF2A3A4A);
    const Color accentGold = Color(0xFFFFB300);

    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          // Header Khusus Admin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 54, bottom: 24, left: 20, right: 20),
            color: adminHeaderColor,
            child: StreamBuilder<DocumentSnapshot>(
              stream: currentUser == null
                  ? null
                  : FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                String displayName = currentUser?.displayName ?? 'Admin Warung';
                String email = currentUser?.email ?? 'admin@warungjajan.com';

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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentGold, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.storefront, color: Colors.white, size: 28),
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
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Badge Mode Penjual
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGold.withOpacity(0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: accentGold, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'PANEL PENJUAL / ADMIN',
                            style: GoogleFonts.inter(
                              color: accentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Kelola Pesanan Masuk',
                  isSelected: activeMenu == 'orders',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeMenu != 'orders') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.fastfood_outlined,
                  title: 'Kelola Menu & Stok',
                  isSelected: activeMenu == 'products',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeMenu != 'products') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
                      );
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Divider(color: Color(0xFFEAEAEA)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF266E31), size: 24),
                  title: Text(
                    'Kembali ke Toko Pembeli',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF266E31),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.logout, color: Color(0xFFE53935), size: 24),
                  title: Text(
                    'Keluar Akun',
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const Color primaryGreen = Color(0xFF1B4D24);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          color: isSelected ? primaryGreen : const Color(0xFF4A5568),
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? primaryGreen : const Color(0xFF2A3A4A),
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
