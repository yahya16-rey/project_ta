import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';
import 'add_product_screen.dart';
import 'transaction_history_screen.dart';
import 'monthly_revenue_graph_screen.dart';


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

  void _addToCart(JamuProvider provider, ProductMenu product, int qty) {
    provider.addToCart(product, qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ($qty) masuk keranjang!'),
        backgroundColor: JamuTheme.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Consumer<JamuProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 120.0),
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
            ),
            
            // Cart Floating Checkout Button
            if (provider.cartItems.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: JamuTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: JamuTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _showCartDetailBottomSheet(context, provider, currencyFormat);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.cartItems.length} Produk di Keranjang',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(provider.cartTotal).replaceAll(',', '.'),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _isSaving ? 'Menyimpan...' : 'Checkout',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!_isSaving)
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                                if (_isSaving)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
                  style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonthlyRevenueGraphScreen()),
              );
            },
            child: Container(
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
                      style: GoogleFonts.inter(
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
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: menu.imagePath.startsWith('assets/')
                                  ? Image.asset(
                                      menu.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported, color: Colors.grey),
                                    )
                                  : kIsWeb
                                      ? Image.network(
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
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                _showDeleteConfirmDialog(context, provider, menu);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              ),
                            ),
                          ),
                        ],
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
                              style: GoogleFonts.inter(
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
                            : kIsWeb
                                ? Image.network(
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
                              style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                        _addToCart(provider, menu, localQty);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JamuTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Tambahkan ke Keranjang',
                        style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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

  void _showCartDetailBottomSheet(BuildContext context, JamuProvider provider, NumberFormat currencyFormat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Keranjang Pesanan',
                    style: JamuTheme.titleMedium.copyWith(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.clearCart();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'KOSONGKAN',
                      style: GoogleFonts.inter(
                        color: JamuTheme.dangerRedText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: provider.cartItems.length,
                  separatorBuilder: (context, index) => const Divider(color: JamuTheme.borderLight),
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.product.name, style: JamuTheme.titleSmall.copyWith(fontSize: 14)),
                      subtitle: Text('${item.quantity} Botol', style: JamuTheme.bodyMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyFormat.format(item.totalAmount).replaceAll(',', '.'),
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: JamuTheme.dangerRedText, size: 20),
                            onPressed: () {
                              provider.removeFromCart(item.product);
                              if (provider.cartItems.isEmpty) {
                                Navigator.pop(ctx);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JamuTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JamuTheme.primaryGreenLight.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Checkout', style: JamuTheme.titleSmall),
                    Text(
                      currencyFormat.format(provider.cartTotal).replaceAll(',', '.'),
                      style: GoogleFonts.inter(
                        color: JamuTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: JamuTheme.textSecondary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Kembali',
                        style: GoogleFonts.inter(color: JamuTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        setState(() => _isSaving = true);
                        await provider.checkoutCart();
                        setState(() => _isSaving = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan Berhasil Disimpan!'),
                              backgroundColor: JamuTheme.primaryGreen,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: JamuTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Checkout Sekarang',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, JamuProvider provider, ProductMenu menu) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Produk?',
            style: JamuTheme.titleMedium,
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${menu.name} dari katalog? Tindakan ini tidak dapat dibatalkan.',
            style: JamuTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(color: JamuTheme.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteProduct(menu);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${menu.name} berhasil dihapus.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
