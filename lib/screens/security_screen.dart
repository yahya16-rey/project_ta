import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/auth_provider.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JamuTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: JamuTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Keamanan & Privasi',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security_rounded, size: 80, color: JamuTheme.primaryGreenLight),
            const SizedBox(height: 16),
            Text(
              'Pengaturan Akun Anda',
              style: JamuTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            _buildActionTile(
              context,
              Icons.lock_outline_rounded,
              'Ubah Kata Sandi',
              'Perbarui password akun Anda secara berkala',
              () {
                _showChangePasswordConfirmation(context);
              },
            ),
            _buildActionTile(
              context,
              Icons.policy_outlined,
              'Kebijakan Privasi',
              'Baca kebijakan penggunaan data aplikasi',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF1F2F6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: JamuTheme.textPrimary, size: 22),
        ),
        title: Text(title, style: JamuTheme.titleSmall.copyWith(fontSize: 15)),
        subtitle: Text(subtitle, style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: JamuTheme.textLight),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordConfirmation(BuildContext context) {
    bool isSending = false;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: JamuTheme.cardRadius),
              title: Text('Ubah Kata Sandi?', style: JamuTheme.titleMedium),
              content: Text(
                'Apakah Anda yakin ingin mengatur ulang kata sandi? Kami akan mengirimkan email berisikan tautan untuk membuat kata sandi baru Anda.',
                style: JamuTheme.bodyMedium,
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
                          setState(() => isSending = true);
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final email = authProvider.userEmail;
                          
                          if (email.isEmpty) {
                            setState(() => isSending = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email pengguna tidak ditemukan')),
                            );
                            return;
                          }

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
                      : const Text('Ya, Kirim Email', style: TextStyle(color: Colors.white)),
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
          'Tautan untuk mengatur ulang kata sandi telah dikirim ke:\n\n$email\n\nSilakan buka email Anda untuk mengatur kata sandi baru.',
          style: JamuTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: JamuTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(context); // Keluar dari Security Screen ke Dashboard/Profile
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout(); // Logout untuk kembali ke Login Screen
              
              // Tampilkan snackbar (akan muncul di atas screen baru jika diset floating dan global)
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sandi berhasil diubah! Silakan login dengan sandi baru Anda.'),
                    backgroundColor: JamuTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: JamuTheme.primaryGreen),
            child: const Text('Saya Sudah Ganti Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
