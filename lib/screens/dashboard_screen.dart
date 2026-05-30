import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_tab.dart';
import 'monitor_tab.dart';
import 'revenue_tab.dart';
import 'profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const MonitorTab(),
    const RevenueTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JamuTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Content Tab
          _tabs[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authProvider = Provider.of<AuthProvider>(context);
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: JamuTheme.lightMintBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'POS Jamu',
            style: GoogleFonts.outfit(
              color: JamuTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: _selectedIndex == 3
          ? []
          : [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3; // Pindah ke tab Profil
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: JamuTheme.borderLight, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: authProvider.userPhotoPath.startsWith('assets/')
                          ? Image.asset(
                              authProvider.userPhotoPath,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(authProvider.userPhotoPath),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: JamuTheme.borderLight, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavBarItem(0, Icons.grid_view_rounded, "Dashboard"),
            _buildNavBarItem(1, Icons.thermostat_rounded, "Monitor"),
            _buildNavBarItem(2, Icons.account_balance_wallet_outlined, "Revenue"),
            _buildNavBarItem(3, Icons.person_outline_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    if (isSelected) {
      // Selected State: Capsule Layout
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: JamuTheme.accentGreen, // Mint green background capsule
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: JamuTheme.primaryGreen, // Dark Green Icon
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: JamuTheme.primaryGreen, // Dark Green Text
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    // Unselected State: Stacked Icon & Label
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: JamuTheme.textLight,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: JamuTheme.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
