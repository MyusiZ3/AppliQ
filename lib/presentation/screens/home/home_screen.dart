import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/status_helper.dart';
import '../../../data/models/job_application.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../applications/application_detail_screen.dart';
import '../applications/application_form_screen.dart';

import '../profile/profile_screen.dart';

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
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
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

  Future<void> _loadDashboardData({bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        widget.repository.getCurrentUserProfile(forceRefresh: forceRefresh),
        widget.repository.getApplications(forceRefresh: forceRefresh),
        widget.repository.getDashboardStats(forceRefresh: forceRefresh),
      ]);

      if (mounted) {
        setState(() {
          _userProfile = results[0] as UserProfile?;
          _applications = (results[1] as List<JobApplication>?) ?? [];
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(repository: widget.repository),
      ),
    ).then((_) => _loadDashboardData(isSilent: true));
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
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return '${formatter.format(amount)} / bln';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _applications.length;
    final interview = _applications.where((a) => a.status == ApplicationStatus.interview).length;
    final offering = _applications.where((a) => a.status == ApplicationStatus.offering || a.status == ApplicationStatus.accepted).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _loadDashboardData(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  children: [
                    // Top User Bar
                    _buildHeader(isDark),

                    const SizedBox(height: 20),

                    // Hero Analytics Card (Purple/Indigo Apple Style Gradient)
                    _buildHeroBanner(total, interview, offering, isDark),

                    const SizedBox(height: 28),

                    // Section 1: Lamaran Terbaru / Prioritas (Horizontal Carousel)
                    _buildSectionHeader(
                      title: 'Lamaran Terbaru',
                      badge: '🔥',
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
    );
  }

  Widget _buildHeader(bool isDark) {
    final displayName = _userProfile?.fullName.isNotEmpty == true
        ? _userProfile!.fullName
        : 'Pencari Karir';
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final greeting = _getDynamicGreeting();

    return Row(
      children: [
        // Avatar with Tap to open Profile
        GestureDetector(
          onTap: _openProfile,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _userProfile?.avatarUrl.isNotEmpty == true
                ? Image.network(
                    _userProfile!.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        initialLetter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initialLetter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
          ),
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 13,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Action Buttons (Calendar/Schedule & Notification)
        Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.calendar, size: 22),
              color: isDark ? Colors.white : const Color(0xFF18181B),
              onPressed: () => widget.onNavigateToTab?.call(2),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.bell, size: 22),
              color: isDark ? Colors.white : const Color(0xFF18181B),
              onPressed: () {
                UIHelper.showInfoSnackBar(context, 'Tidak ada pengingat jadwal mendesak hari ini.');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner(int total, int interview, int offering, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFF18181B),
        border: Border.all(
          color: isDark ? const Color(0xFF323238) : const Color(0x1F000000),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      Icon(CupertinoIcons.chevron_right, color: Colors.white, size: 12),
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
    String? badge,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
            if (badge != null) ...[
              const SizedBox(width: 6),
              Text(badge, style: const TextStyle(fontSize: 16)),
            ],
          ],
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
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai tambahkan lowongan pekerjaan yang sedang kamu ikuti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ApplicationFormScreen(repository: widget.repository),
                  ),
                ).then((_) => _loadDashboardData());
              },
              icon: const Icon(CupertinoIcons.plus, size: 16),
              label: const Text('Catat Lamaran Pertama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _applications.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final app = _applications[index];
          return _buildApplicationCard(app, isDark);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication app, bool isDark) {
    final companyInitial = app.companyName.isNotEmpty ? app.companyName[0].toUpperCase() : 'J';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ApplicationDetailScreen(
              applicationId: app.id,
              repository: widget.repository,
            ),
          ),
        ).then((_) => _loadDashboardData());
      },
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      companyInitial,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.positionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleFavorite(app),
                  child: Icon(
                    app.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    size: 20,
                    color: app.isFavorite ? AppColors.expense : (isDark ? AppColors.textHintDark : AppColors.textHint),
                  ),
                ),
              ],
            ),

            // Chips / Tags (WorkSystem & Status)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildTag(app.workSystem.label, isDark),
                _buildTag(app.jobPortal.label, isDark),
                _buildStatusTag(app.status.label, StatusHelper.getStatusColor(app.status), isDark),
              ],
            ),

            // Bottom Row: Location & Salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 13,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          app.location?.isNotEmpty == true ? app.location! : 'Indonesia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatSalary(app.salaryOffered ?? app.salaryExpectation),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatusTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompaniesList(bool isDark) {
    final Map<String, int> companyCounts = {};
    for (var app in _applications) {
      companyCounts[app.companyName] = (companyCounts[app.companyName] ?? 0) + 1;
    }

    if (companyCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: companyCounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final companyName = companyCounts.keys.elementAt(index);
          final count = companyCounts[companyName] ?? 1;

          return Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count Lamaran aktif',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
