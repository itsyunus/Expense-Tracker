import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../router/app_router.dart';

/// Main shell with animated bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: RoutePaths.home),
    _NavItem(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, label: 'Analytics', path: RoutePaths.analytics),
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Budget', path: RoutePaths.budget),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', path: RoutePaths.settings),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedIndex = index;
      });
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(isDarkMode),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push(RoutePaths.addExpense);
        },
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              // Add space in the middle for FAB
              if (index == 2) {
                return Row(
                  children: [
                    const SizedBox(width: 56), // Space for FAB
                    _buildNavItem(index, isDarkMode),
                  ],
                );
              }
              return _buildNavItem(index, isDarkMode);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDarkMode) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];
    final color = isSelected
        ? AppColors.primary
        : (isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
