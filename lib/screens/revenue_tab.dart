import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';
import 'add_product_screen.dart';
import 'transaction_history_screen.dart';


class RevenueTab extends StatefulWidget {
  const RevenueTab({Key? key}) : super(key: key);

  @override
  State<RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<RevenueTab> {
  String? _selectedProduct;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "1");
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
    _qtyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransactionWithParams(JamuProvider provider, ProductMenu product, int qty) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final amount = product.price * qty;
      
      await provider.addPOSTransaction(product.name, qty, 'Botol', amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi ${product.name} ($qty Botol) disimpan!'),
          backgroundColor: JamuTheme.primaryGreen,
        ),
      );
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
              _buildInputTransactionCard(provider),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currencyFormat.format(provider.totalMonthlyRevenue).replaceAll(',', '.'),
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: JamuTheme.textPrimary,
                    ),
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

  Widget _buildInputTransactionCard(JamuProvider provider) {
    if (provider.catalogMenu.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Katalog Menu POS',
                style: JamuTheme.titleSmall.copyWith(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductScreen()),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: JamuTheme.primaryGreen, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah Produk',
                      style: GoogleFonts.plusJakartaSans(
                        color: JamuTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Adjust ratio for smaller screens to prevent overflow
            double aspectRatio = constraints.maxWidth < 360 ? 0.65 : 0.8;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio, 
              ),
          itemCount: provider.catalogMenu.length,
          itemBuilder: (context, index) {
            final menu = provider.catalogMenu[index];
            return GestureDetector(
              onTap: () => _showAddTransactionDialog(context, provider, menu),
              child: Container(
                decoration: BoxDecoration(
                  color: JamuTheme.cardColor,
                  borderRadius: JamuTheme.cardRadius,
                  border: Border.all(color: JamuTheme.borderLight),
                  boxShadow: JamuTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: menu.imagePath.startsWith('assets/')
                            ? Image.asset(
                                menu.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                              )
                            : Image.file(
                                File(menu.imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              menu.name,
                              style: JamuTheme.titleSmall.copyWith(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${menu.price.toInt()}',
                              style: GoogleFonts.outfit(
                                color: JamuTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context, JamuProvider provider, ProductMenu menu) {
    int localQty = 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: JamuTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: menu.imagePath.startsWith('assets/')
                            ? Image.asset(
                                menu.imagePath,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 80),
                              )
                            : Image.file(
                                File(menu.imagePath),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 80),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(menu.name, style: JamuTheme.titleSmall.copyWith(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${menu.price.toInt()}',
                              style: GoogleFonts.outfit(
                                color: JamuTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Pilih Jumlah',
                    style: GoogleFonts.plusJakartaSans(
                      color: JamuTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (localQty > 1) {
                            setModalState(() => localQty--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: JamuTheme.textSecondary, size: 32),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        localQty.toString(),
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: JamuTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () {
                          setModalState(() => localQty++);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: JamuTheme.primaryGreen, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveTransactionWithParams(provider, menu, localQty);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JamuTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Tambahkan Rp ${(menu.price * localQty).toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransactionHistoryScreen()),
                );
              },
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
