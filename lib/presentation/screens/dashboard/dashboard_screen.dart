import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/export_sheet.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/appliq_loading.dart';
import '../applications/application_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final JobRepository repository;

  const DashboardScreen({super.key, required this.repository});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Kategori Status, 1: Sistem & Portal
  StreamSubscription? _dataSub;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _dataSub = widget.repository.dataChanges.listen((_) {
      if (mounted) _loadStats(isSilent: true);
    });
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStats(
      {bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final data =
          await widget.repository.getDashboardStats(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _stats = data;
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

  Future<void> _handleExport() async {
    HapticFeedback.lightImpact();
    try {
      final apps = await widget.repository.getApplications();
      if (mounted) {
        ExportSheet.show(context, apps);
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = _stats['total_applications'] as int? ?? 0;
    final applied = _stats['applied_count'] as int? ?? 0;
    final interview = _stats['interview_count'] as int? ?? 0;
    final offering = _stats['offering_count'] as int? ?? 0;
    final accepted = _stats['accepted_count'] as int? ?? 0;
    final rejected = _stats['rejected_count'] as int? ?? 0;
    final noResponse = _stats['no_response_count'] as int? ?? 0;

    final byWorkSystem =
        Map<String, dynamic>.from(_stats['by_work_system'] as Map? ?? {});
    final byPortal =
        Map<String, dynamic>.from(_stats['by_portal'] as Map? ?? {});

    final interviewRate = total > 0
        ? ((interview + offering + accepted) / total * 100).toStringAsFixed(1)
        : '0';
    final successRate =
        total > 0 ? (accepted / total * 100).toStringAsFixed(1) : '0';

    return ValueListenableBuilder<AccentThemeMode>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accentMode, _) {
        final isMono = accentMode == AccentThemeMode.monochrome;
        final scaffoldBg =
            AppColors.getBackground(isDark: isDark, isMonochrome: isMono);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Standardized Top Header Row
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  color: scaffoldBg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.analyticsTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            letterSpacing: -0.7,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleExport,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? (isMono
                                    ? const Color(0xFF27272A)
                                    : AppColors.darkSurfaceVariantPastel)
                                : (isMono
                                    ? const Color(0xFFF4F4F5)
                                    : AppColors.lightSurfaceVariantPastel),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? (isMono
                                      ? const Color(0xFF3F3F46)
                                      : AppColors.darkBorderPastel)
                                  : (isMono
                                      ? const Color(0xFFE4E4E7)
                                      : AppColors.lightBorderPastel),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.square_arrow_up,
                              size: 18,
                              color:
                                  isDark ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Notched Pill Selector (Directly under Header, exactly aligned with other screens)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: NotchedPillCard<int>(
                    items: [
                      NotchedPillItem(
                        value: 0,
                        label: AppStrings.pipelineFunnel,
                        icon: CupertinoIcons.chart_pie_fill,
                      ),
                      NotchedPillItem(
                        value: 1,
                        label: AppStrings.systemsAndPortals,
                        icon: CupertinoIcons.chart_bar_alt_fill,
                      ),
                    ],
                    selectedValue: _selectedTab,
                    onValueChanged: (val) => setState(() => _selectedTab = val),
                  ),
                ),

                // Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 60),
                            child: AppliqLoading(),
                          ),
                        )
                      : total == 0
                          ? RefreshIndicator(
                              onRefresh: () => _loadStats(forceRefresh: true),
                              child: EmptyStateView(
                                icon: CupertinoIcons.chart_bar_alt_fill,
                                title: AppStrings.noAnalyticsDataTitle,
                                message: AppStrings.noAnalyticsDataMessage,
                                action: ElevatedButton.icon(
                                  onPressed: () async {
                                    final added =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ApplicationFormScreen(
                                            repository: widget.repository),
                                      ),
                                    );
                                    if (added == true) _loadStats();
                                  },
                                  icon: Icon(
                                    CupertinoIcons.plus,
                                    size: 16,
                                    color: isMono
                                        ? (isDark
                                            ? const Color(0xFF18181B)
                                            : Colors.white)
                                        : AppColors.textOnPastel,
                                  ),
                                  label: Text(
                                    AppStrings.addFirstApp,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isMono
                                          ? (isDark
                                              ? const Color(0xFF18181B)
                                              : Colors.white)
                                          : AppColors.textOnPastel,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMono
                                        ? (isDark
                                            ? Colors.white
                                            : const Color(0xFF18181B))
                                        : AppColors.pastelLime,
                                    foregroundColor: isMono
                                        ? (isDark
                                            ? const Color(0xFF18181B)
                                            : Colors.white)
                                        : AppColors.textOnPastel,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 13),
                                  ),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _loadStats(forceRefresh: true),
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics()),
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 130),
                                children: [
                                  if (_selectedTab == 0) ...[
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isMono
                                                ? (isDark
                                                    ? const Color(0xFF1E1E22)
                                                    : const Color(0xFF18181B))
                                                : (isDark
                                                    ? AppColors.darkSurfacePastel
                                                    : const Color(0xFF17161B)),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color: isMono
                                                  ? (isDark
                                                      ? const Color(0xFF323238)
                                                      : const Color(0x1F000000))
                                                  : (isDark
                                                      ? AppColors
                                                          .darkBorderPastel
                                                      : const Color(0x22FFFFFF)),
                                              width: 0.8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                    alpha: isDark ? 0.35 : 0.08),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppStrings.successRateTitle,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '$interviewRate%',
                                                          style: TextStyle(
                                                            color: isMono
                                                                ? Colors.white
                                                                : AppColors
                                                                    .pastelSky,
                                                            fontSize: 26,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            letterSpacing: -0.8,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          AppStrings
                                                              .interviewCallsRate,
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                    alpha: 0.85),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 1,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.25),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '$successRate%',
                                                          style: TextStyle(
                                                            color: isMono
                                                                ? Colors.white
                                                                : AppColors
                                                                    .pastelLime,
                                                            fontSize: 26,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            letterSpacing: -0.8,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          AppStrings.hiredRate,
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withValues(
                                                                    alpha: 0.85),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        // KPI Bento Rows 2x2 with Neo-Pastel accents
                                        Row(
                                          children: [
                                            Expanded(
                                              child: MetricCard(
                                                label: AppStrings
                                                    .totalApplicationsMetric,
                                                value: '$total',
                                                icon:
                                                    CupertinoIcons.doc_text_fill,
                                                accentColor: AppColors.pastelLime,
                                                backgroundColor: isMono
                                                    ? null
                                                    : AppColors.pastelLime,
                                                foregroundColor: isMono
                                                    ? null
                                                    : AppColors.textOnPastel,
                                                border: isMono
                                                    ? null
                                                    : Border.all(
                                                        color:
                                                            Colors.transparent),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: MetricCard(
                                                label: AppStrings
                                                    .interviewStageMetric,
                                                value: '$interview',
                                                icon: CupertinoIcons.mic_fill,
                                                accentColor:
                                                    AppColors.pastelLavender,
                                                backgroundColor: isMono
                                                    ? null
                                                    : AppColors.pastelLavender,
                                                foregroundColor: isMono
                                                    ? null
                                                    : AppColors.textOnPastel,
                                                border: isMono
                                                    ? null
                                                    : Border.all(
                                                        color:
                                                            Colors.transparent),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: MetricCard(
                                                label:
                                                    AppStrings.offeringMetric,
                                                value: '$offering',
                                                icon: CupertinoIcons.gift_fill,
                                                accentColor: AppColors.pastelSky,
                                                backgroundColor: isMono
                                                    ? null
                                                    : AppColors.pastelSky,
                                                foregroundColor: isMono
                                                    ? null
                                                    : AppColors.textOnPastel,
                                                border: isMono
                                                    ? null
                                                    : Border.all(
                                                        color:
                                                            Colors.transparent),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: MetricCard(
                                                label: AppStrings.hiredMetric,
                                                value: '$accepted',
                                                icon: CupertinoIcons
                                                    .checkmark_seal_fill,
                                                accentColor: AppColors.pastelMint,
                                                backgroundColor: isMono
                                                    ? null
                                                    : AppColors.pastelMint,
                                                foregroundColor: isMono
                                                    ? null
                                                    : AppColors.textOnPastel,
                                                border: isMono
                                                    ? null
                                                    : Border.all(
                                                        color:
                                                            Colors.transparent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Status Breakdown Card
                                    NotchedCard(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.statusDistribution,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildProgressBarRow(
                                              'Applied',
                                              applied,
                                              total,
                                              isMono
                                                  ? const Color(0xFF71717A)
                                                  : AppColors.pastelLime,
                                              isDark),
                                          const SizedBox(height: 12),
                                          _buildProgressBarRow(
                                              'Interview',
                                              interview,
                                              total,
                                              isMono
                                                  ? const Color(0xFFA1A1AA)
                                                  : AppColors.pastelSky,
                                              isDark),
                                          const SizedBox(height: 12),
                                          _buildProgressBarRow(
                                              'Offering',
                                              offering,
                                              total,
                                              isMono
                                                  ? const Color(0xFFD4D4D8)
                                                  : AppColors.pastelMint,
                                              isDark),
                                          const SizedBox(height: 12),
                                          _buildProgressBarRow(
                                              'Accepted',
                                              accepted,
                                              total,
                                              isMono
                                                  ? (isDark
                                                      ? Colors.white
                                                      : const Color(0xFF18181B))
                                                  : AppColors.pastelLavender,
                                              isDark),
                                          const SizedBox(height: 12),
                                          _buildProgressBarRow(
                                              'Rejected',
                                              rejected,
                                              total,
                                              isMono
                                                  ? const Color(0xFF52525B)
                                                  : AppColors.pastelCoral,
                                              isDark),
                                          const SizedBox(height: 12),
                                          _buildProgressBarRow(
                                              'No Response',
                                              noResponse,
                                              total,
                                              isMono
                                                  ? const Color(0xFF3F3F46)
                                                  : (isDark
                                                      ? const Color(0xFF666472)
                                                      : const Color(0xFF9896A4)),
                                              isDark),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    // Work System Distribution Card
                                    NotchedCard(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.workSystemDistribution,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          if (byWorkSystem.isEmpty)
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: Text(
                                                  AppStrings.noWorkSystemData,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark
                                                          ? AppColors
                                                              .textHintDark
                                                          : AppColors
                                                              .textHint),
                                                ),
                                              ),
                                            )
                                          else
                                            ...byWorkSystem.entries.map((entry) {
                                              final count = entry.value as int;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: _buildProgressBarRow(
                                                  entry.key,
                                                  count,
                                                  total,
                                                  isMono
                                                      ? (isDark
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF18181B))
                                                      : AppColors.pastelSky,
                                                  isDark,
                                                ),
                                              );
                                            }),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Portal Breakdown Card
                                    NotchedCard(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.portalSources,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          if (byPortal.isEmpty)
                                            Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: Text(
                                                  AppStrings.noPortalData,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark
                                                          ? AppColors
                                                              .textHintDark
                                                          : AppColors
                                                              .textHint),
                                                ),
                                              ),
                                            )
                                          else
                                            ...byPortal.entries.map((entry) {
                                              final count = entry.value as int;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: _buildProgressBarRow(
                                                  entry.key,
                                                  count,
                                                  total,
                                                  isMono
                                                      ? (isDark
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF18181B))
                                                      : AppColors.pastelLime,
                                                  isDark,
                                                ),
                                              );
                                            }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBarRow(
      String label, int count, int total, Color color, bool isDark) {
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final percentage = (ratio * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
