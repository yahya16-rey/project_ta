import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../providers/jamu_provider.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({Key? key}) : super(key: key);

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
          'Log Aktivitas Terkini',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
      ),
      body: Consumer<JamuProvider>(
        builder: (context, provider, child) {
          if (provider.recentActivities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada log aktivitas tercatat.',
                    style: JamuTheme.bodyLarge.copyWith(color: JamuTheme.textLight),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: provider.recentActivities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = provider.recentActivities[index];
              final isTemp = activity.type == 'temp';

              return GestureDetector(
                onTap: () {
                  _showActivityDetailDialog(context, activity);
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: JamuTheme.cardColor,
                    borderRadius: JamuTheme.innerCardRadius,
                    border: Border.all(color: JamuTheme.borderLight),
                    boxShadow: JamuTheme.softShadow,
                  ),
                  child: Row(
                    children: [
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
                            ),
                          ],
                        ),
                      ),
                      Text(
                        activity.timestamp,
                        style: JamuTheme.bodySmall.copyWith(
                          color: JamuTheme.textLight,
                          fontSize: 12,
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

  void _showActivityDetailDialog(BuildContext context, dynamic activity) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                activity.type == 'temp' ? Icons.thermostat_rounded : Icons.shopping_cart_rounded,
                color: JamuTheme.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Detail Aktivitas',
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
                'Waktu: ${activity.timestamp}',
                style: JamuTheme.bodySmall.copyWith(color: JamuTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                activity.title,
                style: JamuTheme.titleSmall.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: JamuTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'TUTUP',
                style: GoogleFonts.inter(
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
