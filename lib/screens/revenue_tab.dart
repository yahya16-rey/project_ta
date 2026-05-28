import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';

class RevenueTab extends StatefulWidget {
  const RevenueTab({Key? key}) : super(key: key);

  @override
  State<RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<RevenueTab> {
  final _quantityController = TextEditingController(text: "0");
  String _selectedProduct = "Ekstrak Temulawak";
  bool _isSaving = false;

  // Jamu Product Catalog with prices and units
  final Map<String, Map<String, dynamic>> _catalog = {
    "Ekstrak Temulawak": {"price": 75000.0, "unit": "Botol"},
    "Jahe Merah Instan": {"price": 15000.0, "unit": "Sachet"},
    "Kunyit Asam": {"price": 20000.0, "unit": "Botol"},
    "Beras Kencur": {"price": 25000.0, "unit": "Botol"},
  };

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final qtyText = _quantityController.text;
    final qty = int.tryParse(qtyText) ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah barang yang valid (lebih dari 0)'),
          backgroundColor: JamuTheme.dangerRedText,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final productData = _catalog[_selectedProduct]!;
      final price = productData["price"] as double;
      final unit = productData["unit"] as String;
      final totalAmount = price * qty;

      final provider = Provider.of<JamuProvider>(context, listen: false);
      await provider.addPOSTransaction(_selectedProduct, qty, unit, totalAmount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi $_selectedProduct ($qty $unit) disimpan!'),
          backgroundColor: JamuTheme.primaryGreen,
        ),
      );

      _quantityController.text = "0";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan transaksi: $e'),
          backgroundColor: JamuTheme.dangerRedText,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Consumer<JamuProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                'Pencatatan Omset',
                style: JamuTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Lacak pendapatan harian dan efisiensi produksi Anda.',
                style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Total Revenue Card
              _buildTotalRevenueCard(provider, currencyFormat),
              const SizedBox(height: 24),

              // Input Transaksi Baru Card
              _buildInputTransactionCard(),
              const SizedBox(height: 24),

              // Transaksi Terbaru
              _buildRecentTransactionsSection(provider, currencyFormat),
              const SizedBox(height: 24),

              // Bottom Decorative Image
              _buildBottomBanner(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRevenueCard(JamuProvider provider, NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PENDAPATAN BULAN INI',
                  style: GoogleFonts.plusJakartaSans(
                    color: JamuTheme.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(provider.totalMonthlyRevenue).replaceAll(',', '.'),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: JamuTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: JamuTheme.primaryGreenLight,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${provider.revenuePercentageIncrease.toStringAsFixed(0)}% dari bulan lalu',
                      style: GoogleFonts.plusJakartaSans(
                        color: JamuTheme.primaryGreenLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Small bar chart graphic representation
          Container(
            width: 55,
            height: 45,
            decoration: BoxDecoration(
              color: JamuTheme.statusGreenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCardBar(12),
                _buildCardBar(22),
                _buildCardBar(35),
                _buildCardBar(28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBar(double height) {
    return Container(
      width: 6,
      height: height,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: JamuTheme.primaryGreen,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildInputTransactionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input Transaksi Baru',
            style: JamuTheme.titleSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Dropdown Pilih Produk
          Text(
            'Pilih Produk Jamu',
            style: GoogleFonts.plusJakartaSans(
              color: JamuTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: JamuTheme.borderLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: _selectedProduct,
                decoration: const InputDecoration(border: InputBorder.none),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: JamuTheme.textSecondary),
                items: _catalog.keys.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: JamuTheme.bodyLarge.copyWith(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedProduct = newValue!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Jumlah Barang Textfield
          Text(
            'Jumlah Barang',
            style: GoogleFonts.plusJakartaSans(
              color: JamuTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            style: JamuTheme.bodyLarge.copyWith(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JamuTheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JamuTheme.primaryGreen),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Simpan Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: JamuTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Simpan Transaksi',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(JamuProvider provider, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terbaru',
              style: JamuTheme.titleMedium.copyWith(fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'LIHAT SEMUA',
                style: GoogleFonts.plusJakartaSans(
                  color: JamuTheme.primaryGreenLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.recentTransactions.length > 3 ? 3 : provider.recentTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tx = provider.recentTransactions[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: JamuTheme.cardColor,
                borderRadius: JamuTheme.innerCardRadius,
                border: Border.all(color: JamuTheme.borderLight),
                boxShadow: JamuTheme.softShadow,
              ),
              child: Row(
                children: [
                  // Receipt icon container
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDFBF3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: JamuTheme.primaryGreenLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & Time/Qty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.product,
                          style: JamuTheme.titleSmall.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${tx.timestamp} • ${tx.quantity} ${tx.unit}',
                          style: JamuTheme.bodyMedium.copyWith(
                            color: JamuTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    currencyFormat.format(tx.amount).replaceAll(',', '.'),
                    style: GoogleFonts.outfit(
                      color: JamuTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: JamuTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Generated Image Asset
            Image.asset(
              'assets/images/jamu_jars.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback widget if asset hasn't compiled yet
                return Container(
                  color: JamuTheme.primaryGreen,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_outlined, color: Colors.white70, size: 40),
                );
              },
            ),
            // Soft Darkened Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
