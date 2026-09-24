import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/job_repository.dart';
import 'applications/applications_list_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';

import '../../core/localization/app_strings.dart';

class MainNav extends StatefulWidget {
  final JobRepository repository;

  const MainNav({super.key, required this.repository});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final GlobalKey<State<ApplicationsListScreen>> _listKey = GlobalKey();

  late final List<WidgetBuilder> _screenBuilders = [
    (ctx) => HomeScreen(repository: widget.repository, onNavigateToTab: _onTabTapped),
    (ctx) => ApplicationsListScreen(key: _listKey, repository: widget.repository),
    (ctx) => ScheduleScreen(repository: widget.repository),
    (ctx) => DashboardScreen(repository: widget.repository),
  ];

  String _getNavLabel(int index) {
    switch (index) {
      case 0:
        return AppStrings.navHome;
      case 1:
        return AppStrings.navApplications;
      case 2:
        return AppStrings.navSchedule;
      case 3:
        return AppStrings.navStats;
      default:
        return '';
    }
  }

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      label: 'Home',
      icon: CupertinoIcons.house_fill,
    ),
    _NavItemData(
      label: 'Lamaran',
      icon: CupertinoIcons.briefcase_fill,
    ),
    _NavItemData(
      label: 'Jadwal',
      icon: CupertinoIcons.calendar,
    ),
    _NavItemData(
      label: 'Statistik',
      icon: CupertinoIcons.chart_bar_alt_fill,
    ),
  ];

  void _onTabTapped(int index) {
    if (index < 0 || index >= _screenBuilders.length) return;
    HapticFeedback.selectionClick();
    if (_currentIndex == 1 && index != 1) {
      try {
        (_listKey.currentState as dynamic)?.closeSearch();
      } catch (_) {}
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: List.generate(
                  _screenBuilders.length,
                  (index) => _screenBuilders[index](context),
                ),
              ),

              // Bottom Gradient Fade (MyDuitGweh Signature)
              if (!isKeyboardOpen)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 110,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: isKeyboardOpen
              ? const SizedBox.shrink()
              : SafeArea(
                  bottom: true,
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 280,
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xF218181B),
                            borderRadius: BorderRadius.circular(44),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildPillNavItem(0, isDark),
                              _buildPillNavItem(1, isDark),
                              _buildPillNavItem(2, isDark),
                              _buildPillNavItem(3, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPillNavItem(int index, bool isDark) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;

    final activeBg = const Color(0xFFFFFFFF);
    final inactiveBg = const Color(0xFF27272A);

    final activeFg = const Color(0xFF18181B);
    final inactiveFg = const Color(0xFFA1A1AA);

    final iconColor = isActive ? activeFg : inactiveFg;

    final iconWidget = Icon(
      item.icon,
      size: 20,
      color: iconColor,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isActive ? 104 : 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              if (isActive) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _getNavLabel(index),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: activeFg,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({
    required this.label,
    required this.icon,
  });
}
