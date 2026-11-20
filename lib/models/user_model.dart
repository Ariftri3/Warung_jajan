import 'package:cloud_firestore/cloud_firestore.dart';

/// Data tambahan user selain yang ada di Firebase Auth.
/// Disimpan di Firestore: users/{uid}
/// Dipakai di Checkout Screen (Alamat Pengiriman) & Profil Screen.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photoUrl;
  final String role; // 'customer' | 'admin'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
    this.role = 'customer',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
