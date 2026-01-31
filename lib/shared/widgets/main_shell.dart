import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:silaju/core/constants/app_colors.dart';
import 'package:silaju/core/constants/app_strings.dart';
import 'package:silaju/core/router/app_router.dart';

/// Main shell with bottom navigation bar
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<_NavItem> get _navItems => [
        _NavItem(
          icon: Icons.home_rounded,
          activeIcon: Icons.home_rounded,
          label: AppStrings.home,
          path: '${AppRoutes.main}/${AppRoutes.home}',
        ),
        _NavItem(
          icon: Icons.emoji_events_outlined,
          activeIcon: Icons.emoji_events_rounded,
          label: AppStrings.achievements,
          path: '${AppRoutes.main}/${AppRoutes.achievements}',
        ),
        _NavItem(
          icon: Icons.qr_code_scanner_rounded,
          activeIcon: Icons.qr_code_scanner_rounded,
          label: '', // Empty label for FAB
          path: AppRoutes.createReport,
          isSpecial: true,
        ),
        _NavItem(
          icon: Icons.leaderboard_outlined,
          activeIcon: Icons.leaderboard_rounded,
          label: AppStrings.ranking,
          path: '${AppRoutes.main}/${AppRoutes.leaderboard}',
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: AppStrings.profile,
          path: '${AppRoutes.main}/${AppRoutes.profile}',
        ),
      ];

  void _onItemTapped(int index) {
    if (_navItems[index].isSpecial) {
      context.push(_navItems[index].path);
    } else {
      setState(() => _currentIndex = index);
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialItem = _navItems.firstWhere((item) => item.isSpecial);

    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_navItems.length, (index) {
                    final item = _navItems[index];
                    final isSelected = _currentIndex == index;

                    if (item.isSpecial) {
                      // Text aligned exactly with others using placeholder icon
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => context.push(item.path),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.transparent,
                                size: 26,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lapor',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _buildNavItem(item, index, isSelected);
                  }),
                ),
              ),
            ),
          ),
          // Custom Floating Action Button positioned 1/3 above
          Positioned(
            top: -22, // 1/3 of 64px roughly
            child: GestureDetector(
              onTap: () => context.push(specialItem.path),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    specialItem.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color:
                  isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
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
  final bool isSpecial;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    this.isSpecial = false,
  });
}
