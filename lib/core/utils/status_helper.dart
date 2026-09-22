import 'package:flutter/material.dart';
import '../../utils/language_manager.dart';
import '../constants/app_colors.dart';
import '../constants/app_enums.dart';

class StatusHelper {
  static String getFeedbackText(ApplicationStatus status, DateTime appliedDate) {
    final isEn = LanguageManager.isEnglish;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final applied = DateTime(appliedDate.year, appliedDate.month, appliedDate.day);
    final diffDays = today.difference(applied).inDays;

    if (status == ApplicationStatus.applied) {
      if (diffDays <= 0) {
        return isEn ? 'Submitted today' : 'Dikirim hari ini';
      } else if (diffDays <= 30) {
        return isEn ? 'Submitted $diffDays day${diffDays > 1 ? 's' : ''} ago' : 'Dikirim $diffDays hari yang lalu';
      } else {
        return isEn ? 'No response for > 30 days' : 'Tidak ada respon > 30 hari';
      }
    } else if (status == ApplicationStatus.rejected || status == ApplicationStatus.noResponse) {
      return isEn ? 'Stay motivated, more opportunities await!' : 'Semangat, masih ada kesempatan lainnya';
    } else {
      return isEn ? 'You are currently in ${status.label} stage' : 'Kamu sedang dalam tahap ${status.label}';
    }
  }

  static Color getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.statusApplied;
      case ApplicationStatus.interview:
        return AppColors.statusInterview;
      case ApplicationStatus.offering:
        return AppColors.statusOffering;
      case ApplicationStatus.accepted:
        return AppColors.statusAccepted;
      case ApplicationStatus.rejected:
        return AppColors.statusRejected;
      case ApplicationStatus.noResponse:
        return AppColors.statusNoResponse;
    }
  }
}
