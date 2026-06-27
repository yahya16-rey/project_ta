import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
          'Kebijakan Privasi',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip_outlined, size: 50, color: JamuTheme.primaryGreenLight),
            const SizedBox(height: 16),
            Text(
              'Kebijakan Privasi POS Jamu',
              style: JamuTheme.titleLarge.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Terakhir Diperbarui: 30 Mei 2026',
              style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textLight),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Informasi yang Kami Kumpulkan',
              'Kami mengumpulkan informasi transaksi penjualan POS Jamu seperti nama produk, jumlah barang, dan total nominal transaksi. Untuk sistem IoT, kami juga merekam data operasional suhu boiler secara real-time guna mendukung stabilitas kualitas jamu.',
            ),
            _buildSection(
              '2. Penggunaan Informasi',
              'Data yang dikumpulkan sepenuhnya digunakan untuk menyajikan data grafik omset bulanan, laporan analisis penjualan, dan pencatatan riwayat stabilitas suhu mesin produksi Anda agar dapat diakses dengan mudah oleh pemilik toko.',
            ),
            _buildSection(
              '3. Keamanan Data',
              'Keamanan informasi Anda adalah prioritas kami. Semua data transaksi dan sensor disimpan di server database Cloud Firestore dengan protokol enkripsi standar industri untuk mencegah akses yang tidak sah.',
            ),
            _buildSection(
              '4. Akses dan Hak Pengguna',
              'Anda sebagai administrator berhak mengubah informasi profil bisnis, memperbarui kata sandi secara berkala, dan menghapus riwayat log transaksi di dalam aplikasi sesuai kebutuhan operasional usaha.',
            ),
            _buildSection(
              '5. Perubahan Kebijakan',
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Perubahan akan diumumkan melalui pemberitahuan di dalam aplikasi atau pembaruan tanggal revisi di bagian atas halaman ini.',
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Hubungi kami di support@posjamu.com untuk pertanyaan lebih lanjut.',
                textAlign: TextAlign.center,
                style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textLight, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: JamuTheme.titleSmall.copyWith(fontSize: 15, color: JamuTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textSecondary, height: 1.5, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
