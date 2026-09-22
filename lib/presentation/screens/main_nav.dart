import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/job_repository.dart';
import 'applications/application_form_screen.dart';
import 'applications/applications_list_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'schedule/schedule_screen.dart';

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

  static final List<_NavItemData> _navItems = [
    _NavItemData(
      label: 'Home',
      customIcon: (color, isActive) => MyDuitHomeIcon(
        color: color,
        size: 21,
      ),
    ),
    _NavItemData(
      label: 'Lamaran',
      activeIcon: CupertinoIcons.briefcase_fill,
      inactiveIcon: CupertinoIcons.briefcase,
    ),
    _NavItemData(
      label: 'Jadwal',
      activeIcon: CupertinoIcons.calendar_today,
      inactiveIcon: CupertinoIcons.calendar,
    ),
    _NavItemData(
      label: 'Statistik',
      activeIcon: CupertinoIcons.chart_bar_alt_fill,
      inactiveIcon: CupertinoIcons.chart_bar_alt_fill,
    ),
  ];

  void _onTabTapped(int index) {
    if (index < 0 || index >= _screenBuilders.length) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _showAddApplication() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicationFormScreen(repository: widget.repository),
      ),
    );
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
    final iconColor = isActive ? const Color(0xFF18181B) : const Color(0xFFA1A1AA);

    Widget iconWidget;
    if (item.customIcon != null) {
      iconWidget = item.customIcon!(iconColor, isActive);
    } else {
      iconWidget = Icon(
        isActive ? item.activeIcon! : item.inactiveIcon!,
        size: isActive ? 20 : 21,
        color: iconColor,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isActive ? 104 : 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF27272A),
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
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF18181B),
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
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final Widget Function(Color color, bool isActive)? customIcon;

  const _NavItemData({
    required this.label,
    this.activeIcon,
    this.inactiveIcon,
    this.customIcon,
  });
}

class MyDuitHomeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MyDuitHomeIcon({
    super.key,
    this.size = 20,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MyDuitHomePainter(color: color),
      ),
    );
  }
}

class _MyDuitHomePainter extends CustomPainter {
  final Color color;

  _MyDuitHomePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Outer boundary (crisp optical proportions)
    // Bottom-left
    path.moveTo(w * 0.06, h * 0.92);
    // Left vertical wall
    path.lineTo(w * 0.06, h * 0.44);
    // Left shoulder curve
    path.quadraticBezierTo(w * 0.06, h * 0.39, w * 0.10, h * 0.35);
    // Left roof slope
    path.lineTo(w * 0.46, h * 0.06);
    // Outer roof apex curve
    path.quadraticBezierTo(w * 0.50, h * 0.02, w * 0.54, h * 0.06);
    // Right roof slope
    path.lineTo(w * 0.90, h * 0.35);
    // Right shoulder curve
    path.quadraticBezierTo(w * 0.94, h * 0.39, w * 0.94, h * 0.44);
    // Right vertical wall
    path.lineTo(w * 0.94, h * 0.92);

    // Inner pitched doorway cutout (matching MyDuitGweh silhouette)
    // Right leg bottom inner
    path.lineTo(w * 0.67, h * 0.92);
    // Right inner wall
    path.lineTo(w * 0.67, h * 0.57);
    // Right inner shoulder
    path.quadraticBezierTo(w * 0.67, h * 0.53, w * 0.63, h * 0.50);
    // Right inner ceiling slope
    path.lineTo(w * 0.53, h * 0.41);
    // Inner peak curve
    path.quadraticBezierTo(w * 0.50, h * 0.38, w * 0.47, h * 0.41);
    // Left inner ceiling slope
    path.lineTo(w * 0.37, h * 0.50);
    // Left inner shoulder
    path.quadraticBezierTo(w * 0.33, h * 0.53, w * 0.33, h * 0.57);
    // Left inner wall
    path.lineTo(w * 0.33, h * 0.92);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MyDuitHomePainter oldDelegate) =>
      oldDelegate.color != color;
}
