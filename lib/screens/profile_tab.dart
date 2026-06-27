import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../theme/theme.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'store_info_screen.dart';
import 'security_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // 1. Profile Picture with Edit Pencil Overlay
              _buildProfileHeader(context, authProvider),
              const SizedBox(height: 20),

              // Name & Contact Info
              Text(
                authProvider.userName,
                style: GoogleFonts.inter(
                  color: JamuTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${authProvider.userEmail} • ${authProvider.userPhone}',
                style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              // 2. Settings Menu List
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                title: 'Informasi Toko',
                subtitle: 'Atur detail bisnis Anda',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: JamuTheme.textLight),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StoreInfoScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.security_rounded,
                title: 'Keamanan & Privasi',
                subtitle: 'Ganti password dan pengaturan akun',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: JamuTheme.textLight),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecurityScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: JamuTheme.dangerRedText, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: JamuTheme.cardRadius,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: JamuTheme.dangerRedText, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Keluar Akun',
                        style: GoogleFonts.inter(
                          color: JamuTheme.dangerRedText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // App Version
              Text(
                'Versi Aplikasi 2.4.0-stable',
                style: JamuTheme.caption.copyWith(color: JamuTheme.textLight, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Text(
                '© POS Jamu x Universitas Harkat Negeri',
                style: GoogleFonts.inter(
                  color: JamuTheme.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Stack(
        children: [
          // Owner avatar photo container
          Container(
            padding: const EdgeInsets.all(4), // White border spacing
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F5A41), // Deep green background fallback
                image: DecorationImage(
                  image: authProvider.userPhotoPath.startsWith('assets/')
                      ? AssetImage(authProvider.userPhotoPath) as ImageProvider
                      : FileImage(File(authProvider.userPhotoPath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Green edit pen overlay badge
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF063A24), // Deep green matching brand
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: JamuTheme.cardRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Left Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F2F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: JamuTheme.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: JamuTheme.titleSmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
                      ),
                    ],
                  ),
                ),
                
                // Trailing
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: JamuTheme.cardRadius),
        title: Text('Konfirmasi Keluar', style: JamuTheme.titleMedium),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sesi aplikasi saat ini?',
          style: JamuTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Berhasil keluar akun')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: JamuTheme.dangerRedText),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
