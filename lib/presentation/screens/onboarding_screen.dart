import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../data/repositories/job_repository.dart';
import '../../utils/language_manager.dart';
import '../widgets/appliq_logo.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final JobRepository repository;

  const OnboardingScreen({super.key, required this.repository});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _animController;
  late final Animation<double> _floatAnimation;

  List<OnboardingData> get _pages {
    final isEn = LanguageManager.isEnglish;
    return [
      OnboardingData(
        title: isEn ? 'Take Control of Your\nJob Applications' : 'Kendalikan Proses\nLamaran Kerja',
        subtitle: isEn 
            ? 'Track every job vacancy, role, and company you apply to in seconds.' 
            : 'Catat setiap lowongan, posisi, dan perusahaan yang kamu lamar dalam hitungan detik.',
        type: OnboardingType.tracker,
      ),
      OnboardingData(
        title: isEn ? 'Track Interview &\nTest Schedules' : 'Pantau Jadwal\nWawancara & Tes',
        subtitle: isEn 
            ? 'Keep interviewer names, technical notes, and video meeting links neatly in one place.' 
            : 'Simpan nama interviewer, catatan teknis, dan tautan pertemuan secara rapi dalam satu tempat.',
        type: OnboardingType.schedule,
      ),
      OnboardingData(
        title: isEn ? 'Data-Driven\nCareer Analytics' : 'Analitik Pelamar\nBerbasis Data',
        subtitle: isEn 
            ? 'Discover your most effective job portals and track interview conversion rates in real-time.' 
            : 'Ketahui portal loker paling efektif dan tingkat keberhasilan interview kamu secara real-time.',
        type: OnboardingType.analytics,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

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
    final btnBg = isDark ? Colors.white : const Color(0xFF18181B);
    final btnFg = isDark ? const Color(0xFF18181B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Fixed height prevents any layout shift when 'Lewati' is hidden
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppliqLogo(
                        size: 32,
                        borderRadius: 9,
                        padding: EdgeInsets.all(3.5),
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
                  // Visibility maintainSize keeps header height completely stable across all pages
                  Visibility(
                    visible: _currentPage < _pages.length - 1,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _navigateToLogin();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        LanguageManager.isEnglish ? 'Skip' : 'Lewati',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
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
                        // Dynamic Animated Visual Elements (No generic outer box)
                        SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: _floatAnimation,
                            builder: (context, _) {
                              return Transform.translate(
                                offset: Offset(0, _floatAnimation.value),
                                child: _buildVisual(page.type, isDark),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

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
                            fontSize: 14.5,
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

            // Footer (Monochrome Dots Indicator & Monochrome Action Button)
            _buildFooter(_pages, isDark, btnBg, btnFg),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(OnboardingType type, bool isDark) {
    switch (type) {
      case OnboardingType.tracker:
        return _buildTrackerVisual(isDark);
      case OnboardingType.schedule:
        return _buildScheduleVisual(isDark);
      case OnboardingType.analytics:
        return _buildAnalyticsVisual(isDark);
    }
  }

  // Visual 1: Authentic Layered Job Cards with Status Badges
  Widget _buildTrackerVisual(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Back Card (Secondary)
        Positioned(
          top: 18,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B).withValues(alpha: 0.7) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.paintbrush_fill,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Senior UI/UX Designer',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Tokopedia • Jakarta',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Applied',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF52525B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Front Main Card (Primary)
        Positioned(
          top: 76,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          CupertinoIcons.chevron_left_slash_chevron_right,
                          size: 20,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lead Flutter Engineer',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: -0.3,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GoTo Financial • Hybrid',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.checkmark_alt, size: 13, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'Interview',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, thickness: 0.8, color: borderColor),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp 22.000.000 - 30.000.000 ${AppStrings.perMonth}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      LanguageManager.isEnglish ? '2h ago' : '2 jam lalu',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Visual 2: Sleek Live Interview Schedule Preview
  Widget _buildScheduleVisual(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 13,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        LanguageManager.isEnglish ? 'Tomorrow, 10:00 AM' : 'Besok, 10:00 WIB',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Color(0xFFEF4444)),
                      SizedBox(width: 5),
                      Text(
                        'User Interview',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Technical & System Design',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              LanguageManager.isEnglish 
                  ? 'Asia Digital Bank • with Engineering Manager' 
                  : 'Bank Digital Asia • Bersama Engineering Manager',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.videocam_fill, size: 18, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'meet.google.com/app-liq-demo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.doc_on_clipboard,
                    size: 15,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Visual 3: Bespoke Real-time Metrics & Conversion Funnel (No Generic Template Box)
  Widget _buildAnalyticsVisual(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E2E33) : const Color(0xFFE4E4E7);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 3 Key Metric Capsules
        Row(
          children: [
            Expanded(child: _buildMetricItem('24', AppStrings.statTotal, CupertinoIcons.briefcase_fill, isDark, cardBg, borderColor)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricItem('8', AppStrings.statInterview, CupertinoIcons.chat_bubble_2_fill, isDark, cardBg, borderColor)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricItem('3', AppStrings.statOffering, CupertinoIcons.sparkles, isDark, cardBg, borderColor)),
          ],
        ),
        const SizedBox(height: 14),

        // Conversion Pipeline Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageManager.isEnglish ? 'Conversion Rate' : 'Tingkat Keberhasilan (Conversion)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '33.3%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Segmented Progress Funnel Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Container(color: isDark ? Colors.white : const Color(0xFF18181B)),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 4,
                        child: Container(color: isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: 12,
                        child: Container(color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Applied', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                  Text('Screening', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                  Text('Interview', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                  Text('Offering', style: TextStyle(fontSize: 10.5, color: isDark ? AppColors.textHintDark : AppColors.textHint)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String value, String label, IconData icon, bool isDark, Color cardBg, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF18181B)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(List<OnboardingData> pages, bool isDark, Color btnBg, Color btnFg) {
    final isLastPage = _currentPage == pages.length - 1;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots Indicator (Monochrome)
          Row(
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 6),
                height: 7,
                width: _currentPage == index ? 22 : 7,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? (isDark ? Colors.white : const Color(0xFF18181B))
                      : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Navigation Button (Monochrome)
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
                  height: 50,
                  padding: isLastPage
                      ? const EdgeInsets.symmetric(horizontal: 22)
                      : const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: btnBg,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
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
                              LanguageManager.isEnglish ? 'Get Started' : 'Mulai',
                              style: TextStyle(
                                color: btnFg,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 16,
                              color: btnFg,
                            ),
                          ],
                        )
                      : Icon(
                          CupertinoIcons.arrow_right,
                          size: 18,
                          color: btnFg,
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
