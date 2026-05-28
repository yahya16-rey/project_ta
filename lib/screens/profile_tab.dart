import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<JamuProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // 1. Profile Picture with Edit Pencil Overlay
              _buildProfileHeader(),
              const SizedBox(height: 16),

              // Name & Contact Info
              Text(
                'Pemilik UMKM Jamu',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: JamuTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'umkm.jamu@email.com',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: JamuTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Premium Member badge
              _buildPremiumBadge(),
              const SizedBox(height: 28),

              // 2. Settings Menu Items
              _buildMenuItem(
                icon: Icons.storefront_outlined,
                title: "Informasi Toko",
                subtitle: "Detail operasional & alamat",
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: JamuTheme.textLight),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              
              _buildMenuItem(
                icon: Icons.sensors_rounded,
                title: "Hubungkan Alat IoT",
                subtitle: provider.isIotConnected ? "Arduino Uno connected" : "Disambungkan...",
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.isIotConnected)
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: JamuTheme.textLight),
                  ],
                ),
                onTap: () {},
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: "Bantuan & Dukungan",
                subtitle: "FAQ & hubungi admin",
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: JamuTheme.textLight),
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // 3. Dual Statistics Panel (Today's Transactions & Stock levels)
              _buildStatsGrid(provider),
              const SizedBox(height: 28),

              // 4. Log out action button
              _buildLogoutButton(context),
              const SizedBox(height: 24),

              // Version display label
              Text(
                'Versi Aplikasi 2.4.0-stable',
                style: JamuTheme.caption.copyWith(color: JamuTheme.textLight, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F5A41), // Deep green background fallback
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/owner_profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: Colors.white70,
                    );
                  },
                ),
              ),
            ),
          ),
          // Green edit pen overlay badge
          Positioned(
            bottom: 4,
            right: 4,
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
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: JamuTheme.lightMintBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 6,
            color: JamuTheme.primaryGreenLight,
          ),
          const SizedBox(width: 6),
          Text(
            'Premium Member',
            style: GoogleFonts.plusJakartaSans(
              color: JamuTheme.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.2,
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
                    color: JamuTheme.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Text labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: JamuTheme.titleSmall.copyWith(
                          color: JamuTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: JamuTheme.bodyMedium.copyWith(
                          color: JamuTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing item
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(JamuProvider provider) {
    return Row(
      children: [
        // Left Box: Transactions Today
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF133F2E), // Darker Forest Green
              borderRadius: JamuTheme.cardRadius,
              boxShadow: JamuTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSAKSI HARI INI',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${provider.transactionsCountToday}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Right Box: Herbal Stock percentage
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: JamuTheme.accentGreen, // Mint green background
              borderRadius: JamuTheme.cardRadius,
              boxShadow: JamuTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOK HERBAL',
                  style: GoogleFonts.plusJakartaSans(
                    color: JamuTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${provider.stockLevel.toStringAsFixed(0)}%',
                  style: GoogleFonts.outfit(
                    color: JamuTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar Akun'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun Jamu Herbal?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Keluar berhasil')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: JamuTheme.dangerRedText),
                child: const Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFFFDE8E8), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFFFF8F8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, color: JamuTheme.dangerRedText, size: 20),
          const SizedBox(width: 10),
          Text(
            'Keluar Akun',
            style: GoogleFonts.plusJakartaSans(
              color: JamuTheme.dangerRedText,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
