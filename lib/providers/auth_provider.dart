import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Dipasang di atas MaterialApp (lihat main.dart) supaya bisa diakses
/// dari screen mana saja lewat: context.watch<AuthProvider>() atau
/// context.read<AuthProvider>().
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapErrorMessage(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUp(name: name, email: email, password: password);
      errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapErrorMessage(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Pesan error dalam Bahasa Indonesia, biar user paham.
  String _mapErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email belum terdaftar.';
      case 'wrong-password':
        return 'Kata sandi salah.';
      case 'invalid-credential':
        return 'Email atau kata sandi salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter).';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'operation-not-allowed':
        return 'Metode login Email/Password belum diaktifkan di Firebase Console.';
      default:
        return 'Terjadi kesalahan ($code). Coba lagi.';
    }
  }
}
