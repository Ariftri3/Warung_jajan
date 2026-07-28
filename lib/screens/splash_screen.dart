import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_theme.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart'; // akan dibuat di Langkah 6

/// Sesuai mockup: logo bulat, judul "Warung Jajan" (Playfair Display),
/// tagline "Cita Rasa Nusantara", loading bar, background cream.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Beri jeda 2.5 detik supaya animasi splash terlihat (sesuai mockup).
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.currentUser != null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground, // #FFF8E1 sesuai mockup
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo bulat dengan shadow lembut, sesuai mockup
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceContainer, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.bakery_dining_rounded,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Judul brand pakai Playfair Display, sesuai mockup
            Text('Warung Jajan', style: AppTheme.displayBrand),
            const SizedBox(height: 4),
            Text(
              'Cita Rasa Nusantara',
              style: AppTheme.bodyLg.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            // Loading bar sederhana
            SizedBox(
              width: 128,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  backgroundColor: AppColors.surfaceContainer,
                  valueColor: AlwaysStoppedAnimation(AppColors.primaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menyiapkan jajanan favorit Anda...',
              style: AppTheme.labelSm.copyWith(
                color: AppColors.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
