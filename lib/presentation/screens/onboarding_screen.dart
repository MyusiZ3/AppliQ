import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/job_repository.dart';
import '../widgets/appliq_logo.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final JobRepository repository;

  const OnboardingScreen({super.key, required this.repository});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Kendalikan Proses\nLamaran Kerja',
      subtitle: 'Catat setiap lowongan, posisi, dan perusahaan yang kamu lamar dalam hitungan detik.',
      type: OnboardingType.tracker,
    ),
    OnboardingData(
      title: 'Pantau Jadwal\nWawancara & Tes',
      subtitle: 'Simpan nama interviewer, catatan teknis, dan tautan pertemuan secara rapi dalam satu tempat.',
      type: OnboardingType.schedule,
    ),
    OnboardingData(
      title: 'Analitik Pelamar\nBerbasis Data',
      subtitle: 'Ketahui portal loker paling efektif dan tingkat keberhasilan interview kamu secara real-time.',
      type: OnboardingType.analytics,
    ),
  ];

  Future<void> _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? Colors.white : const Color(0xFF18181B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppliqLogo(
                        size: 34,
                        borderRadius: 10,
                        padding: EdgeInsets.all(4),
                        hasWhiteBackground: true,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AppliQ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _navigateToLogin();
                      },
                      child: Text(
                        'Lewati',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration Container
                        Center(
                          child: Container(
                            height: 240,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            child: _buildVisual(page.type, isDark, accentColor),
                          ),
                        ),

                        // Title
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            height: 1.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer (Dots Indicator & Arrow Button)
            _buildFooter(_pages, isDark, AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(OnboardingType type, bool isDark, Color accentColor) {
    switch (type) {
      case OnboardingType.tracker:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.income, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Software Engineer • PT Maju',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.clock_fill, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Product Designer • Dikirim 3 hari lalu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case OnboardingType.schedule:
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.video_camera_solid, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'User & Technical Interview',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kamis, 10:00 WIB • Google Meet',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      case OnboardingType.analytics:
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMetricPill('18', 'Total', AppColors.primary, isDark),
              const SizedBox(width: 10),
              _buildMetricPill('6', 'Interview', AppColors.warning, isDark),
              const SizedBox(width: 10),
              _buildMetricPill('2', 'Offering', AppColors.income, isDark),
            ],
          ),
        );
    }
  }

  Widget _buildMetricPill(String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(List<OnboardingData> pages, bool isDark, Color accentColor) {
    final isLastPage = _currentPage == pages.length - 1;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, 0, 28, 20 + bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots Indicator
          Row(
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 6),
                height: 7,
                width: _currentPage == index ? 20 : 7,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? accentColor
                      : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Navigation Button
          Row(
            children: [
              if (_currentPage > 0) ...[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (_currentPage < pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    _navigateToLogin();
                  }
                },
                child: Container(
                  height: 52,
                  padding: isLastPage
                      ? const EdgeInsets.symmetric(horizontal: 20)
                      : const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isLastPage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Mulai',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF18181B) : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 16,
                              color: isDark ? const Color(0xFF18181B) : Colors.white,
                            ),
                          ],
                        )
                      : Icon(
                          CupertinoIcons.arrow_right,
                          size: 18,
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum OnboardingType { tracker, schedule, analytics }

class OnboardingData {
  final String title;
  final String subtitle;
  final OnboardingType type;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}
