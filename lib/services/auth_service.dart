import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Satu-satunya file yang boleh memanggil FirebaseAuth langsung.
/// Dipakai oleh AuthProvider — bukan oleh screen secara langsung.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream ini dipakai Splash Screen untuk cek: sudah login atau belum.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Dipakai Login Screen (mockup: form email + password + tombol "Masuk").
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Dipakai Register Screen. Setelah akun Auth dibuat, langsung simpan
  /// data tambahan (nama, dll) ke Firestore users/{uid}.
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'phone': '',
      'address': '',
    });

    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
