import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../models/jamu_models.dart';
import 'temperature_history_screen.dart';


class MonitorTab extends StatelessWidget {
  const MonitorTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<JamuProvider>(
      builder: (context, provider, child) {
        final temp = provider.boilerData.temperature;
        final status = provider.boilerData.status;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Monitoring
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring Suhu',
                      style: JamuTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau kondisi mesin boiler Anda secara real-time.',
                      style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // 1. Large Circular Ring Gauge
              Center(
                child: _buildCircularGauge(temp, status),
              ),
              const SizedBox(height: 24),

              // 2. TARGET & LAST UPDATED Sub-Cards (Side-by-side)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.thermostat_rounded,
                      title: "TARGET",
                      value: "${provider.targetTemperature.toStringAsFixed(1)}°C",
                      iconColor: const Color(0xFF0F5A41),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.history_toggle_off_rounded,
                      title: "LAST UPDATED",
                      value: provider.lastUpdatedTime,
                      iconColor: const Color(0xFF0F5A41),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 3. Mesin Control Switch
              _buildMotorControlCard(provider),
              const SizedBox(height: 24),

              // 4. Fluctuation Trend Card
              _buildTrendCard(provider),
              const SizedBox(height: 24),

              // 4. Riwayat Update List
              _buildUpdateHistory(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularGauge(double temp, String status) {
    return Container(
      width: 210,
      height: 210,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring Track (White shadow card background)
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  spreadRadius: 4,
                )
              ],
            ),
          ),
          // Circular Arc Painter
          CustomPaint(
            size: const Size(200, 200),
            painter: GaugeRingPainter(
              progress: (temp - 25.0) / 15.0, // Scale temperature e.g., from 25 to 40
              color: JamuTheme.primaryGreen,
              trackColor: const Color(0xFFE8ECEF),
            ),
          ),
          // Center Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SUHU SAAT INI',
                style: GoogleFonts.inter(
                  color: JamuTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${temp.toStringAsFixed(1)}°C',
                style: GoogleFonts.inter(
                  color: JamuTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 44,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: JamuTheme.statusGreenBg,
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
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: JamuTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: JamuTheme.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: JamuTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorControlCard(JamuProvider provider) {
    bool isMotorOn = provider.boilerData.status != 'OFF';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMotorOn ? JamuTheme.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: isMotorOn ? JamuTheme.primaryGreen : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesin Pengaduk',
                    style: JamuTheme.titleMedium.copyWith(fontSize: 16),
                  ),
                  Text(
                    isMotorOn ? 'Motor Sedang Berjalan' : 'Motor Mati',
                    style: JamuTheme.bodySmall.copyWith(
                      color: isMotorOn ? JamuTheme.primaryGreen : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isMotorOn,
            activeColor: JamuTheme.primaryGreen,
            onChanged: (value) {
              provider.toggleMotor(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(JamuProvider provider) {
    // Generate graph spots
    final spots = <FlSpot>[];
    if (provider.tempHistory.isEmpty) {
      // fallback dummy points if history is loading
      spots.addAll([
        const FlSpot(0, 30.5),
        const FlSpot(1, 31.8),
        const FlSpot(2, 32.2),
        const FlSpot(3, 32.4),
        const FlSpot(4, 32.6),
      ]);
    } else {
      final list = provider.tempHistory.reversed.toList();
      for (int i = 0; i < list.length; i++) {
        spots.add(FlSpot(i.toDouble(), list[i].temperature));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JamuTheme.cardColor,
        borderRadius: JamuTheme.cardRadius,
        border: Border.all(color: JamuTheme.borderLight),
        boxShadow: JamuTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fluctuation Trend',
                    style: JamuTheme.titleSmall.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Last 24 Hours',
                    style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textLight),
                  ),
                ],
              ),
              Text(
                '+0.2°C High',
                style: GoogleFonts.inter(
                  color: JamuTheme.primaryGreenLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Line Chart View
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: JamuTheme.borderLight,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: spots.length > 2 ? (spots.length / 2).floorToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        int val = value.toInt();
                        if (val == 0) {
                          text = '00:00';
                        } else if (val == (spots.length / 2).floor()) {
                          text = '12:00';
                        } else if (val == spots.length - 1) {
                          text = 'NOW';
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            text,
                            style: GoogleFonts.inter(
                              color: JamuTheme.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: JamuTheme.primaryGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          JamuTheme.primaryGreen.withOpacity(0.2),
                          JamuTheme.primaryGreen.withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                showingTooltipIndicators: [
                  // Show the highest peak indicator automatically
                  ShowingTooltipIndicators([
                    LineBarSpot(
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: JamuTheme.primaryGreen,
                      ),
                      0,
                      spots[_findPeakIndex(spots)],
                    ),
                  ]),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: JamuTheme.primaryGreenDark,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((barSpot) {
                        return LineTooltipItem(
                          'Peak ${barSpot.y.toStringAsFixed(1)}°',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _findPeakIndex(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    int peakIdx = 0;
    double maxVal = spots[0].y;
    for (int i = 1; i < spots.length; i++) {
      if (spots[i].y > maxVal) {
        maxVal = spots[i].y;
        peakIdx = i;
      }
    }
    return peakIdx;
  }

  Widget _buildUpdateHistory(BuildContext context, JamuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Update',
              style: JamuTheme.titleMedium.copyWith(fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TemperatureHistoryScreen()),
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
          itemCount: provider.tempHistory.length > 5 ? 5 : provider.tempHistory.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reading = provider.tempHistory[index];
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
                  // Refresh circle icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDFBF3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cached_rounded,
                      color: JamuTheme.primaryGreenLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Time and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reading.time,
                          style: JamuTheme.titleSmall.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          reading.status,
                          style: JamuTheme.bodyMedium.copyWith(
                            color: JamuTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperature value
                  Text(
                    '${reading.temperature.toStringAsFixed(1)}°C',
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
}

// Custom Painter to draw the gauge ring
class GaugeRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  GaugeRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 12.0;
    
    // Background track arc
    final paintTrack = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Active progress arc
    final paintProgress = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - (strokeWidth / 2) - 8;

    // Standard starting at bottom-left, sweeping to bottom-right
    final double startAngle = 135 * (pi / 180);
    final double sweepAngle = 270 * (pi / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paintTrack,
    );

    // Limit progress between 0.0 and 1.0
    final activeSweep = sweepAngle * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
