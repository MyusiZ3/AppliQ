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

  Future<void> _loadSchedules(
      {bool isSilent = false, bool forceRefresh = false}) async {
    if (!isSilent) setState(() => _isLoading = true);
    try {
      final apps =
          await widget.repository.getApplications(forceRefresh: forceRefresh);
      final items = <Map<String, dynamic>>[];

      for (var app in apps) {
        final logs = await widget.repository
            .getApplicationLogs(app.id, forceRefresh: forceRefresh);
        for (var log in logs) {
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
          'Jadwal Wawancara',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: NotchedPillCard<bool>(
              items: const [
                NotchedPillItem(
                  value: true,
                  label: 'Jadwal Mendatang',
                  icon: CupertinoIcons.calendar_today,
                ),
                NotchedPillItem(
                  value: false,
                  label: 'Semua Riwayat',
                  icon: CupertinoIcons.clock,
                ),
              ],
              selectedValue: _upcomingOnly,
              onValueChanged: (val) => setState(() => _upcomingOnly = val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filteredItems.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => _loadSchedules(forceRefresh: true),
                        child: EmptyStateView(
                          icon: CupertinoIcons.calendar_badge_minus,
                          title: _upcomingOnly
                              ? 'Tidak Ada Jadwal Mendatang'
                              : 'Belum Ada Jadwal Wawancara',
                          message: _upcomingOnly
                              ? 'Tidak ada agenda wawancara terdekat. Ketuk "Semua Riwayat" untuk melihat riwayat sebelumnya.'
                              : 'Jadwal wawancara yang kamu catat pada rincian lamaran akan muncul rapi di sini.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadSchedules(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 130),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final app = item['app'] as JobApplication;
                            final log = item['log'] as ApplicationLog;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.stageName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(100),
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
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (log.scheduledAt != null)
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.clock,
                                          size: 14,
                                          color: isDark
                                              ? AppColors.textHintDark
                                              : AppColors.textHint,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('EEEE, dd MMM yyyy, HH:mm')
                                              .format(log.scheduledAt!),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (log.interviewerName != null) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.person,
                                          size: 14,
                                          color: isDark
                                              ? AppColors.textHintDark
                                              : AppColors.textHint,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Pewawancara: ${log.interviewerName}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (log.meetingLink != null &&
                                      log.meetingLink!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () => launchUrl(
                                        Uri.parse(log.meetingLink!),
                                        mode: LaunchMode.externalApplication,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                                CupertinoIcons
                                                    .video_camera_solid,
                                                size: 15,
                                                color: AppColors.primary),
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
