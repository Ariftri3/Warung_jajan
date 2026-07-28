import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> seedProducts() async {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
  
  try {
    // Hapus data lama agar foto produk yang salah (typo/ekstensi salah) terganti
    final snapshot = await productsRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    if (kDebugMode) {
      print("Mulai seeding ulang data produk dengan gambar yang benar...");
    }

    final List<Map<String, dynamic>> dummyProducts = [
      {
        'name': 'Onde-Onde',
        'description': 'Onde-onde isi kacang hijau manis, digoreng dadakan dan renyah di luar.',
        'price': 15000,
        'imageUrl': 'assets/images/onde onde.jpeg', 
        'categoryId': 'Kue Basah',
        'tasteTag': 'Manis',
        'rating': 4.9,
        'reviewCount': 120,
        'sold': 350,
        'variants': ['3 Pcs', '5 Pcs', '10 Pcs'],
      },
      {
        'name': 'Lemper Ayam',
        'description': 'Ketan gurih dengan isian ayam suwir bumbu sedap, dibungkus daun pisang.',
        'price': 12000,
        'imageUrl': 'assets/images/lemper ayam.jpeg',
        'categoryId': 'Kue Basah',
        'tasteTag': 'Gurih',
        'rating': 4.8,
        'reviewCount': 85,
        'sold': 200,
        'variants': ['2 Pcs', '5 Pcs'],
      },
      {
        'name': 'Dadar Gulung',
        'description': 'Dadar gulung dengan unti kelapa manis, renyah dan nikmat.',
        'price': 10500,
        'imageUrl': 'assets/images/dadar_gulung.jpg',
        'categoryId': 'Kue Basah',
        'tasteTag': 'Gurih & Manis',
        'rating': 4.9,
        'reviewCount': 210,
        'sold': 500,
        'variants': ['3 Pcs', '5 Pcs'],
      },
      {
        'name': 'Klepon',
        'description': 'Kue beras kenyal isi gula merah cair, ditaburi kelapa parut segar.',
        'price': 10000,
        'imageUrl': 'assets/images/klepon.jpg',
        'categoryId': 'Kue Basah',
        'tasteTag': 'Manis',
        'rating': 4.7,
        'reviewCount': 90,
        'sold': 180,
        'variants': ['1 Kotak (5 Pcs)', '2 Kotak'],
      },
      {
        'name': 'Putu Ayu',
        'description': 'Kue kukus harum pandan dengan kelapa parut gurih.',
        'price': 11000,
        'imageUrl': 'assets/images/putu ayu.jpeg',
        'categoryId': 'Kue Basah',
        'tasteTag': 'Manis',
        'rating': 4.6,
        'reviewCount': 50,
        'sold': 100,
        'variants': ['3 Pcs', '5 Pcs'],
      },
      // --- KUE KERING ---
      {
        'name': 'Nastar Klasik',
        'description': 'Kue kering isi selai nanas asli yang manis dan lumer di mulut.',
        'price': 45000,
        'imageUrl': 'assets/images/nastar.jpeg',
        'categoryId': 'Kue Kering',
        'tasteTag': 'Manis',
        'rating': 4.9,
        'reviewCount': 320,
        'sold': 1200,
        'variants': ['Toples Kecil', 'Toples Besar'],
      },
      {
        'name': 'Kastengel Keju',
        'description': 'Kue kering renyah dengan taburan keju edam pilihan.',
        'price': 50000,
        'imageUrl': 'assets/images/kastengel.jpeg',
        'categoryId': 'Kue Kering',
        'tasteTag': 'Gurih',
        'rating': 4.8,
        'reviewCount': 280,
        'sold': 950,
        'variants': ['Toples Kecil', 'Toples Besar'],
      },
      {
        'name': 'Putri Salju',
        'description': 'Kue kering lembut bertabur gula halus yang dingin seperti salju.',
        'price': 42000,
        'imageUrl': 'assets/images/putri salju baru.jpeg',
        'categoryId': 'Kue Kering',
        'tasteTag': 'Manis',
        'rating': 4.7,
        'reviewCount': 190,
        'sold': 600,
        'variants': ['Toples Kecil', 'Toples Besar'],
      },
      {
        'name': 'Lidah Kucing',
        'description': 'Kue kering tipis renyah dengan rasa mentega premium.',
        'price': 40000,
        'imageUrl': 'assets/images/lidah kucing.jpeg',
        'categoryId': 'Kue Kering',
        'tasteTag': 'Manis',
        'rating': 4.6,
        'reviewCount': 150,
        'sold': 450,
        'variants': ['Toples Kecil', 'Toples Besar'],
      },
      // --- GORENGAN ---
      {
        'name': 'Risol Mayo',
        'description': 'Gorengan risol isi smoked beef, telur, dan mayo yang lumer.',
        'price': 20000,
        'imageUrl': 'assets/images/risol mayo.jpeg',
        'categoryId': 'Gorengan',
        'tasteTag': 'Gurih',
        'rating': 4.9,
        'reviewCount': 410,
        'sold': 1500,
        'variants': ['5 Pcs', '10 Pcs'],
      },
      {
        'name': 'Bakwan Jagung',
        'description': 'Gorengan jagung manis renyah di luar, empuk di dalam. Pas disajikan hangat.',
        'price': 10000,
        'imageUrl': 'assets/images/bakwan jagung.jpeg',
        'categoryId': 'Gorengan',
        'tasteTag': 'Gurih',
        'rating': 4.7,
        'reviewCount': 250,
        'sold': 800,
        'variants': ['5 Pcs', '10 Pcs'],
      },
      {
        'name': 'Tahu Isi Pedas',
        'description': 'Tahu goreng tepung berisi sayuran pedas nikmat.',
        'price': 12000,
        'imageUrl': 'assets/images/tahu isi.jpeg',
        'categoryId': 'Gorengan',
        'tasteTag': 'Pedas Gurih',
        'rating': 4.8,
        'reviewCount': 180,
        'sold': 600,
        'variants': ['5 Pcs', '10 Pcs'],
      },
      {
        'name': 'Pisang Goreng Madu',
        'description': 'Pisang manis legit berbalut adonan madu renyah.',
        'price': 15000,
        'imageUrl': 'assets/images/pisang goreng madu.jpeg',
        'categoryId': 'Gorengan',
        'tasteTag': 'Manis',
        'rating': 4.9,
        'reviewCount': 310,
        'sold': 900,
        'variants': ['3 Pcs', '5 Pcs'],
      }
    ];

    for (var product in dummyProducts) {
      await productsRef.add(product);
    }

    if (kDebugMode) {
      print("Seeding ulang data produk selesai!");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error saat seeding ulang: $e");
    }
  }
}
