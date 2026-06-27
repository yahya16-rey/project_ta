import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/jamu_provider.dart';
import '../theme/theme.dart';

class MonthlyRevenueGraphScreen extends StatefulWidget {
  const MonthlyRevenueGraphScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyRevenueGraphScreen> createState() => _MonthlyRevenueGraphScreenState();
}

class _MonthlyRevenueGraphScreenState extends State<MonthlyRevenueGraphScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  int _findPeakIndex(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    int peakIndex = 0;
    double maxVal = spots[0].y;
    for (int i = 1; i < spots.length; i++) {
      if (spots[i].y > maxVal) {
        maxVal = spots[i].y;
        peakIndex = i;
      }
    }
    return peakIndex;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JamuProvider>(context);

    // Get current month name
    final now = DateTime.now();
    final List<String> months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final currentMonth = '${months[now.month - 1]} ${now.year}';

    // Prepare chart data
    final spots = <FlSpot>[];
    final monthlyData = provider.monthlyDailyRevenue;
    
    if (monthlyData.isEmpty) {
      // Dummy spots to prevent empty chart error if not synced yet
      spots.add(const FlSpot(0, 0));
    } else {
      for (int i = 0; i < monthlyData.length; i++) {
        // Only show up to today if we want, or show whole month
        // Let's show up to the current day for better visual
        if (i < now.day) {
          spots.add(FlSpot(i.toDouble(), monthlyData[i]));
        }
      }
      if (spots.isEmpty) spots.add(const FlSpot(0, 0));
    }

    final double highestRevenue = spots.isNotEmpty ? spots[_findPeakIndex(spots)].y : 0;

    return Scaffold(
      backgroundColor: JamuTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Grafik Pendapatan',
          style: GoogleFonts.inter(
            color: JamuTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: JamuTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: JamuTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perkembangan Harian',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: JamuTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bulan $currentMonth',
              style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
            ),
            const SizedBox(height: 40),
            
            // Trend Card Wrapper (Similar to Monitor Tab)
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trend Fluktuasi',
                            style: JamuTheme.titleSmall.copyWith(fontSize: 16),
                          ),
                          Text(
                            'Pendapatan Bulan Ini',
                            style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textLight),
                          ),
                        ],
                      ),
                      Text(
                        'Puncak: ${currencyFormat.format(highestRevenue).replaceAll(',', '.')}',
                        style: GoogleFonts.inter(
                          color: JamuTheme.primaryGreenLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Line Chart
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots.map((e) => FlSpot(e.x + 1, e.y)).toList(),
                            isCurved: true,
                            color: JamuTheme.primaryGreen,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: JamuTheme.primaryGreenLight.withOpacity(0.3),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: highestRevenue > 0 ? highestRevenue * 1.2 : 100,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: JamuTheme.primaryGreen,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  'Tgl ${spot.x.toInt()}\n${currencyFormat.format(spot.y).replaceAll(',', '.')}',
                                  GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
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
                              getTitlesWidget: (value, meta) {
                                int day = value.toInt();
                                if (day == 1 || day % 5 == 0 || day == spots.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4,
                                    child: Text(
                                      day == spots.length ? 'HARI INI' : '$day',
                                      style: GoogleFonts.inter(
                                        color: JamuTheme.textLight,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: highestRevenue > 0 ? (highestRevenue / 4) : 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: JamuTheme.borderLight,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Ketuk batang grafik untuk melihat detail',
                style: JamuTheme.bodyMedium.copyWith(color: JamuTheme.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
