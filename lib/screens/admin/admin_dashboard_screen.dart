import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/order_model.dart';
import '../../utils/currency_formatter.dart';
import 'admin_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Color primaryGreen = const Color(0xFF1B4D24);
  final Color bgColor = const Color(0xFFF7F9F2);

  String _selectedFilter = 'Semua';

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diubah menjadi: "$newStatus"'),
          backgroundColor: newStatus == 'Dibatalkan' ? Colors.red : primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmDialog(BuildContext context, String orderId, String newStatus, String actionTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(actionTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin mengubah status pesanan ini menjadi "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Dibatalkan' ? Colors.red : primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(context, orderId, newStatus);
            },
            child: const Text('Ya, Lanjutkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AdminDrawer(activeMenu: 'orders'),
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
              'Kelola Pesanan Masuk',
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
      body: Column(
        children: [
          // Filter Status Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Diproses'),
                  _buildFilterChip('Dikirim'),
                  _buildFilterChip('Selesai'),
                  _buildFilterChip('Dibatalkan'),
                ],
              ),
            ),
          ),

          // Daftar Pesanan
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada pesanan masuk',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Parse orders
                final List<OrderModel> orders = snapshot.data!.docs
                    .map((doc) => OrderModel.fromFirestore(doc))
                    .toList();

                // Sort terbaru di atas
                orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                // Filter
                final filteredOrders = _selectedFilter == 'Semua'
                    ? orders
                    : orders.where((o) => o.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada pesanan dengan status "$_selectedFilter"',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(context, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: GoogleFonts.inter(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        selectedColor: primaryGreen,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (val) {
          if (val) {
            setState(() {
              _selectedFilter = label;
            });
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusBgColor = Colors.orange.shade50;
    Color statusTextColor = Colors.orange.shade800;

    if (order.status == 'Dikirim') {
      statusBgColor = Colors.blue.shade50;
      statusTextColor = Colors.blue.shade800;
    } else if (order.status == 'Selesai') {
      statusBgColor = Colors.green.shade50;
      statusTextColor = Colors.green.shade800;
    } else if (order.status == 'Dibatalkan') {
      statusBgColor = Colors.red.shade50;
      statusTextColor = Colors.red.shade800;
    }

    final formattedDate =
        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    final shortId = order.id.length >= 6 ? order.id.substring(0, 6).toUpperCase() : order.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt, color: Color(0xFF1B4D24), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '#$shortId',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1B4D24),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.inter(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formattedDate,
            style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11),
          ),
          const Divider(height: 20),

          // Items summary
          Text(
            'Daftar Jajanan:',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '• ${item.name} (${item.quantity}x)',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.price * item.quantity),
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Shipping & Payment info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.shippingAddress.isEmpty ? 'Alamat belum diisi' : order.shippingAddress,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengiriman: ${order.shippingMethod}',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    Text(
                      'Bayar: ${order.paymentMethod}',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran:',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                CurrencyFormatter.format(order.total),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons untuk Admin
          _buildActionButtons(context, order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    if (order.status == 'Diproses' || order.status == 'Menunggu Pembayaran') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _showConfirmDialog(
                context,
                order.id,
                'Dibatalkan',
                'Batalkan Pesanan',
              ),
              child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.delivery_dining, size: 18),
              label: const Text('Kirim Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5), // Blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _showConfirmDialog(
                context,
                order.id,
                'Dikirim',
                'Kirim Pesanan',
              ),
            ),
          ),
        ],
      );
    } else if (order.status == 'Dikirim') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Tandai Selesai (Diterima)', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 11),
          ),
          onPressed: () => _showConfirmDialog(
            context,
            order.id,
            'Selesai',
            'Selesaikan Pesanan',
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          order.status == 'Selesai' ? 'Pesanan telah selesai' : 'Pesanan telah dibatalkan',
          style: GoogleFonts.inter(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }
}
