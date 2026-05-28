import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/theme.dart';
import '../providers/jamu_provider.dart';
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

          // Floating Action Button (Only show on Dashboard index 0)
          if (_selectedIndex == 0)
            Positioned(
              right: 16,
              bottom: 80, // Positioned right above the bottom navigation bar
              child: FloatingActionButton(
                onPressed: () {
                  // Switch to Revenue Tab (Index 2)
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                backgroundColor: JamuTheme.primaryGreen,
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // Dynamic App Bar configurations depending on selected tab index
    if (_selectedIndex == 1) {
      // Monitor Tab App Bar
      return AppBar(
        title: Text(
          'Monitoring Suhu Jamu',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: JamuTheme.textPrimary,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.healing_outlined,
              color: JamuTheme.primaryGreen,
              size: 22,
            ),
          ),
        ),
        leadingWidth: 42,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: JamuTheme.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }

    // Default: Jamu Herbal App Bar (Dashboard, Revenue, Profile)
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: JamuTheme.borderLight),
            ),
            child: const Icon(
              Icons.healing_outlined,
              color: JamuTheme.primaryGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Jamu Herbal',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: JamuTheme.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        if (_selectedIndex == 3) ...[
          // Settings Gear action on Profile Screen
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: JamuTheme.textPrimary),
            onPressed: () {},
          ),
        ] else ...[
          // Bell & Profile image action on Dashboard & Revenue Screens
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: JamuTheme.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: JamuTheme.borderLight, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/owner_profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      backgroundColor: JamuTheme.lightMintBg,
                      child: Icon(Icons.person_rounded, size: 16, color: JamuTheme.primaryGreen),
                    );
                  },
                ),
              ),
            ),
          ),
        ]
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
