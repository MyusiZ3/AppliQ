import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../data/repositories/job_repository.dart';
import 'applications/applications_list_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'schedule/schedule_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final JobRepository repository;

  const MainNavigationScreen({super.key, required this.repository});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ApplicationsListScreen(repository: widget.repository),
      DashboardScreen(repository: widget.repository),
      ScheduleScreen(repository: widget.repository),
      ProfileScreen(repository: widget.repository),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.textHintDark : AppColors.textHint,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: -0.2),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.doc_text, size: 22),
              activeIcon: const Icon(CupertinoIcons.doc_text_fill, size: 22),
              label: AppStrings.navApplications,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.chart_pie, size: 22),
              activeIcon: const Icon(CupertinoIcons.chart_pie_fill, size: 22),
              label: AppStrings.navAnalytics,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.calendar, size: 22),
              activeIcon: const Icon(CupertinoIcons.calendar_today, size: 22),
              label: AppStrings.quickSchedule,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person, size: 22),
              activeIcon: const Icon(CupertinoIcons.person_fill, size: 22),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
