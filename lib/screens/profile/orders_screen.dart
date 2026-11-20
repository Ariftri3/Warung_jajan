import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/shimmer_loading.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  final Color primaryGreen = const Color(0xFF266E31);
  final Color bgColor = const Color(0xFFF7F9F2);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Riwayat Pesanan',
          style: GoogleFonts.merriweather(
            color: primaryGreen,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text('Silakan login terlebih dahulu.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('uid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const OrderListShimmer();
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pesanan',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!.docs
                    .map((doc) => OrderModel.fromFirestore(doc))
                    .toList();

                // Sorting manual dari yang terbaru
                orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    
                    // Format tanggal
                    final String formattedDate = '${order.createdAt.day}-${order.createdAt.month}-${order.createdAt.year}, ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}';
                    
                    // Format item list
                    final String itemsString = order.items.map((item) {
                      return '${item.name} (${item.quantity}x)';
                    }).join(', ');

                    // Menentukan warna status
                    Color statusColor = Colors.orange;
                    if (order.status == 'Selesai') statusColor = Colors.green;
                    if (order.status == 'Dibatalkan') statusColor = Colors.red;
                    if (order.status == 'Dikirim') statusColor = Colors.blue;

                    String? firstImageUrl;
                    if (order.items.isNotEmpty) {
                      firstImageUrl = order.items.first.imageUrl;
                    }

                    return _buildOrderCard(
                      context: context,
                      orderId: order.id,
                      date: formattedDate,
                      status: order.status,
                      itemsString: itemsString,
                      total: CurrencyFormatter.format(order.total),
                      statusColor: statusColor,
                      imageUrl: firstImageUrl,
                      paymentProofUrl: order.paymentProofUrl,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required String orderId,
    required String date,
    required String status,
    required String itemsString,
    required String total,
    required Color statusColor,
    String? imageUrl,
    String? paymentProofUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag, color: primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Belanja',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fastfood, color: Colors.grey),
                            );
                          },
                        ),
                ),
              ] else ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      itemsString,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Belanja', style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
                  Text(total, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24),
                    onPressed: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Hapus Riwayat?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                          content: const Text('Apakah Anda yakin ingin menghapus pesanan ini dari riwayat?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ) ?? false;

                      if (confirm) {
                        await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text('Beli Lagi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),

          // Tampilkan bukti transfer jika ada
          if (paymentProofUrl != null && paymentProofUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Bukti Transfer',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                paymentProofUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
