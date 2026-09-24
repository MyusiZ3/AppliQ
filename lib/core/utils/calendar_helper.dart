import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../../utils/ui_helper.dart';

class CalendarHelper {
  /// Format a DateTime to Google Calendar UTC ISO format: yyyyMMddTHHmmssZ
  static String formatUtcForCalendar(DateTime dt) {
    final utc = dt.toUtc();
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(utc);
  }

  /// Open Google Calendar URL Template with pre-filled event details
  static Future<bool> openGoogleCalendar({
    required String title,
    required DateTime start,
    DateTime? end,
    String? details,
    String? location,
  }) async {
    final endTime = end ?? start.add(const Duration(hours: 1));
    final startFormatted = formatUtcForCalendar(start);
    final endFormatted = formatUtcForCalendar(endTime);

    final queryParams = <String, String>{
      'action': 'TEMPLATE',
      'text': title,
      'dates': '$startFormatted/$endFormatted',
    };

    if (details != null && details.trim().isNotEmpty) {
      queryParams['details'] = details.trim();
    }
    if (location != null && location.trim().isNotEmpty) {
      queryParams['location'] = location.trim();
    }

    final uri = Uri(
      scheme: 'https',
      host: 'calendar.google.com',
      path: '/calendar/render',
      queryParameters: queryParams,
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (_) {}

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launched) return true;
    } catch (_) {}

    return false;
  }

  /// One-click helper to sync a job application stage/interview schedule to calendar
  static Future<void> syncScheduleToCalendar({
    required BuildContext context,
    required String companyName,
    required String positionTitle,
    required String stageName,
    required DateTime scheduledAt,
    String? meetingLink,
    String? interviewer,
    String? notes,
  }) async {
    HapticFeedback.lightImpact();

    final title = '[AppliQ] $stageName: $companyName - $positionTitle';

    final detailsBuffer = StringBuffer();
    detailsBuffer.writeln('📋 Posisi: $positionTitle');
    detailsBuffer.writeln('🏢 Perusahaan: $companyName');
    detailsBuffer.writeln('🎯 Tahap: $stageName');

    if (interviewer != null && interviewer.trim().isNotEmpty) {
      detailsBuffer.writeln('👤 Pewawancara: $interviewer');
    }
    if (meetingLink != null && meetingLink.trim().isNotEmpty) {
      detailsBuffer.writeln('🔗 Meeting Link: $meetingLink');
    }
    if (notes != null && notes.trim().isNotEmpty) {
      detailsBuffer.writeln('📝 Catatan: $notes');
    }
    detailsBuffer.writeln('\n---\n📅 Disinkronkan melalui AppliQ Job Tracker');

    final location = (meetingLink != null && meetingLink.trim().isNotEmpty)
        ? meetingLink.trim()
        : companyName;

    final success = await openGoogleCalendar(
      title: title,
      start: scheduledAt,
      end: scheduledAt.add(const Duration(hours: 1)),
      details: detailsBuffer.toString(),
      location: location,
    );

    if (context.mounted) {
      if (success) {
        UIHelper.showSuccessSnackBar(context, AppStrings.calendarSyncSuccess);
      } else {
        UIHelper.showErrorSnackBar(
            context, 'Gagal membuka kalender. Pastikan browser atau Google Calendar terpasang.');
      }
    }
  }
}
