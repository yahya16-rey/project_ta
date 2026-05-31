import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
          'Riwayat Transaksi POS',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer<JamuProvider>(
        builder: (context, provider, child) {
          if (provider.recentTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi tercatat.',
                    style: JamuTheme.bodyLarge.copyWith(color: JamuTheme.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.recentTransactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = provider.recentTransactions[index];
              return GestureDetector(
                onTap: () {
                  _showTransactionDetailDialog(context, tx, currencyFormat);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: JamuTheme.cardColor,
                    borderRadius: JamuTheme.innerCardRadius,
                    border: Border.all(color: JamuTheme.borderLight),
                    boxShadow: JamuTheme.softShadow,
                  ),
                  child: Row(
                    children: [
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
                              '${tx.timestamp} WIB • ${tx.quantity} ${tx.unit}',
                              style: JamuTheme.bodyMedium.copyWith(
                                color: JamuTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTransactionDetailDialog(BuildContext context, dynamic tx, NumberFormat currencyFormat) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: JamuTheme.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detail Transaksi',
                  style: JamuTheme.titleMedium.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waktu: ${tx.timestamp} WIB',
                style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                tx.product,
                style: JamuTheme.titleSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Jumlah: ${tx.quantity} ${tx.unit}',
                style: JamuTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${currencyFormat.format(tx.amount).replaceAll(',', '.')}',
                style: GoogleFonts.outfit(
                  color: JamuTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'TUTUP',
                style: GoogleFonts.plusJakartaSans(
                  color: JamuTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
