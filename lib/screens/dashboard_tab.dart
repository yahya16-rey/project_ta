import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

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
              // Welcome Banner
              _buildWelcomeBanner(),
              const SizedBox(height: 20),

              // Temperature Card
              _buildTemperatureCard(context, provider),
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
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Halo, Pemilik\nJamu!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sistem produksi Anda berjalan optimal hari ini.',
                style: GoogleFonts.plusJakartaSans(
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

  Widget _buildTemperatureCard(BuildContext context, JamuProvider provider) {
    final temp = provider.boilerData.temperature;
    final status = provider.boilerData.status;

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
                  style: GoogleFonts.plusJakartaSans(
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
            style: GoogleFonts.outfit(
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
    final revenue = provider.totalMonthlyRevenue;

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
          // Top Row: Wallet Icon and DETAIL Action
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
                  // Handled in navigation shell
                },
                child: Text(
                  'DETAIL',
                  style: GoogleFonts.plusJakartaSans(
                    color: JamuTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Revenue Value
          Text(
            currencyFormat.format(revenue).replaceAll(',', '.'),
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: JamuTheme.textPrimary,
            ),
          ),
          Text(
            'Pendapatan Bulan Ini',
            style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
          ),
          const SizedBox(height: 24),

          // Mini bar chart
          _buildMiniBarChart(),
        ],
      ),
    );
  }

  Widget _buildMiniBarChart() {
    // Mimics the mockup: 5 vertical bars, with the 4th highlighted in deep green
    final heights = [10.0, 16.0, 24.0, 42.0, 20.0];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (index) {
        final isHighlighted = index == 3;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: heights[index],
            decoration: BoxDecoration(
              color: isHighlighted ? JamuTheme.primaryGreen : const Color(0xFFE2E4E8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentActivitiesSection(BuildContext context, JamuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Aktivitas Terkini',
                  style: JamuTheme.titleMedium.copyWith(fontSize: 20),
                ),
              ],
            ),
            const Icon(
              Icons.history_rounded,
              color: JamuTheme.textSecondary,
              size: 22,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.recentActivities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text('Tidak ada aktivitas')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.recentActivities.length > 3 ? 3 : provider.recentActivities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = provider.recentActivities[index];
              final isTemp = activity.type == 'temp';

              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: JamuTheme.cardColor,
                  borderRadius: JamuTheme.innerCardRadius,
                  border: Border.all(color: JamuTheme.borderLight),
                  boxShadow: JamuTheme.softShadow,
                ),
                child: Row(
                  children: [
                    // Left Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isTemp ? const Color(0xFFEDFBF3) : const Color(0xFFF1F2F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isTemp ? Icons.check_circle_outline_rounded : Icons.shopping_cart_outlined,
                        color: isTemp ? JamuTheme.statusGreenText : JamuTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: JamuTheme.titleSmall.copyWith(
                              color: JamuTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.description,
                            style: JamuTheme.bodyMedium.copyWith(
                              color: JamuTheme.textSecondary,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Time stamp
                    Text(
                      activity.timestamp,
                      style: JamuTheme.bodySmall.copyWith(
                        color: JamuTheme.textLight,
                        fontSize: 12,
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
