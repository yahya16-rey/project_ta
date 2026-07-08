import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int initialFilterIndex;

  const TransactionHistoryScreen({
    Key? key,
    this.initialFilterIndex = 0,
  }) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late int _selectedFilterIndex;
  final List<String> _filters = ['Harian', 'Mingguan', 'Bulanan', 'Tahunan', 'Semua'];
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
  }

  bool _isSameWeek(DateTime d1, DateTime d2) {
    final startOfWeek1 = d1.subtract(Duration(days: d1.weekday - 1));
    final startOfWeek2 = d2.subtract(Duration(days: d2.weekday - 1));
    return startOfWeek1.year == startOfWeek2.year && startOfWeek1.month == startOfWeek2.month && startOfWeek1.day == startOfWeek2.day;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isSameMonth(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }

  bool _isSameYear(DateTime d1, DateTime d2) {
    return d1.year == d2.year;
  }

  List<DocumentSnapshot> _filterTransactions(List<DocumentSnapshot> allDocs) {
    final now = DateTime.now();
    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime date;
      if (data['timestamp'] == null) {
        // Pending server sync, assume it just happened now
        date = now;
      } else {
        date = (data['timestamp'] as Timestamp).toDate();
      }

      switch (_selectedFilterIndex) {
        case 0: // Harian
          return _isSameDay(date, now);
        case 1: // Mingguan
          return _isSameMonth(date, now); // Ambil semua bulan ini untuk di-group per minggu
        case 2: // Bulanan
          return _isSameYear(date, now); // Ambil semua tahun ini untuk di-group
        case 3: // Tahunan
          return true; // Ambil semua untuk di-group
        case 4: // Semua
        default:
          return true;
      }
    }).toList();
  }

  DateTime _getDate(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (data['timestamp'] == null) {
      return DateTime.now();
    }
    return (data['timestamp'] as Timestamp).toDate();
  }

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
          'Riwayat Transaksi',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded, color: JamuTheme.primaryGreen),
            tooltip: 'Export PDF',
            onPressed: () => _exportToPdf(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? JamuTheme.primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? JamuTheme.primaryGreen : JamuTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      _filters[index],
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : JamuTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('transactions').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: JamuTheme.primaryGreen));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final filteredDocs = _filterTransactions(snapshot.data!.docs);

          if (filteredDocs.isEmpty) {
            return _buildEmptyState();
          }

          final listItems = [];
          if (_selectedFilterIndex == 1) { // Mingguan
             int maxWeeks = 4;
             for (int i = maxWeeks; i >= 1; i--) {
                listItems.add('Minggu $i');
                bool hasItem = false;
                for (var doc in filteredDocs) {
                   int day = _getDate(doc).day;
                   int weekNum = ((day - 1) ~/ 7) + 1;
                   if (weekNum > maxWeeks) weekNum = maxWeeks; // Clamp days 29+ into Week 4
                   if (weekNum == i) {
                      listItems.add(doc);
                      hasItem = true;
                   }
                }
                if (!hasItem) {
                   listItems.add('EMPTY_STATE');
                }
             }
          } else if (_selectedFilterIndex == 2) { // Bulanan
             final List<String> monthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
             for (int i = 12; i >= 1; i--) {
                listItems.add('${monthNames[i-1]} ${DateTime.now().year}');
                bool hasItem = false;
                for (var doc in filteredDocs) {
                   if (_getDate(doc).month == i) {
                      listItems.add(doc);
                      hasItem = true;
                   }
                }
                if (!hasItem) {
                   listItems.add('EMPTY_STATE');
                }
             }
          } else if (_selectedFilterIndex == 3) { // Tahunan
             int minYear = DateTime.now().year;
             int maxYear = DateTime.now().year;
             for (var doc in filteredDocs) {
                int y = _getDate(doc).year;
                if (y < minYear) minYear = y;
                if (y > maxYear) maxYear = y;
             }
             for (int y = maxYear; y >= minYear; y--) {
                listItems.add('Tahun $y');
                bool hasItem = false;
                for (var doc in filteredDocs) {
                   if (_getDate(doc).year == y) {
                      listItems.add(doc);
                      hasItem = true;
                   }
                }
                if (!hasItem) {
                   listItems.add('EMPTY_STATE');
                }
             }
          } else {
            listItems.addAll(filteredDocs);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              final item = listItems[index];
              if (item == 'EMPTY_STATE') {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Belum ada transaksi di periode ini.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                );
              } else if (item is String) {
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 16, bottom: 12),
                  child: Text(
                    item, 
                    style: GoogleFonts.inter(
                      color: JamuTheme.primaryGreen, 
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionCard(item as DocumentSnapshot),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final date = _getDate(doc);
    final timeStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
    final totalAmount = (data['amount'] ?? 0).toDouble();

    // Parse items array
    final itemsList = data['items'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> items = itemsList.map((e) => e as Map<String, dynamic>).toList();
    
    // Generate title (first product + others)
    String title = 'Transaksi';
    int totalItems = 0;
    if (items.isNotEmpty) {
      title = items[0]['nama_produk'] ?? 'Produk';
      if (items.length > 1) {
        title += ' (+${items.length - 1} lainnya)';
      }
      for (var item in items) {
        totalItems += (item['jumlah'] as num?)?.toInt() ?? 0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.innerCardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: JamuTheme.innerCardRadius,
          onTap: () {
            _showTransactionDetailDialog(context, timeStr, items, totalAmount);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        title,
                        style: JamuTheme.titleSmall.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$timeStr WIB • $totalItems item',
                        style: JamuTheme.bodyMedium.copyWith(
                          color: JamuTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(totalAmount).replaceAll(',', '.'),
                  style: GoogleFonts.inter(
                    color: JamuTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi di periode ini.',
            style: JamuTheme.bodyLarge.copyWith(color: JamuTheme.textLight),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetailDialog(BuildContext context, String timeStr, List<Map<String, dynamic>> items, double totalAmount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: JamuTheme.statusGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: JamuTheme.statusGreenText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Transaksi',
                          style: JamuTheme.titleMedium.copyWith(fontSize: 18),
                        ),
                        Text(
                          'Waktu: $timeStr WIB',
                          style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final name = item['nama_produk'] ?? '';
                    final qty = item['jumlah'] ?? 0;
                    final price = item['harga'] ?? 0;
                    final subtotal = qty * price;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: JamuTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${qty}x',
                            style: GoogleFonts.inter(
                              color: JamuTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: JamuTheme.titleSmall.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@ ${currencyFormat.format(price).replaceAll(',', '.')}',
                                style: JamuTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(subtotal).replaceAll(',', '.'),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: JamuTheme.textPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JamuTheme.lightMintBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Belanja',
                      style: JamuTheme.titleSmall.copyWith(color: JamuTheme.primaryGreen),
                    ),
                    Text(
                      currencyFormat.format(totalAmount).replaceAll(',', '.'),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JamuTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JamuTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'TUTUP',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportToPdf(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyiapkan dokumen PDF...'), duration: Duration(seconds: 2)),
      );

      final snapshot = await FirebaseFirestore.instance.collection('transactions').orderBy('timestamp', descending: true).get();
      final filteredDocs = _filterTransactions(snapshot.docs);

      if (filteredDocs.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada transaksi untuk diekspor.')),
        );
        return;
      }

      final pdf = pw.Document();
      
      final String filterName = _filters[_selectedFilterIndex];
      final String reportDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());
      
      double totalPendapatan = 0;
      for (var doc in filteredDocs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPendapatan += (data['amount'] ?? 0).toDouble();
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laporan Transaksi', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Jamu Herbal', style: const pw.TextStyle(fontSize: 16, color: PdfColors.green700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Periode: $filterName', style: const pw.TextStyle(fontSize: 14)),
              pw.Text('Dicetak pada: $reportDate', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 20),
              
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  <String>['No', 'Tanggal', 'Item', 'Total (Rp)'],
                  ...List.generate(filteredDocs.length, (index) {
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final date = _getDate(filteredDocs[index]);
                    final timeStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
                    final totalAmount = (data['amount'] ?? 0).toDouble();
                    
                    final itemsList = data['items'] as List<dynamic>? ?? [];
                    final List<Map<String, dynamic>> items = itemsList.map((e) => e as Map<String, dynamic>).toList();
                    String itemString = items.map((e) => "${e['nama_produk']} x${e['jumlah']}").join(", ");

                    return [
                      (index + 1).toString(),
                      timeStr,
                      itemString,
                      currencyFormat.format(totalAmount).replaceAll('Rp ', '').replaceAll(',', '.')
                    ];
                  }),
                ],
              ),
              
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Total Pendapatan: ${currencyFormat.format(totalPendapatan).replaceAll(',', '.')}',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green700),
                  ),
                ]
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Laporan_Transaksi_${filterName}_$reportDate.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor PDF: $e')),
      );
    }
  }
}
