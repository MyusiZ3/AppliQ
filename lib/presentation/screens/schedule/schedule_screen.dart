import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../applications/application_detail_screen.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/appliq_loading.dart';

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
    _dataSub?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final filteredItems = _scheduleItems.where((item) {
      if (!_upcomingOnly) return true;
      final log = item['log'] as ApplicationLog;
      if (log.scheduledAt == null) return false;
      return log.scheduledAt!.isAfter(now.subtract(const Duration(hours: 12)));
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Jadwal & Agenda',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Notched Pill Filter Switcher (Mendatang vs Semua)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NotchedPillCard<bool>(
              items: const [
                NotchedPillItem(
                  value: true,
                  label: 'Mendatang',
                  icon: CupertinoIcons.calendar_today,
                ),
                NotchedPillItem(
                  value: false,
                  label: 'Semua Agenda',
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
                : filteredItems.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () =>
                            _loadSchedules(forceRefresh: true),
                        child: EmptyStateView(
                          icon: CupertinoIcons.calendar_badge_plus,
                          title: _upcomingOnly
                              ? 'Tidak Ada Jadwal Mendatang'
                              : 'Belum Ada Riwayat Jadwal',
                          message: _upcomingOnly
                              ? 'Kamu belum memiliki agenda wawancara terdekat. Jadwal wawancara akan otomatis muncul di sini saat dicatat.'
                              : 'Belum ada tahapan interview atau deadline yang tersimpan.',
                          action: ElevatedButton.icon(
                            onPressed: () =>
                                _loadSchedules(forceRefresh: true),
                            icon: Icon(
                              CupertinoIcons.refresh,
                              size: 16,
                              color: isDark ? const Color(0xFF18181B) : Colors.white,
                            ),
                            label: Text(
                              'Perbarui Jadwal',
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
                    : RefreshIndicator(
                        onRefresh: () =>
                            _loadSchedules(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final app = item['app'] as JobApplication;
                            final log = item['log'] as ApplicationLog;

                            return RepaintBoundary(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    width: 0.8,
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Text(
                                            log.result,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${app.positionTitle} • ${app.companyName}',
                                      style: TextStyle(
                                        fontSize: 13,
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
                                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _scheduleDateFormat.format(log.scheduledAt!),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                                            'Pewawancara: ${log.interviewerName}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (log.meetingLink != null && log.meetingLink!.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () => launchUrl(
                                          Uri.parse(log.meetingLink!),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                        borderRadius: BorderRadius.circular(100),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(CupertinoIcons.video_camera_solid, size: 15, color: AppColors.primary),
                                              SizedBox(width: 6),
                                              Text(
                                                'Buka Link Pertemuan',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
