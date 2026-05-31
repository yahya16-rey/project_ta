import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
    _loadLocalProfile();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? _userName;
    _userEmail = prefs.getString('userEmail') ?? _userEmail;
    _userPhone = prefs.getString('userPhone') ?? _userPhone;
    _userPhotoPath = prefs.getString('userPhotoPath') ?? _userPhotoPath;
    notifyListeners();
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

  Future<void> updateProfile({required String name, required String email, required String phone, String? photoPath}) async {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;

    final prefs = await SharedPreferences.getInstance();

    if (photoPath != null) {
      if (!photoPath.startsWith('assets/')) {
        // Copy image to permanent app directory
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = path.basename(photoPath);
          final savedImage = await File(photoPath).copy('${directory.path}/$fileName');
          _userPhotoPath = savedImage.path;
        } catch (e) {
          debugPrint('Failed to save profile image: $e');
          _userPhotoPath = photoPath;
        }
      } else {
        _userPhotoPath = photoPath;
      }
    }
    
    prefs.setString('userName', _userName);
    prefs.setString('userEmail', _userEmail);
    prefs.setString('userPhone', _userPhone);
    prefs.setString('userPhotoPath', _userPhotoPath);

    notifyListeners();
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        // Re-autentikasi pengguna ke Firebase
        // Menggunakan signInWithEmailAndPassword sebagai workaround untuk bug PigeonUserDetails pada reauthenticateWithCredential
        await _auth.signInWithEmailAndPassword(
          email: currentUser.email!,
          password: currentPassword,
        ).timeout(const Duration(seconds: 10));
        
        // Update password di Firebase Auth
        await currentUser.updatePassword(newPassword).timeout(const Duration(seconds: 10));
      } else {
        // Mode simulasi/offline
        final prefs = await SharedPreferences.getInstance();
        final storedPassword = prefs.getString('mockPassword');
        if (storedPassword != null && storedPassword != currentPassword) {
            _isLoading = false;
            notifyListeners();
            return 'Kata sandi saat ini salah.';
        }
        prefs.setString('mockPassword', newPassword);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      // Firebase kadang menggunakan 'invalid-credential' untuk password salah
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Kata sandi saat ini salah.';
      } else if (e.code == 'weak-password') {
        return 'Kata sandi baru terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'requires-recent-login') {
        return 'Sesi Anda telah kedaluwarsa. Silakan login kembali sebelum mengubah kata sandi.';
      }
      return 'Gagal memperbarui: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem: $e';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Gagal mengirim email reset: ${e.message}';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem: $e';
    }
  }
}

