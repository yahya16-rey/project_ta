import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';

class TemperatureHistoryScreen extends StatelessWidget {
  const TemperatureHistoryScreen({Key? key}) : super(key: key);

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
          'Riwayat Update Suhu IoT',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer<JamuProvider>(
        builder: (context, provider, child) {
          if (provider.tempHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.thermostat_rounded, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat update suhu.',
                    style: JamuTheme.bodyLarge.copyWith(color: JamuTheme.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.tempHistory.length,
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
          );
        },
      ),
    );
  }
}
