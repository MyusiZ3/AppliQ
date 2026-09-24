import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../applications/application_detail_screen.dart';
import '../applications/application_form_screen.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/appliq_loading.dart';
import '../../../core/utils/calendar_helper.dart';

class ScheduleScreen extends StatefulWidget {
  final JobRepository repository;

  const ScheduleScreen({super.key, required this.repository});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _scheduleItems = [];
  bool _isLoading = true;
  bool _upcomingOnly = true;
  StreamSubscription? _dataSub;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _dataSub = widget.repository.dataChanges.listen((_) {
      if (mounted) _loadSchedules(isSilent: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dataSub?.cancel();
    super.dispose();
  }

  void closeSearch() {
    if (_isSearchOpen && mounted) {
      setState(() {
        _isSearchOpen = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  static final DateFormat _scheduleDateFormat = DateFormat('EEEE, dd MMM yyyy, HH:mm');

  Future<void> _loadSchedules(
      {bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        widget.repository.getApplications(forceRefresh: forceRefresh),
        widget.repository.getAllApplicationLogs(forceRefresh: forceRefresh),
      ]);

      final apps = (results[0] as List<JobApplication>?) ?? [];
      final logs = (results[1] as List<ApplicationLog>?) ?? [];
      final appMap = {for (var a in apps) a.id: a};
      final items = <Map<String, dynamic>>[];

      for (var log in logs) {
        final app = appMap[log.applicationId];
        if (app != null) {
          items.add({
            'app': app,
            'log': log,
          });
        }
      }

      items.sort((a, b) {
        final dateA =
            (a['log'] as ApplicationLog).scheduledAt ?? DateTime(2099);
        final dateB =
            (b['log'] as ApplicationLog).scheduledAt ?? DateTime(2099);
        return dateA.compareTo(dateB);
      });

      if (mounted) {
        setState(() {
          _scheduleItems = items;
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

  String _lastScheduleQuery = '';
  bool _lastUpcomingOnly = true;
  int _lastScheduleHash = 0;
  List<Map<String, dynamic>> _cachedFilteredSchedules = [];

  List<Map<String, dynamic>> _getFilteredSchedules(DateTime now) {
    final currentHash = Object.hash(_scheduleItems.length, _scheduleItems.isNotEmpty ? _scheduleItems.first['app'] : 0);
    if (_cachedFilteredSchedules.isNotEmpty &&
        _lastScheduleQuery == _searchQuery &&
        _lastUpcomingOnly == _upcomingOnly &&
        _lastScheduleHash == currentHash) {
      return _cachedFilteredSchedules;
    }

    final query = _searchQuery.trim().toLowerCase();
    final list = _scheduleItems.where((item) {
      final app = item['app'] as JobApplication;
      final log = item['log'] as ApplicationLog;

      if (_upcomingOnly) {
        if (log.scheduledAt == null) return false;
        if (!log.scheduledAt!.isAfter(now.subtract(const Duration(hours: 12)))) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final matchesCompany = app.companyName.toLowerCase().contains(query);
        final matchesPosition = app.positionTitle.toLowerCase().contains(query);
        final matchesStage = log.stageName.toLowerCase().contains(query);
        final matchesInterviewer = log.interviewerName?.toLowerCase().contains(query) ?? false;
        final matchesNotes = log.notes?.toLowerCase().contains(query) ?? false;
        final matchesResult = log.result.toLowerCase().contains(query);

        if (!matchesCompany &&
            !matchesPosition &&
            !matchesStage &&
            !matchesInterviewer &&
            !matchesNotes &&
            !matchesResult) {
          return false;
        }
      }

      return true;
    }).toList();

    _lastScheduleQuery = _searchQuery;
    _lastUpcomingOnly = _upcomingOnly;
    _lastScheduleHash = currentHash;
    _cachedFilteredSchedules = list;

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final filteredItems = _getFilteredSchedules(now);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Standardized Top Header Row
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.scheduleTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        letterSpacing: -0.7,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircleActionButton(
                        icon: _isSearchOpen ? CupertinoIcons.xmark : CupertinoIcons.search,
                        isDark: isDark,
                        isActive: _isSearchOpen,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) {
                              _searchQuery = '';
                              _searchController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildCircleActionButton(
                        icon: CupertinoIcons.plus,
                        isDark: isDark,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          closeSearch();
                          final added = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationFormScreen(repository: widget.repository),
                            ),
                          );
                          if (added == true) _loadSchedules();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Collapsible Search Bar (Only appears when search icon is clicked)
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.searchScheduleHint,
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        size: 17,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16),
                              color: isDark ? AppColors.textHintDark : AppColors.textHint,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            // Notched Pill Filter Switcher (Mendatang vs Semua)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: NotchedPillCard<bool>(
                items: [
                  NotchedPillItem(
                    value: true,
                    label: AppStrings.upcomingTab,
                    icon: CupertinoIcons.calendar_today,
                  ),
                  NotchedPillItem(
                    value: false,
                    label: AppStrings.allAgendaTab,
                    icon: CupertinoIcons.list_bullet,
                  ),
                ],
                selectedValue: _upcomingOnly,
                onValueChanged: (val) => setState(() => _upcomingOnly = val),
              ),
            ),

            // Schedule List Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: AppliqLoading(),
                      ),
                    )
                  : _scheduleItems.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () =>
                              _loadSchedules(forceRefresh: true),
                          child: EmptyStateView(
                            icon: CupertinoIcons.calendar_badge_plus,
                            title: AppStrings.noScheduleTitle,
                            message: AppStrings.noScheduleMessage,
                            action: ElevatedButton.icon(
                              onPressed: () =>
                                  _loadSchedules(forceRefresh: true),
                              icon: Icon(
                                CupertinoIcons.refresh,
                                size: 16,
                                color: isDark ? const Color(0xFF18181B) : Colors.white,
                              ),
                              label: Text(
                                AppStrings.refreshSchedule,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
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
                      : _buildGroupedScheduleList(context, isDark, filteredItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7)),
            width: 0.8,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                : (isDark ? Colors.white : const Color(0xFF18181B)),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedScheduleList(BuildContext context, bool isDark, List<Map<String, dynamic>> itemsList) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final endOfWeek = startOfToday.add(const Duration(days: 7));

    final overdueItems = <Map<String, dynamic>>[];
    final todayItems = <Map<String, dynamic>>[];
    final thisWeekItems = <Map<String, dynamic>>[];
    final upcomingItems = <Map<String, dynamic>>[];
    final pastHistoryItems = <Map<String, dynamic>>[];

    for (var item in itemsList) {
      final log = item['log'] as ApplicationLog;
      final date = log.scheduledAt;
      if (date == null) {
        if (!_upcomingOnly) pastHistoryItems.add(item);
        continue;
      }

      if (date.isBefore(startOfToday)) {
        if (_upcomingOnly) {
          // If overdue but still pending in upcoming view, show in Overdue group
          overdueItems.add(item);
        } else {
          pastHistoryItems.add(item);
        }
      } else if (date.isBefore(endOfToday)) {
        todayItems.add(item);
      } else if (date.isBefore(endOfWeek)) {
        thisWeekItems.add(item);
      } else {
        upcomingItems.add(item);
      }
    }

    final totalVisible = overdueItems.length +
        todayItems.length +
        thisWeekItems.length +
        upcomingItems.length +
        pastHistoryItems.length;

    if (totalVisible == 0) {
      if (_searchQuery.isNotEmpty) {
        return RefreshIndicator(
          onRefresh: () => _loadSchedules(forceRefresh: true),
          child: EmptyStateView(
            icon: CupertinoIcons.search,
            title: AppStrings.noScheduleFoundTitle,
            message: AppStrings.noScheduleFoundMessage(_searchQuery),
            action: ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: Icon(
                CupertinoIcons.clear,
                size: 16,
                color: isDark ? const Color(0xFF18181B) : Colors.white,
              ),
              label: Text(
                AppStrings.resetSearch,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _loadSchedules(forceRefresh: true),
        child: EmptyStateView(
          icon: CupertinoIcons.calendar_today,
          title: _upcomingOnly ? AppStrings.noUpcomingScheduleTitle : AppStrings.noScheduleTitle,
          message: _upcomingOnly
              ? AppStrings.noUpcomingScheduleMessage
              : AppStrings.noPastScheduleMessage,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadSchedules(forceRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
        children: [
          if (overdueItems.isNotEmpty)
            _buildSection(
              title: AppStrings.sectionOverdue,
              subtitle: AppStrings.sectionOverdueSubtitle,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              accentColor: const Color(0xFFEF4444),
              items: overdueItems,
              isDark: isDark,
              isOverdue: true,
            ),
          if (todayItems.isNotEmpty)
            _buildSection(
              title: AppStrings.sectionToday,
              subtitle: AppStrings.sectionTodaySubtitle,
              icon: CupertinoIcons.flame_fill,
              accentColor: const Color(0xFF10B981),
              items: todayItems,
              isDark: isDark,
            ),
          if (thisWeekItems.isNotEmpty)
            _buildSection(
              title: AppStrings.sectionThisWeek,
              subtitle: AppStrings.sectionThisWeekSubtitle,
              icon: CupertinoIcons.calendar_today,
              accentColor: const Color(0xFF3B82F6),
              items: thisWeekItems,
              isDark: isDark,
            ),
          if (upcomingItems.isNotEmpty)
            _buildSection(
              title: AppStrings.sectionUpcoming,
              subtitle: AppStrings.sectionUpcomingSubtitle,
              icon: CupertinoIcons.hourglass,
              accentColor: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              items: upcomingItems,
              isDark: isDark,
            ),
          if (!_upcomingOnly && pastHistoryItems.isNotEmpty)
            _buildSection(
              title: AppStrings.sectionHistory,
              subtitle: AppStrings.sectionHistorySubtitle,
              icon: CupertinoIcons.archivebox_fill,
              accentColor: isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
              items: pastHistoryItems,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Map<String, dynamic>> items,
    required bool isDark,
    bool isOverdue = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10, left: 4, right: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: accentColor),
                    const SizedBox(width: 5),
                    Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${items.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildScheduleCard(item, isDark, isOverdue)),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item, bool isDark, bool isOverdue) {
    final app = item['app'] as JobApplication;
    final log = item['log'] as ApplicationLog;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          closeSearch();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ApplicationDetailScreen(
                applicationId: app.id,
                repository: widget.repository,
              ),
            ),
          );
          _loadSchedules(isSilent: true);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOverdue
                  ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isOverdue ? 1.2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      log.stageName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final badgeColor = _getLogResultColor(log.result, isOverdue: isOverdue);
                      final badgeLabel = isOverdue ? AppStrings.sectionOverdue : AppStrings.localizedResult(log.result);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${app.positionTitle} • ${app.companyName}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (log.scheduledAt != null)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 14,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : (isDark ? AppColors.textHintDark : AppColors.textHint),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _scheduleDateFormat.format(log.scheduledAt!),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              if (log.interviewerName != null && log.interviewerName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.person,
                      size: 14,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.interviewerPrefix}${log.interviewerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (log.meetingLink != null && log.meetingLink!.isNotEmpty)
                    GestureDetector(
                      onTap: () => UIHelper.openUrl(context, log.meetingLink),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.video_camera_solid,
                                size: 15, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.openMeetingRoom,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (log.scheduledAt != null)
                    GestureDetector(
                      onTap: () {
                        CalendarHelper.syncScheduleToCalendar(
                          context: context,
                          companyName: app.companyName,
                          positionTitle: app.positionTitle,
                          stageName: log.stageName,
                          scheduledAt: log.scheduledAt!,
                          meetingLink: log.meetingLink,
                          interviewer: log.interviewerName,
                          notes: log.notes,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF27272A)
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.calendar_badge_plus,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFFE4E4E7)
                                  : const Color(0xFF18181B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.syncToCalendar,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFE4E4E7)
                                    : const Color(0xFF18181B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLogResultColor(String result, {bool isOverdue = false}) {
    if (isOverdue) return const Color(0xFFEF4444);
    switch (result.trim().toLowerCase()) {
      case 'lolos':
      case 'selesai':
      case 'passed':
      case 'done':
        return const Color(0xFF10B981);
      case 'diterima':
      case 'offering':
      case 'accepted':
        return const Color(0xFF059669);
      case 'gagal':
      case 'ditolak':
      case 'failed':
      case 'rejected':
      case 'tidak lolos':
        return const Color(0xFFEF4444);
      case 'waiting':
      case 'menunggu':
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

