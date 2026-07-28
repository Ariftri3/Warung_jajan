import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart'; // dibuat di Langkah 6
import 'register_screen.dart';

/// Sesuai mockup Login Screen: icon toko, "Selamat Datang!", form email +
/// password, tombol "Masuk" hijau, divider "Atau masuk dengan", Google/Facebook,
/// footer "Belum punya akun? Daftar di sini".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground, // #FFF8E1 sesuai mockup
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==== Header / Identity ====
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.stitchingBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.storefront, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text('Selamat Datang!', style: AppTheme.headlineLgMobile.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(
                          'Masuk untuk menikmati jajanan favorit Anda di Warung Jajan.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMd,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ==== Form ====
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Email', style: AppTheme.labelLg),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'contoh@email.com',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email wajib diisi';
                            if (!value.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Kata Sandi', style: AppTheme.labelLg),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: implementasi lupa password (authProvider.resetPassword)
                            },
                            child: Text('Lupa Kata Sandi?', style: AppTheme.labelSm.copyWith(color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ==== Tombol Masuk ====
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Masuk'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ==== Divider ====
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.outlineVariant)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ATAU MASUK DENGAN', style: AppTheme.labelSm),
                      ),
                      const Expanded(child: Divider(color: AppColors.outlineVariant)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ==== Social Login (UI saja, logic bisa ditambah nanti) ====
                  Row(
                    children: [
                      Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata, onTap: () {})),
                      const SizedBox(width: 16),
                      Expanded(child: _SocialButton(label: 'Facebook', icon: Icons.facebook, onTap: () {})),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ==== Footer ====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun? ', style: AppTheme.bodyMd),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Daftar di sini',
                          style: AppTheme.labelLg.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.onSurface),
      label: Text(label, style: AppTheme.labelLg),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusDefault),
      ),
    );
  }
}
