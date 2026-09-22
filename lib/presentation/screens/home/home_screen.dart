import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/status_helper.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../applications/application_detail_screen.dart';
import '../applications/application_form_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/hr_templates_sheet.dart';
import '../../widgets/export_sheet.dart';
import '../../widgets/notification_sheet.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/appliq_loading.dart';
import '../../widgets/app_avatar.dart';
import '../../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final JobRepository repository;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.repository,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _userProfile;
  List<JobApplication> _applications = [];
  List<Map<String, dynamic>> _upcomingSchedules = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isFollowUpDismissed = false;
  bool _hasReadNotifications = false;
  StreamSubscription? _dataSub;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _dataSub = widget.repository.dataChanges.listen((_) {
      if (mounted) _loadDashboardData(isSilent: true);
    });
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  static final NumberFormat _salaryFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Future<void> _loadDashboardData(
      {bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        widget.repository.getCurrentUserProfile(forceRefresh: forceRefresh),
        widget.repository.getApplications(forceRefresh: forceRefresh),
        widget.repository.getDashboardStats(forceRefresh: forceRefresh),
        widget.repository.getAllApplicationLogs(forceRefresh: forceRefresh),
      ]);

      final apps = (results[1] as List<JobApplication>?) ?? [];
      final allLogs = (results[3] as List<ApplicationLog>?) ?? [];
      final upcoming = <Map<String, dynamic>>[];
      final now = DateTime.now();
      final appMap = {for (var a in apps) a.id: a};

      for (var log in allLogs) {
        if (log.scheduledAt != null &&
            log.scheduledAt!.isAfter(now.subtract(const Duration(hours: 3)))) {
          final app = appMap[log.applicationId];
          if (app != null &&
              (app.status == ApplicationStatus.interview ||
               app.status == ApplicationStatus.applied)) {
            upcoming.add({
              'app': app,
              'log': log,
            });
          }
        }
      }

      upcoming.sort((a, b) {
        final dateA = (a['log'] as ApplicationLog).scheduledAt!;
        final dateB = (b['log'] as ApplicationLog).scheduledAt!;
        return dateA.compareTo(dateB);
      });

      // Jadwalkan pengingat push notification otomatis untuk agenda mendatang
      for (var item in upcoming) {
        final app = item['app'] as JobApplication;
        final log = item['log'] as ApplicationLog;
        if (log.scheduledAt != null && log.scheduledAt!.isAfter(DateTime.now())) {
          NotificationService.instance.scheduleInterviewReminder(
            id: log.id.hashCode,
            company: app.companyName,
            position: app.positionTitle,
            stageName: log.stageName,
            scheduledAt: log.scheduledAt!,
            remindMinutesBefore: 60,
          );
        }
      }

      if (mounted) {
        setState(() {
          _userProfile = results[0] as UserProfile?;
          _applications = apps;
          _upcomingSchedules = upcoming;
          _stats = (results[2] as Map<String, dynamic>?) ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (!isSilent) UIHelper.handleError(context, e);
      }
    }
  }

  void _openProfile() {
    HapticFeedback.lightImpact();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ProfileScreen(repository: widget.repository),
          ),
        )
        .then((_) => _loadDashboardData(isSilent: true));
  }

  Future<void> _toggleFavorite(JobApplication app) async {
    HapticFeedback.selectionClick();
    try {
      await widget.repository.toggleFavorite(app.id);
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  String _formatSalary(double? amount) {
    if (amount == null || amount == 0) return 'Gaji Dirahasiakan';
    return '${_salaryFormatter.format(amount)} / bln';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _applications.length;
    final interview = _applications
        .where((a) => a.status == ApplicationStatus.interview)
        .length;
    final offering = _applications
        .where((a) =>
            a.status == ApplicationStatus.offering ||
            a.status == ApplicationStatus.accepted)
        .length;

    final staleApplications = _applications.where((app) {
      if (app.status != ApplicationStatus.applied &&
          app.status != ApplicationStatus.noResponse) return false;
      if (app.appliedDate == null) return false;
      final days = DateTime.now().difference(app.appliedDate!).inDays;
      return days >= 7;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: AppliqLoading(),
                ),
              )
            : Column(
                children: [
                  // Sticky Top User Bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.background,
                    child: _buildHeader(isDark, staleApplications),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _loadDashboardData(forceRefresh: true),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                        children: [
                          // Hero Analytics Card (Monochrome Notched Pill Style)
                          _buildHeroBanner(total, interview, offering, isDark),

                          const SizedBox(height: 22),

                          // Quick Action Shortcuts (4 Minimalist Quick Actions)
                          _buildQuickActions(isDark),

                          // Upcoming Schedule Widget (If any upcoming interview schedule)
                          if (_upcomingSchedules.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            _buildUpcomingScheduleCard(
                                _upcomingSchedules.first, isDark),
                          ],

                          // Smart Follow-Up Reminder Alert (If any stale applications)
                          if (!_isFollowUpDismissed &&
                              staleApplications.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _buildFollowUpAlert(staleApplications, isDark),
                          ],

                          const SizedBox(height: 28),

                          // Section 1: Lamaran Terbaru (Horizontal Carousel)
                          _buildSectionHeader(
                            title: 'Lamaran Terbaru',
                            actionLabel: 'Lihat Semua',
                            onAction: () => widget.onNavigateToTab?.call(1),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 14),

                          _buildRecentApplications(isDark),

                          const SizedBox(height: 28),

                          // Section 2: Perusahaan yang Dilamar
                          _buildSectionHeader(
                            title: 'Perusahaan Dilamar',
                            actionLabel: 'Lihat Detail',
                            onAction: () => widget.onNavigateToTab?.call(1),
                            isDark: isDark,
                          ),

                          const SizedBox(height: 14),

                          _buildCompaniesList(isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF323238) : const Color(0x1F000000),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: CupertinoIcons.plus,
            label: 'Lamaran',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ApplicationFormScreen(repository: widget.repository),
                    ),
                  )
                  .then((_) => _loadDashboardData());
            },
            isDark: isDark,
          ),
          _buildQuickActionItem(
            icon: CupertinoIcons.calendar,
            label: 'Jadwal',
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onNavigateToTab?.call(2);
            },
            isDark: isDark,
          ),
          _buildQuickActionItem(
            icon: CupertinoIcons.doc_text,
            label: 'Template',
            onTap: () {
              HapticFeedback.lightImpact();
              HrTemplatesSheet.show(context);
            },
            isDark: isDark,
          ),
          _buildQuickActionItem(
            icon: CupertinoIcons.square_arrow_up,
            label: 'Ekspor',
            onTap: () {
              HapticFeedback.lightImpact();
              ExportSheet.show(context, _applications);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C30) : const Color(0xFF27272A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingScheduleCard(Map<String, dynamic> item, bool isDark) {
    final app = item['app'] as JobApplication;
    final log = item['log'] as ApplicationLog;
    final date = log.scheduledAt!;
    final now = DateTime.now();
    final isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;
    final isTomorrow = date.difference(now).inDays == 1 ||
        (date.day == now.day + 1 && date.month == now.month);
    final timeStr = DateFormat('HH:mm').format(date);

    String timeLabel;
    if (isToday) {
      timeLabel = 'Hari ini, $timeStr WIB';
    } else if (isTomorrow) {
      timeLabel = 'Besok, $timeStr WIB';
    } else {
      const days = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final dayName = days[(date.weekday - 1).clamp(0, 6)];
      final monthName = months[(date.month - 1).clamp(0, 11)];
      timeLabel = '$dayName, ${date.day} $monthName • $timeStr';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.calendar,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Jadwal Terdekat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            app.positionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${app.companyName} • ${log.stageName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (log.meetingLink != null && log.meetingLink!.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final uri = Uri.parse(log.meetingLink!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(CupertinoIcons.videocam_fill,
                            color: Color(0xFF18181B), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Buka Link Meeting',
                          style: TextStyle(
                            color: Color(0xFF18181B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => ApplicationDetailScreen(
                            applicationId: app.id,
                            repository: widget.repository,
                          ),
                        ),
                      )
                      .then((_) => _loadDashboardData(isSilent: true));
                },
                child: Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.9), size: 11),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpAlert(List<JobApplication> staleApps, bool isDark) {
    final count = staleApps.length;
    final firstName = staleApps.first.companyName;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.hourglass,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Perlu Follow-up ($count)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isFollowUpDismissed = true),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 14,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  count == 1
                      ? 'Lamaran di $firstName sudah > 7 hari tanpa kabar status.'
                      : '$count lamaran termasuk di $firstName sudah > 7 hari tanpa respon.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HrTemplatesSheet.show(
                      context,
                      defaultCompanyName: staleApps.first.companyName,
                      defaultPosition: staleApps.first.positionTitle,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kirim Email Follow-up',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF18181B),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.arrow_up_right,
                        size: 11,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, List<JobApplication> staleApplications) {
    final rawName = _userProfile?.fullName.isNotEmpty == true
        ? _userProfile!.fullName
        : 'Pencari Karir';
    final displayName =
        rawName.length > 12 ? '${rawName.substring(0, 12)}...' : rawName;
    final initialLetter =
        rawName.isNotEmpty ? rawName[0].toUpperCase() : 'U';
    final greeting = _getDynamicGreeting();
    final hasAlerts = !_hasReadNotifications &&
        (_upcomingSchedules.isNotEmpty || staleApplications.isNotEmpty);

    return Row(
      children: [
        // Avatar with Tap to open Profile
        AppAvatar(
          url: _userProfile?.avatarUrl,
          radius: 23,
          isDark: isDark,
          fallbackName: _userProfile?.fullName,
          onTap: _openProfile,
        ),
        const SizedBox(width: 12),
        // Name & Dynamic Greeting
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openProfile,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 13,
                      color:
                          isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Action Button with Notification Center & Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.bell, size: 22),
              color: isDark ? Colors.white : const Color(0xFF18181B),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _hasReadNotifications = true);
                NotificationSheet.show(
                  context,
                  upcomingSchedules: _upcomingSchedules,
                  staleApplications: staleApplications,
                );
              },
            ),
            if (hasAlerts)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner(int total, int interview, int offering, bool isDark) {
    return NotchedCard(
      showTopNotch: true,
      showBottomNotch: false,
      borderRadius: 26,
      padding: const EdgeInsets.all(22),
      backgroundColor: isDark ? const Color(0xFF1E1E22) : const Color(0xFF18181B),
      borderColor: isDark ? const Color(0xFF323238) : const Color(0x1F000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Lamaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateToTab?.call(3),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Statistik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_right,
                          color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Total Applications
              Expanded(
                child: _buildBannerStat(
                  icon: CupertinoIcons.briefcase_fill,
                  value: '$total',
                  label: 'Dilamar',
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              // Interview Stage
              Expanded(
                child: _buildBannerStat(
                  icon: CupertinoIcons.videocam_fill,
                  value: '$interview',
                  label: 'Interview',
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              // Offering
              Expanded(
                child: _buildBannerStat(
                  icon: CupertinoIcons.gift_fill,
                  value: '$offering',
                  label: 'Offering',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: isDark ? const Color(0xFFE4E4E7) : const Color(0xFF18181B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentApplications(bool isDark) {
    if (_applications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 40,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada lamaran tersimpan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai tambahkan lowongan pekerjaan yang sedang kamu ikuti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => ApplicationFormScreen(
                            repository: widget.repository),
                      ),
                    )
                    .then((_) => _loadDashboardData());
              },
              icon: const Icon(CupertinoIcons.plus, size: 16),
              label: const Text('Catat Lamaran Pertama'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.white : const Color(0xFF18181B),
                foregroundColor:
                    isDark ? const Color(0xFF18181B) : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _applications.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final app = _applications[index];
          return _buildApplicationCard(app, isDark);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication app, bool isDark) {
    final companyInitial =
        app.companyName.isNotEmpty ? app.companyName[0].toUpperCase() : 'J';

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => ApplicationDetailScreen(
                  applicationId: app.id,
                  repository: widget.repository,
                ),
              ),
            )
            .then((_) => _loadDashboardData(isSilent: true));
      },
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Logo, Title & Favorite
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      companyInitial,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.positionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        app.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleFavorite(app),
                  child: Icon(
                    app.isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    size: 18,
                    color: app.isFavorite
                        ? AppColors.expense
                        : (isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint),
                  ),
                ),
              ],
            ),

            // Chips / Tags (WorkSystem & Status)
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [
                _buildTag(app.workSystem.label, isDark),
                _buildTag(app.jobPortal.label, isDark),
                _buildStatusTag(app.status.label,
                    StatusHelper.getStatusColor(app.status), isDark),
              ],
            ),

            // Bottom Row: Location & Salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 12,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          app.location?.isNotEmpty == true
                              ? app.location!
                              : 'Indonesia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 1,
                  child: Text(
                    _formatSalary(app.salaryOffered ?? app.salaryExpectation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompaniesList(bool isDark) {
    final Map<String, List<JobApplication>> companyApps = {};
    for (var app in _applications) {
      companyApps.putIfAbsent(app.companyName, () => []).add(app);
    }

    if (companyApps.isEmpty) {
      return NotchedCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'Belum ada daftar perusahaan yang dilamar.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ),
        ),
      );
    }

    final topCompanies = companyApps.entries.take(5).toList();

    return NotchedCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (int i = 0; i < topCompanies.length; i++) ...[
            _buildCompanyTile(
                topCompanies[i].key, topCompanies[i].value, isDark),
            if (i < topCompanies.length - 1)
              Divider(
                height: 1,
                indent: 70,
                endIndent: 16,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyTile(
      String companyName, List<JobApplication> apps, bool isDark) {
    final companyInitial =
        companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';
    final latestRole = apps.first.positionTitle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onNavigateToTab?.call(1),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Company Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x26FFFFFF)
                        : const Color(0x14000000),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    companyInitial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Company Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      latestRole.isNotEmpty
                          ? latestRole
                          : '${apps.length} Lamaran',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Count Badge + Chevron
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${apps.length} Posisi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
