import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/order_model.dart';
import '../home/home_screen.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Color primaryGreen = const Color(0xFF266E31);
  final Color bgColor = const Color(0xFFF7F9F2);

  // States
  String selectedShipping = 'Sameday';
  String selectedPayment = 'COD (Bayar di Tempat)';
  String? selectedBank;
  bool _isFetchingLocation = false;
  String _currentAddress = 'Silakan ambil lokasi anda';
  double? _currentLat;
  double? _currentLng;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['address'] != null && data['address'].toString().isNotEmpty) {
            setState(() {
              _currentAddress = data['address'];
              _currentLat = (data['latitude'] as num?)?.toDouble();
              _currentLng = (data['longitude'] as num?)?.toDouble();
            });
          }
        }
      } catch (e) {
        // Abaikan jika error
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLat = position.latitude;
          _currentLng = position.longitude;
        });

        List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress =
                '${place.street}, ${place.subLocality}, ${place.locality}';
          });
        } else {
          setState(() {
            _currentAddress =
                'Koordinat: ${position.latitude}, ${position.longitude}';
          });
        }
      } else {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak.';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi.';
      });
    }

    setState(() {
      _isFetchingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
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
          'Checkout',
          style: GoogleFonts.inter(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(Icons.location_on_outlined, 'Alamat Pengiriman'),
              _buildAddressCard(),
              const SizedBox(height: 16),
              
              _buildSectionTitle(Icons.local_shipping_outlined, 'Metode Pengiriman'),
              _buildShippingMethodSelector(),
              const SizedBox(height: 8),
              
              _buildSectionTitle(Icons.account_balance_wallet_outlined, 'Metode Pembayaran'),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              
              _buildSummarySection(cartProvider),
              const SizedBox(height: 24),
              
              _buildProductDetails(cartProvider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, {String? actionText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryGreen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
            ),
          ),
          if (actionText != null)
            Text(
              actionText,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primaryGreen),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rumah', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_currentAddress, 
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13, height: 1.4)
          ),
          const SizedBox(height: 12),
          if (_isFetchingLocation)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: Text(
                  'Ambil Lokasi (GPS)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F5E9),
                  foregroundColor: primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodSelector() {
    String subtitle = selectedShipping == 'Sameday'
        ? 'Estimasi tiba hari ini (6-8 jam)'
        : 'Estimasi tiba dalam 1-2 jam';
    String price = selectedShipping == 'Sameday' ? 'Rp15.000' : 'Rp25.000';

    return GestureDetector(
      onTap: () {
        _showShippingOptions();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedShipping,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                Text(price,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        fontSize: 14)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShippingOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Metode Pengiriman',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildShippingOptionItem(
                  'Sameday', 'Estimasi tiba hari ini (6-8 jam)', 'Rp15.000'),
              _buildShippingOptionItem(
                  'Instant', 'Estimasi tiba dalam 1-2 jam', 'Rp25.000'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShippingOptionItem(String title, String subtitle, String price) {
    bool isSelected = selectedShipping == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedShipping = title;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8F4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            Text(price,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPaymentOption('COD (Bayar di Tempat)', 'Bayar saat pesanan tiba', Icons.money, Colors.green),
          const Divider(height: 1, indent: 48),
          _buildPaymentOption('Transfer Bank', 'BCA, Mandiri, BNI, BRI', Icons.account_balance, Colors.brown),
          if (selectedPayment == 'Transfer Bank')
             _buildBankSelection(),
        ],
      ),
    );
  }

  Widget _buildBankSelection() {
    return Container(
      padding: const EdgeInsets.only(left: 48, right: 16, bottom: 16),
      child: Column(
        children: [
          _buildBankItem('BCA'),
          _buildBankItem('Mandiri'),
          _buildBankItem('BNI'),
          _buildBankItem('BRI'),
        ],
      ),
    );
  }

  Widget _buildBankItem(String bankName) {
    bool isSelected = selectedBank == bankName;
    return InkWell(
      onTap: () {
        setState(() {
          selectedBank = bankName;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primaryGreen : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(bankName, style: GoogleFonts.inter(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, Color iconColor) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = title;
          if (title != 'Transfer Bank') {
             selectedBank = null;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedPayment,
              activeColor: primaryGreen,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedPayment = value;
                  });
                }
              },
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(CartProvider cartProvider) {
    int subtotal = cartProvider.subtotal;
    int shippingCost = selectedShipping == 'Sameday' ? 15000 : 25000;
    int total = subtotal + shippingCost;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.receipt_long_outlined, 'Ringkasan Belanja'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBEBEB).withOpacity(0.5), // light beige/grey
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal (${cartProvider.itemCount} Item)', 'Rp$subtotal'),
              const SizedBox(height: 8),
              _buildSummaryRow('Biaya Pengiriman', 'Rp$shippingCost'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Rp$total', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: primaryGreen)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(color: Colors.grey.shade800, fontSize: 13)),
      ],
    );
  }

  Widget _buildProductDetails(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text('Detail Produk', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
               Text('${cartProvider.itemCount} Jajanan', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartProvider.items.length,
          itemBuilder: (context, index) {
            final item = cartProvider.items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.imageUrl,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${item.quantity}x', style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('Rp${item.price}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 14)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              if (selectedPayment == 'Transfer Bank' && selectedBank == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih bank terlebih dahulu!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                final uid = authProvider.currentUser?.uid;
                
                if (uid != null) {
                  // Buat data pesanan
                  final int subtotal = cartProvider.subtotal;
                  final int shippingCost = selectedShipping == 'Sameday' ? 15000 : 25000;
                  final int total = subtotal + shippingCost;
                  
                  final orderData = OrderModel(
                    id: '',
                    uid: uid,
                    items: cartProvider.items,
                    shippingAddress: _currentAddress,
                    shippingMethod: selectedShipping,
                    paymentMethod: selectedPayment == 'Transfer Bank' 
                        ? 'Transfer Bank ($selectedBank)' 
                        : selectedPayment,
                    subtotal: subtotal,
                    shippingCost: shippingCost,
                    total: total,
                    status: 'Diproses',
                    latitude: _currentLat,
                    longitude: _currentLng,
                    createdAt: DateTime.now(),
                  );

                  // Simpan ke Firestore Orders
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .add(orderData.toMap());

                  // Update Alamat Terakhir ke Profil User
                  await FirebaseFirestore.instance.collection('users').doc(uid).set({
                    'address': _currentAddress,
                    'latitude': _currentLat,
                    'longitude': _currentLng,
                  }, SetOptions(merge: true));

                  await cartProvider.clearCart(uid);
                  
                  if (mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Column(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF266E31), size: 56),
                              SizedBox(height: 16),
                              Text(
                                'Pesanan Berhasil!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          content: const Text(
                            'Pesanan Anda sedang diproses. Anda dapat melihat status pesanan di halaman Riwayat.',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF266E31),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal membuat pesanan: Izin akses Firebase ditolak atau terjadi kesalahan jaringan.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buat Pesanan & Bayar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.money, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
