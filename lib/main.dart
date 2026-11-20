import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // otomatis dibuat oleh `flutterfire configure`
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/splash_screen.dart';

import 'seed_data.dart'; // [TAMBAHAN] untuk isi data awal

Future<void> main() async {
  // WAJIB dipanggil sebelum Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // [TAMBAHAN] Jalankan fungsi seeding tanpa memblokir aplikasi
  try {
    // Jalankan seeding di background agar tidak menahan runApp
    seedProducts().catchError((e) {
      debugPrint("Gagal seeding data: $e");
    });
  } catch (e) {
    debugPrint("Error saat memanggil seedProducts: $e");
  }

  runApp(const WarungJajanApp());
}

class WarungJajanApp extends StatelessWidget {
  const WarungJajanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Semua Provider didaftarkan di sini, supaya bisa diakses
      // dari screen manapun dengan: context.watch<AuthProvider>(), dst.
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Warung Jajan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
