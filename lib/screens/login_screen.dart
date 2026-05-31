import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password tidak boleh kosong'),
          backgroundColor: JamuTheme.dangerRedText,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.login(email, password);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: JamuTheme.dangerRedText,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController(text: _emailController.text);
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: JamuTheme.cardRadius),
              title: Text('Lupa Kata Sandi?', style: JamuTheme.titleMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan email akun Anda. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi.',
                    style: JamuTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: JamuTheme.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: JamuTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email tidak boleh kosong')),
                            );
                            return;
                          }

                          setState(() => isSending = true);
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final error = await authProvider.sendPasswordResetEmail(email);
                          
                          if (!ctx.mounted) return;
                          
                          if (error != null) {
                            setState(() => isSending = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error), backgroundColor: JamuTheme.dangerRedText),
                            );
                          } else {
                            Navigator.pop(ctx);
                            _showEmailSentSuccessDialog(context, email);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: JamuTheme.primaryGreen),
                  child: isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Email', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEmailSentSuccessDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: JamuTheme.cardRadius),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: JamuTheme.primaryGreen),
            SizedBox(width: 10),
            Text('Email Terkirim'),
          ],
        ),
        content: Text(
          'Tautan untuk mengatur ulang kata sandi telah dikirim ke:\n\n$email\n\nSilakan buka email Anda dan atur sandi baru, setelah itu login kembali menggunakan sandi baru tersebut.',
          style: JamuTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: JamuTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sandi berhasil diubah! Silakan login dengan sandi baru Anda.'),
                  backgroundColor: JamuTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: JamuTheme.primaryGreen),
            child: const Text('Saya Sudah Ganti Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JamuTheme.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: JamuTheme.borderLight, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Text
                  Text(
                    'Login Admin',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: JamuTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan masuk ke akun POS Jamu Anda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: JamuTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: JamuTheme.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.primaryGreen),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: JamuTheme.textSecondary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: JamuTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: JamuTheme.primaryGreen),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Lupa Kata Sandi
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.plusJakartaSans(
                          color: JamuTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JamuTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Masuk',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
