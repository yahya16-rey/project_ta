import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class StoreInfoScreen extends StatelessWidget {
  const StoreInfoScreen({Key? key}) : super(key: key);

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
          'Informasi Toko',
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
            const Icon(Icons.storefront_rounded, size: 80, color: JamuTheme.primaryGreenLight),
            const SizedBox(height: 16),
            Text(
              'Detail Bisnis POS Jamu',
              style: JamuTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            _buildInfoTile('Nama Toko', 'POS Jamu Utama'),
            _buildInfoTile('Alamat Toko', 'Jl. Merdeka No. 45, Jakarta Selatan'),
            _buildInfoTile('Jam Operasional', '08:00 - 20:00 WIB (Senin - Sabtu)'),
            _buildInfoTile('Nomor Izin Usaha', 'NIB-1234567890'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: JamuTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JamuTheme.borderLight),
            ),
            child: Text(
              value,
              style: JamuTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
