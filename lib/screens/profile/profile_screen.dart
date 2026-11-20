import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../app_drawer.dart';
import '../home/home_screen.dart';
import '../home/kategori_screen.dart';
import '../cart/cart_screen.dart';
import '../auth/login_screen.dart';
import 'orders_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3; // Profil aktif
  final Color primaryGreen = const Color(0xFF266E31);
  final Color bgColor = const Color(0xFFF7F9F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.arrow_back, color: primaryGreen),
              onPressed: () {
                // Sesuai desain ada panah, tapi jika ingin Drawer bisa diganti
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomeScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            );
          }
        ),
        title: Text(
          'Profil Saya',
          style: GoogleFonts.merriweather(
            color: primaryGreen,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primaryGreen, size: 24),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final uid = authProvider.currentUser?.uid;
              if (uid != null) {
                final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                UserModel userModel;
                if (!doc.exists) {
                  userModel = UserModel(
                    uid: uid,
                    name: authProvider.currentUser?.displayName ?? 'Pengguna',
                    email: authProvider.currentUser?.email ?? 'Tidak ada email',
                  );
                } else {
                  userModel = UserModel.fromFirestore(doc);
                }
                _showEditProfileDialog(userModel);
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final uid = authProvider.currentUser?.uid;
          if (uid == null) {
            return const Center(child: Text('Belum login.'));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              UserModel userModel;
              if (!snapshot.hasData || !snapshot.data!.exists) {
                userModel = UserModel(
                  uid: uid,
                  name: authProvider.currentUser?.displayName ?? 'Arif',
                  email: authProvider.currentUser?.email ?? 'ariftri815@gmail.com',
                  phone: '0812-3456-7890',
                  address: 'Kebayoran Lama, Jakarta Selatan',
                );
              } else {
                userModel = UserModel.fromFirestore(snapshot.data!);
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildProfileCard(
                        userModel,
                        authProvider.currentUser?.displayName ?? 'Pengguna',
                        authProvider.currentUser?.email ?? 'Tidak ada email',
                      ),
                      const SizedBox(height: 24),
              
              _buildMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Pesanan Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Daftar Alamat',
                subtitle: userModel.address.isEmpty ? 'Belum ada alamat, ketuk untuk tambah.' : userModel.address,
                onTap: () => _showEditAddressDialog(userModel.address, uid),
              ),
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                title: 'Panel Penjual (Admin)',
                subtitle: userModel.role == 'admin'
                    ? 'Buka panel pengelola pesanan & menu'
                    : 'Ketuk untuk aktifkan mode admin & buka panel (Demo)',
                onTap: () async {
                  if (userModel.role != 'admin') {
                    await FirebaseFirestore.instance.collection('users').doc(uid).set({
                      'role': 'admin',
                    }, SetOptions(merge: true));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode Admin berhasil diaktifkan untuk akun ini!'),
                          backgroundColor: Color(0xFF1B4D24),
                        ),
                      );
                    }
                  }
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 12),
              _buildLogoutButton(),
              
              Text(
                'Version 2.4.1 (Indonesian Heritage Edition)',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(UserModel user, String fallbackName, String fallbackEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 4),
                  color: Colors.grey.shade200,
                  image: user.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.photoUrl.isEmpty ? Icon(Icons.person, size: 60, color: Colors.grey.shade600) : null,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name.trim().isEmpty ? fallbackName : user.name,
            style: GoogleFonts.merriweather(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: primaryGreen, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Pelanggan Setia',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(user.email.trim().isEmpty ? fallbackEmail : user.email, style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_iphone, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(user.phone.isEmpty ? '-' : user.phone, style: GoogleFonts.inter(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingBadge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4), // light green box
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingBadge != null) ...[
            trailingBadge,
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      child: OutlinedButton.icon(
        onPressed: () async {
          await Provider.of<AuthProvider>(context, listen: false).logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
        label: Text(
          'Keluar dari Akun',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFC62828),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFC62828)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
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
          _buildNavItem(1, Icons.category_outlined, 'Kategori'),
          _buildNavCartItem(2, Icons.shopping_cart_outlined, 'Keranjang', 3), // 3 items di screenshot keranjang sebelumnya
          _buildNavItem(3, Icons.person, 'Profil'),
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
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const KategoriScreen(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
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

  Future<void> _showEditAddressDialog(String currentAddress, String uid) async {
    final controller = TextEditingController(text: currentAddress);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah Alamat', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Masukkan alamat lengkap Anda...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey.shade600))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(uid).set({
                  'address': controller.text.trim()
                }, SetOptions(merge: true));
                if (context.mounted) Navigator.pop(context);
              },
              child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _showEditProfileDialog(UserModel userModel) async {
    final nameController = TextEditingController(text: userModel.name);
    final phoneController = TextEditingController(text: userModel.phone);
    final photoController = TextEditingController(text: userModel.photoUrl);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profil', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: photoController,
                  decoration: InputDecoration(
                    labelText: 'URL Foto Profil (opsional)',
                    hintText: 'https://...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Atau pilih avatar ini:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Felix', photoController),
                    _buildAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Aneka', photoController),
                    _buildAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Jajanan', photoController),
                    _buildAvatarOption('https://api.dicebear.com/7.x/avataaars/png?seed=Food', photoController),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('users').doc(userModel.uid).set({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'photoUrl': photoController.text.trim(),
                }, SetOptions(merge: true));
                if (context.mounted) Navigator.pop(context);
              },
              child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarOption(String url, TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        controller.text = url;
      },
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }
}
