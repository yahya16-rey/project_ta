import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  // Profile data
  String _userName = "Admin POS Jamu";
  String _userEmail = "admin@posjamu.com";
  String _userPhone = "081234567890";
  String _userPhotoPath = "assets/images/logo.png"; // Default

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userPhotoPath => _userPhotoPath;

  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      _isLoading = false;
      notifyListeners();
      return null; // Null means success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'user-not-found') {
        return 'Email tidak terdaftar.';
      } else if (e.code == 'wrong-password') {
        return 'Password salah.';
      }
      return 'Gagal login: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  void updateProfile({required String name, required String email, required String phone, String? photoPath}) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    if (photoPath != null) {
      _userPhotoPath = photoPath;
    }
    notifyListeners();
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        // Re-autentikasi pengguna
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPassword);
      } else {
        // Mode simulasi/offline
        await Future.delayed(const Duration(milliseconds: 800));
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'wrong-password') {
        return 'Kata sandi saat ini salah.';
      } else if (e.code == 'weak-password') {
        return 'Kata sandi baru terlalu lemah.';
      }
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan: $e';
    }
  }
}

