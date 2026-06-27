import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';
import 'activity_history_screen.dart';
import 'transaction_history_screen.dart';
import 'monthly_revenue_graph_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Consumer<JamuProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF114D32)),
            ),
          );
        }
            return SingleChildScrollView(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 90.0 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Banner
                  _buildWelcomeBanner(),
                  const SizedBox(height: 20),

                  // Temperature Card
                  _buildTemperatureCard(context, provider, provider.boilerData),
                  const SizedBox(height: 16),

                  // Revenue Card
                  _buildRevenueCard(context, provider, currencyFormat),
                  const SizedBox(height: 24),

                  // Recent Activities Section
                  _buildRecentActivitiesSection(context, provider),
                ],
              ),
            );
          },
        );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF042617), Color(0xFF0A442A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Stack(
        children: [
          // Background subtle leaf design using custom shape or icons
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.eco_rounded,
              size: 130,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELAMAT DATANG',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Halo, POS Jamu!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sistem produksi Anda berjalan optimal hari ini.',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureCard(BuildContext context, JamuProvider provider, BoilerData boilerData) {
    final temp = boilerData.temperature;
    final status = boilerData.status;

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
          // Top Row: Icon and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDFBF3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.thermostat_rounded,
                  color: Color(0xFF5CAE93),
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: JamuTheme.lightMintBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: JamuTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle row: Temp value
          Text(
            '${temp.toStringAsFixed(1)}°C',
            style: GoogleFonts.inter(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: JamuTheme.textPrimary,
            ),
          ),
          Text(
            'Monitoring Real-time',
            style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
          ),
          const SizedBox(height: 20),

          // Bottom Sparkline Graph
          SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(
                readings: provider.tempHistory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(BuildContext context, JamuProvider provider, NumberFormat currencyFormat) {
    return RevenueCarousel(provider: provider, currencyFormat: currencyFormat);
  }

  Widget _buildRecentActivitiesSection(BuildContext context, JamuProvider provider) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terkini',
              style: JamuTheme.titleMedium.copyWith(fontSize: 20),
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
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            if (provider.recentTransactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "Belum ada data",
                    style: TextStyle(fontSize: 14, color: JamuTheme.textSecondary),
                  ),
                ),
              );
            }

            final txs = provider.recentTransactions.take(3).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = txs[index];
                final items = tx.items ?? [];
                final double amount = tx.amount;
                final String timeStr = tx.timestamp;

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
                        final formattedProducts = '${items.length} Product\n' + items.map((e) {
                          final nama = e.name;
                          final qty = e.quantity;
                          final harga = e.price;
                          final total = qty * harga;
                          return '$qty $nama Rp ${currencyFormat.format(total).replaceAll('Rp ', '').replaceAll(',', '.')}';
                        }).join('\n');
                        
                        final activity = ActivityLog(
                          id: tx.id,
                          type: 'transaction',
                          title: 'Transaksi Checkout',
                          description: '$formattedProducts\nTotal Rp ${currencyFormat.format(amount).replaceAll('Rp ', '').replaceAll(',', '.')}',
                          timestamp: timeStr,
                        );
                        _showActivityDetailDialog(context, activity);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        // Left Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F2F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: JamuTheme.textSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Loop items array to display detail text nama produk & jumlah
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaksi Checkout',
                                style: JamuTheme.titleSmall.copyWith(
                                  color: JamuTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: items.map<Widget>((item) {
                                  final namaProduk = item.name;
                                  final jumlah = item.quantity;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(
                                      '${jumlah}x $namaProduk',
                                      style: JamuTheme.bodyMedium.copyWith(
                                        color: JamuTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // Time stamp & Total Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              timeStr,
                              style: JamuTheme.bodySmall.copyWith(
                                color: JamuTheme.textLight,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currencyFormat.format(amount).replaceAll(',', '.'),
                              style: GoogleFonts.inter(
                                color: JamuTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

  void _showActivityDetailDialog(BuildContext context, ActivityLog activity) {
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
                    decoration: BoxDecoration(
                      color: activity.type == 'temp' ? JamuTheme.warningOrangeBg : JamuTheme.statusGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      activity.type == 'temp' ? Icons.thermostat_rounded : Icons.shopping_cart_rounded,
                      color: activity.type == 'temp' ? JamuTheme.warningOrangeText : JamuTheme.statusGreenText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Aktivitas',
                          style: JamuTheme.titleMedium.copyWith(fontSize: 18),
                        ),
                        Text(
                          'Waktu: ${activity.timestamp}',
                          style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                activity.title,
                style: JamuTheme.titleSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JamuTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: JamuTheme.borderLight),
                ),
                child: Text(
                  activity.description,
                  style: JamuTheme.bodyMedium.copyWith(height: 1.5),
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
}

// Custom Painter to draw the smooth wavy sparkline
class SparklinePainter extends CustomPainter {
  final List<TemperatureReading> readings;

  SparklinePainter({required this.readings});

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;

    final paint = Paint()
      ..color = JamuTheme.primaryGreenLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // We reverse the list for plotting so older items are on the left, newest on the right
    final reversedList = readings.reversed.toList();
    final int pointsCount = reversedList.length;

    // Find min and max temperature values to scale nicely
    double minTemp = reversedList.map((e) => e.temperature).reduce(min);
    double maxTemp = reversedList.map((e) => e.temperature).reduce(max);
    
    // Avoid division by zero
    if (maxTemp == minTemp) {
      minTemp -= 1.0;
      maxTemp += 1.0;
    }

    final double widthSegment = size.width / (pointsCount - 1);
    final double heightRange = maxTemp - minTemp;

    // Start coordinate
    double getX(int index) => index * widthSegment;
    double getY(int index) {
      double pct = (reversedList[index].temperature - minTemp) / heightRange;
      // Invert Y because canvas draws 0 at top
      return size.height - (pct * (size.height - 10) + 5);
    }

    path.moveTo(getX(0), getY(0));

    // Draw smooth curved lines using Bezier curves
    for (int i = 0; i < pointsCount - 1; i++) {
      double x1 = getX(i);
      double y1 = getY(i);
      double x2 = getX(i + 1);
      double y2 = getY(i + 1);

      double cx1 = x1 + (x2 - x1) / 2.0;
      double cy1 = y1;
      double cx2 = x1 + (x2 - x1) / 2.0;
      double cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RevenueCarousel extends StatefulWidget {
  final JamuProvider provider;
  final NumberFormat currencyFormat;

  const RevenueCarousel({Key? key, required this.provider, required this.currencyFormat}) : super(key: key);

  @override
  State<RevenueCarousel> createState() => _RevenueCarouselState();
}

class _RevenueCarouselState extends State<RevenueCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final monthName = months[now.month - 1];
    
    final todayStr = '${now.day} $monthName ${now.year}';
    final monthStr = '$monthName ${now.year}';
    final yearStr = '${now.year}';

    final tabs = ['Hari Ini', 'Bulan Ini', 'Tahun Ini'];
    final amounts = [
      widget.provider.totalDailyRevenue,
      widget.provider.totalMonthlyRevenue,
      widget.provider.totalYearlyRevenue,
    ];
    final dates = [todayStr, monthStr, yearStr];
    // Map indices to the filter index in TransactionHistoryScreen (0: Hari, 1: Bulan, 2: Tahun)
    final filterIndices = [0, 1, 2];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F2F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: JamuTheme.textSecondary,
                            size: 24,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionHistoryScreen(
                                  initialFilterIndex: filterIndices[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: JamuTheme.primaryGreenLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'DETAIL',
                              style: GoogleFonts.inter(
                                color: JamuTheme.primaryGreenDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.currencyFormat.format(amounts[index]).replaceAll(',', '.'),
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: JamuTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'Pendapatan ${tabs[index]}',
                      style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
                    ),
                    Text(
                      dates[index],
                      style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index ? JamuTheme.primaryGreen : JamuTheme.borderLight,
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
      ],
    );
  }
}
