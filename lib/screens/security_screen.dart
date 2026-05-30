import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
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
          style: GoogleFonts.outfit(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
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
}
