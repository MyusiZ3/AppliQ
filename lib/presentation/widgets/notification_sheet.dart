import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/job_application.dart';
import '../../data/models/application_log.dart';
import '../../services/notification_service.dart';
import '../../utils/language_manager.dart';
import '../../utils/theme_manager.dart';
import '../../utils/ui_helper.dart';
import '../widgets/hr_templates_sheet.dart';

class NotificationSheet extends StatefulWidget {
  final List<Map<String, dynamic>> upcomingSchedules;
  final List<JobApplication> staleApplications;

  const NotificationSheet({
    super.key,
    required this.upcomingSchedules,
    required this.staleApplications,
  });

  static void show(
    BuildContext context, {
    required List<Map<String, dynamic>> upcomingSchedules,
    required List<JobApplication> staleApplications,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSheet(
        upcomingSchedules: upcomingSchedules,
        staleApplications: staleApplications,
      ),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  bool _isTesting = false;

  Future<void> _testPushNotification() async {
    setState(() => _isTesting = true);
    HapticFeedback.mediumImpact();

    try {
      await NotificationService.instance.requestPermissions();
      final isEn = LanguageManager.isEnglish;
      await NotificationService.instance.showInstantNotification(
        id: 9999,
        title: isEn ? 'AppliQ • Reminder Notification' : 'AppliQ • Notifikasi Pengingat',
        body: isEn 
            ? 'Popup notification system active! Your interview reminders will appear automatically.' 
            : 'Sistem notifikasi popup aktif! Pengingat jadwal wawancara kamu akan muncul otomatis.',
      );

      if (mounted) {
        UIHelper.showSuccessSnackBar(
          context,
          AppStrings.testNotificationSentToast,
        );
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;
    final isEn = LanguageManager.isEnglish;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final totalAlerts = widget.upcomingSchedules.length + widget.staleApplications.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark: isDark, isMonochrome: isMono),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isMono
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                          : AppColors.pastelSky.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.bell_fill,
                      size: 18,
                      color: isMono
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : AppColors.pastelSky,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.notificationCenterTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        totalAlerts == 0
                            ? AppStrings.noUrgentReminders
                            : AppStrings.activeRemindersCount(totalAlerts),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 14,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Test Notification Action Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222226) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF333338) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.pushNotificationTestTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.pushNotificationTestDesc,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isTesting ? null : _testPushNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMono
                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                        : AppColors.pastelLime,
                    foregroundColor: isMono
                        ? (isDark ? const Color(0xFF18181B) : Colors.white)
                        : AppColors.textOnPastel,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _isTesting
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isMono
                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                : AppColors.textOnPastel,
                          ),
                        )
                      : Text(
                          AppStrings.testNotificationButton,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable List of Active Reminders
          Flexible(
            child: ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                // Upcoming Interview Schedules
                if (widget.upcomingSchedules.isNotEmpty) ...[
                  Text(
                    AppStrings.interviewAgendaSection,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.upcomingSchedules.map((item) {
                    final app = item['app'] as JobApplication;
                    final log = item['log'] as ApplicationLog;
                    final date = log.scheduledAt!;
                    final timeStr = DateFormat('dd MMM, HH:mm').format(date);
                    final formattedTime = isEn ? timeStr : '$timeStr WIB';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.calendar,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${app.companyName} • ${log.stageName}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${AppStrings.scheduleDateLabel}: $formattedTime',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Follow-up Alerts (> 7 Days)
                if (widget.staleApplications.isNotEmpty) ...[
                  Text(
                    AppStrings.followUpNeededSection,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.staleApplications.map((app) {
                    final days = DateTime.now().difference(app.appliedDate).inDays;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.clock_fill,
                              size: 18,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.companyName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${app.positionTitle} • ${AppStrings.appliedDaysAgo(days)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              HrTemplatesSheet.show(
                                context,
                                defaultCompanyName: app.companyName,
                                defaultPosition: app.positionTitle,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : const Color(0xFF18181B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.emailHrButton,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (totalAlerts == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 40,
                            color: const Color(0xFF059669).withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.allSchedulesSafeTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.allSchedulesSafeDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
