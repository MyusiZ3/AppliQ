import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/status_helper.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/models/user_resume.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/google_drive_service.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/appliq_loading.dart';
import '../../../core/utils/calendar_helper.dart';
import '../profile/document_preview_screen.dart';
import 'application_form_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  final JobRepository repository;

  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
    required this.repository,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  JobApplication? _application;
  List<ApplicationLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apps = await widget.repository.getApplications();
      final app = apps.firstWhere((a) => a.id == widget.applicationId);
      final logs = await widget.repository.getApplicationLogs(widget.applicationId);
      setState(() {
        _application = app;
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.handleError(context, e);
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _updateStatus(ApplicationStatus newStatus) async {
    if (_application == null || _application!.status == newStatus) return;
    HapticFeedback.selectionClick();
    final prevApp = _application!;
    setState(() {
      _application = _application!.copyWith(status: newStatus);
    });

    try {
      final updated = prevApp.copyWith(status: newStatus);
      final saved = await widget.repository.updateApplication(updated);
      if (mounted) {
        setState(() => _application = saved);
        UIHelper.showSuccessSnackBar(
          context,
          LanguageManager.isEnglish
              ? 'Status updated to ${AppStrings.localizedStatus(newStatus)}'
              : 'Status diubah ke ${newStatus.label}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _application = prevApp);
        UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _deleteApplication() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppStrings.deleteApplicationConfirmTitle),
        content: Text(AppStrings.deleteApplicationConfirmMessage),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.repository.deleteApplication(widget.applicationId);
        if (mounted) {
          UIHelper.showSuccessSnackBar(context, AppStrings.successDeleted);
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _updateLogResult(ApplicationLog log, String newResult) async {
    final prevLogs = List<ApplicationLog>.from(_logs);
    final updated = log.copyWith(result: newResult);
    setState(() {
      final index = _logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _logs[index] = updated;
      }
    });

    try {
      await widget.repository.updateApplicationLog(updated);
      if (mounted) {
        UIHelper.showSuccessSnackBar(
          context,
          LanguageManager.isEnglish
              ? 'Stage "${log.stageName}" status set to ${AppStrings.localizedResult(newResult)}'
              : 'Status tahap "${log.stageName}" diubah ke $newResult',
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _logs = prevLogs);
        UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _showUpdateStageResultSheet(ApplicationLog log) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    HapticFeedback.lightImpact();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 20 + MediaQuery.of(ctx).padding.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.updateStageStatusTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.stageName} • ${_application?.companyName ?? ''}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                _buildStageOptionTile(
                  title: AppStrings.stageOptionPassed,
                  icon: CupertinoIcons.checkmark_circle_fill,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  isSelected: log.result == 'Lolos' || log.result == 'Selesai' || log.result == 'Passed',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateLogResult(log, 'Lolos');
                  },
                ),
                const SizedBox(height: 8),

                _buildStageOptionTile(
                  title: AppStrings.stageOptionNext,
                  icon: CupertinoIcons.arrow_right_circle_fill,
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                  isSelected: false,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateLogResult(log, 'Lolos');
                    if (mounted) _showAddStageSheet();
                  },
                ),
                const SizedBox(height: 8),

                _buildStageOptionTile(
                  title: AppStrings.stageOptionOffering,
                  icon: CupertinoIcons.sparkles,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                  isSelected: log.result == 'Diterima' || log.result == 'Offering' || log.result == 'Accepted',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateLogResult(log, 'Diterima');
                    await _updateStatus(ApplicationStatus.offering);
                  },
                ),
                const SizedBox(height: 8),

                _buildStageOptionTile(
                  title: AppStrings.stageOptionWaiting,
                  icon: CupertinoIcons.hourglass,
                  color: isDark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF71717A),
                  isDark: isDark,
                  isSelected: log.result == 'Waiting' ||
                      log.result == 'Menunggu',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateLogResult(log, 'Waiting');
                  },
                ),
                const SizedBox(height: 8),

                _buildStageOptionTile(
                  title: AppStrings.stageOptionFailed,
                  icon: CupertinoIcons.xmark_circle_fill,
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                  isSelected: log.result == 'Gagal' ||
                      log.result == 'Ditolak' ||
                      log.result == 'Rejected' ||
                      log.result == 'Failed',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateLogResult(log, 'Gagal');
                    await _updateStatus(ApplicationStatus.rejected);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageOptionTile({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(CupertinoIcons.checkmark_alt, color: color, size: 18)
            else
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: isDark
                    ? AppColors.textHintDark
                    : AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  void _showAddStageSheet() => _showStageFormSheet();

  void _showEditStageSheet(ApplicationLog log) => _showStageFormSheet(logToEdit: log);

  Future<void> _showStageFormSheet({ApplicationLog? logToEdit}) async {
    final isEditing = logToEdit != null;
    final stageNameController =
        TextEditingController(text: logToEdit?.stageName ?? '');
    final interviewerController =
        TextEditingController(text: logToEdit?.interviewerName ?? '');
    final linkController =
        TextEditingController(text: logToEdit?.meetingLink ?? '');
    final notesController =
        TextEditingController(text: logToEdit?.notes ?? '');
    DateTime scheduledDate = logToEdit?.scheduledAt ??
        DateTime.now().add(const Duration(days: 1));
    String selectedResult = logToEdit?.result ?? 'Waiting';
    bool isSubmitting = false;

    final quickStages = [
      'HR Screening',
      'Technical Test',
      'User Interview',
      'Final Interview',
      'Offering Call',
    ];

    final resultsList = [
      'Waiting',
      'Lolos',
      'Selesai',
      'Diterima',
      'Gagal',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? AppColors.surfaceDark : Colors.white;
            final insetBg =
                isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
            final borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final badgeBg = isDark
                ? const Color(0xFF3F3F46)
                : const Color(0xFFE4E4E7);

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        // iOS Top Pill Indicator
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : Colors.black.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // iOS Nav Header: [Batal] [Judul] [Simpan]
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: isSubmitting
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 4),
                                  child: Text(
                                    AppStrings.cancel,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                isEditing
                                    ? (LanguageManager.isEnglish ? 'Edit Stage' : 'Edit Tahap')
                                    : (LanguageManager.isEnglish ? 'New Stage' : 'Tahap Baru'),
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (isSubmitting ||
                                        stageNameController.text
                                            .trim()
                                            .isEmpty)
                                    ? null
                                    : () async {
                                        if (stageNameController.text
                                            .trim()
                                            .isEmpty) {
                                          return;
                                        }

                                        setSheetState(
                                            () => isSubmitting = true);
                                        HapticFeedback.mediumImpact();

                                        try {
                                          if (isEditing) {
                                            final updatedLog =
                                                logToEdit.copyWith(
                                              stageName: stageNameController
                                                  .text
                                                  .trim(),
                                              scheduledAt: scheduledDate,
                                              interviewerName:
                                                  interviewerController
                                                          .text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : interviewerController
                                                          .text
                                                          .trim(),
                                              meetingLink: linkController
                                                      .text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : linkController.text
                                                      .trim(),
                                              notes: notesController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : notesController.text
                                                      .trim(),
                                              result: selectedResult,
                                            );
                                            await widget.repository
                                                .updateApplicationLog(
                                                    updatedLog);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              UIHelper.showSuccessSnackBar(
                                                  context,
                                                  LanguageManager.isEnglish
                                                      ? 'Recruitment stage updated successfully'
                                                      : 'Tahap rekrutmen berhasil diperbarui');
                                            }
                                          } else {
                                            final log = ApplicationLog(
                                              id: '',
                                              applicationId:
                                                  widget.applicationId,
                                              userId: '',
                                              stageName: stageNameController
                                                  .text
                                                  .trim(),
                                              scheduledAt: scheduledDate,
                                              interviewerName:
                                                  interviewerController
                                                          .text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : interviewerController
                                                          .text
                                                          .trim(),
                                              meetingLink: linkController
                                                      .text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : linkController.text
                                                      .trim(),
                                              notes: notesController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : notesController.text
                                                      .trim(),
                                              result: selectedResult,
                                            );
                                            await widget.repository
                                                .createApplicationLog(log);
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              UIHelper.showSuccessSnackBar(
                                                  context,
                                                  LanguageManager.isEnglish
                                                      ? 'Interview stage added successfully'
                                                      : 'Tahap wawancara berhasil ditambahkan');
                                            }
                                          }
                                          _loadData();
                                        } catch (e) {
                                          if (context.mounted) {
                                            setSheetState(
                                                () => isSubmitting = false);
                                            UIHelper.handleError(context, e);
                                          }
                                        }
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 4),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF18181B),
                                          ),
                                        )
                                      : Text(
                                          AppStrings.save,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: stageNameController
                                                    .text
                                                    .trim()
                                                    .isNotEmpty
                                                ? (isDark
                                                    ? Colors.white
                                                    : const Color(
                                                        0xFF18181B))
                                                : (isDark
                                                    ? AppColors.textHintDark
                                                    : AppColors.textHint),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.8,
                          color: borderColor,
                        ),
                        const SizedBox(height: 18),

                        // Section 1: TIPE TAHAP
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            LanguageManager.isEnglish ? 'STAGE TYPE' : 'TIPE TAHAP',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: insetBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: borderColor, width: 0.8),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: quickStages.map((stage) {
                                  final isSelected =
                                      stageNameController.text.trim() ==
                                          stage;
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setSheetState(() {
                                        stageNameController.text = stage;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark
                                                ? const Color(0xFF3F3F46)
                                                : const Color(0xFF18181B))
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(
                                                          alpha: isDark
                                                              ? 0.3
                                                              : 0.12),
                                                  blurRadius: 6,
                                                  offset:
                                                      const Offset(0, 2),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        stage,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          letterSpacing: -0.2,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                  ? AppColors
                                                      .textSecondaryDark
                                                  : AppColors.textSecondary),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 2: INFORMASI UTAMA
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            LanguageManager.isEnglish ? 'MAIN INFORMATION' : 'INFORMASI UTAMA',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Inset Grouped Form Card
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: insetBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: borderColor, width: 0.8),
                            ),
                            child: Column(
                              children: [
                                // Nama Tahap
                                _buildInsetRow(
                                  icon: CupertinoIcons.layers_fill,
                                  badgeBg: badgeBg,
                                  isDark: isDark,
                                  child: TextField(
                                    controller: stageNameController,
                                    onChanged: (_) =>
                                        setSheetState(() {}),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: LanguageManager.isEnglish
                                          ? 'Stage name (e.g. HR Interview)'
                                          : 'Nama tahap (misal: HR Interview)',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 52,
                                    color: borderColor),

                                // Pewawancara
                                _buildInsetRow(
                                  icon: CupertinoIcons.person_fill,
                                  badgeBg: badgeBg,
                                  isDark: isDark,
                                  child: TextField(
                                    controller: interviewerController,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: LanguageManager.isEnglish
                                          ? 'Interviewer (e.g. Sarah)'
                                          : 'Pewawancara (misal: Ibu Sarah)',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 52,
                                    color: borderColor),

                                // Jadwal & Waktu Tile
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    HapticFeedback.selectionClick();
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: scheduledDate,
                                      firstDate: DateTime.now().subtract(
                                          const Duration(days: 30)),
                                      lastDate: DateTime.now().add(
                                          const Duration(days: 180)),
                                    );
                                    if (pickedDate != null &&
                                        context.mounted) {
                                      final pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            scheduledDate),
                                      );
                                      if (pickedTime != null) {
                                        setSheetState(() {
                                          scheduledDate = DateTime(
                                            pickedDate.year,
                                            pickedDate.month,
                                            pickedDate.day,
                                            pickedTime.hour,
                                            pickedTime.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: _buildInsetRow(
                                    icon: CupertinoIcons.calendar,
                                    badgeBg: badgeBg,
                                    isDark: isDark,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            LanguageManager.isEnglish
                                                ? DateFormat('dd MMM yyyy, HH:mm').format(scheduledDate)
                                                : '${DateFormat('dd MMM yyyy, HH:mm').format(scheduledDate)} WIB',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? AppColors
                                                      .textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          Icon(
                                            CupertinoIcons.chevron_right,
                                            size: 14,
                                            color: isDark
                                                ? AppColors.textHintDark
                                                : AppColors.textHint,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 52,
                                    color: borderColor),

                                // Tautan Meeting / Lokasi
                                _buildInsetRow(
                                  icon: CupertinoIcons.videocam_fill,
                                  badgeBg: badgeBg,
                                  isDark: isDark,
                                  child: TextField(
                                    controller: linkController,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: LanguageManager.isEnglish
                                          ? 'Meeting Link / Zoom / Office Location'
                                          : 'Tautan Google Meet / Zoom / Lokasi',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                  ),
                                ),
                                Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 52,
                                    color: borderColor),

                                // Catatan / Kisi-kisi
                                _buildInsetRow(
                                  icon: CupertinoIcons.doc_text_fill,
                                  badgeBg: badgeBg,
                                  isDark: isDark,
                                  child: TextField(
                                    controller: notesController,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: LanguageManager.isEnglish
                                          ? 'Prep notes / questions to ask...'
                                          : 'Catatan / kisi-kisi persiapan...',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.textHintDark
                                            : AppColors.textHint,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Section 3: STATUS HASIL TAHAP
                        if (isEditing) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              LanguageManager.isEnglish ? 'STAGE RESULT STATUS' : 'STATUS HASIL TAHAP',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? AppColors.textHintDark
                                    : AppColors.textHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: insetBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: borderColor, width: 0.8),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: resultsList.map((res) {
                                    final isSelected = selectedResult == res;
                                    final resColor = _getLogResultColor(res);
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setSheetState(() => selectedResult = res);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? resColor.withValues(alpha: 0.18)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? resColor
                                                : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: resColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              AppStrings.localizedResult(res),
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? (isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF18181B))
                                                    : (isDark
                                                        ? AppColors
                                                            .textSecondaryDark
                                                        : AppColors
                                                            .textSecondary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInsetRow({
    required IconData icon,
    required Color badgeBg,
    required bool isDark,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 15,
              color: isDark ? Colors.white70 : const Color(0xFF52525B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _handleDeleteCvAttachment() async {
    final app = _application;
    if (app == null || app.cvFileUrl == null) return;

    HapticFeedback.lightImpact();

    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(AppStrings.manageAttachment),
        message: Text(app.cvFileName ?? (LanguageManager.isEnglish ? 'Google Drive Document' : 'Berkas Google Drive')),
        actions: [
          if (app.cvFileUrl != null && app.cvFileUrl!.isNotEmpty)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, 'delete_drive'),
              child: Text(AppStrings.deleteFromDrive),
            ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx, 'detach_only'),
            child: Text(AppStrings.detachOnly),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppStrings.cancel),
        ),
      ),
    );

    if (action == null) return;

    try {
      if (action == 'delete_drive') {
        await GoogleDriveService.deleteDocument(app.cvFileUrl!);
      }

      final updatedApp = app.copyWith(
        clearCvFile: true,
      );

      await widget.repository.updateApplication(updatedApp);

      if (mounted) {
        setState(() {
          _application = updatedApp;
        });
        UIHelper.showSuccessSnackBar(
          context,
          action == 'delete_drive'
              ? AppStrings.fileDeletedDrive
              : AppStrings.attachmentDetached,
        );
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  Future<void> _openCoverLetterGenerator() async {
    final app = _application;
    if (app == null) return;
    HapticFeedback.lightImpact();

    final resume = await widget.repository.getUserResume();
    if (!mounted) return;

    final baseResume = resume ??
        UserResume.empty(
          app.userId,
          fullName: 'Pelamar AppliQ',
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          resume: baseResume,
          initialTab: 1, // Surat Lamaran
          initialCompanyName: app.companyName,
          initialPosition: app.positionTitle,
          initialCompanyAddress: app.location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _application == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: AppliqLoading(),
          ),
        ),
      );
    }

    final app = _application!;
    final feedback = StatusHelper.getFeedbackText(app.status, app.appliedDate);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          color: isDark ? Colors.white : const Color(0xFF18181B),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.applicationDetailTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              CupertinoIcons.ellipsis_vertical,
              size: 20,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            elevation: 4,
            onSelected: (value) async {
              if (value == 'cover_letter') {
                _openCoverLetterGenerator();
              } else if (value == 'edit') {
                final updated = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ApplicationFormScreen(
                      repository: widget.repository,
                      applicationToEdit: app,
                    ),
                  ),
                );
                if (updated == true) _loadData();
              } else if (value == 'delete') {
                _deleteApplication();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'cover_letter',
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_plaintext,
                      size: 18,
                      color: ThemeManager.isMonochrome
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      LanguageManager.isEnglish ? 'Generate Cover Letter' : 'Buat Cover Letter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.pencil,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.edit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.trash,
                      size: 18,
                      color: AppColors.expense,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.delete,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 90),
        children: [
          // Header Card with Notch Pill
          NotchedCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 22,
            showTopNotch: true,
            showBottomNotch: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        app.positionTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(status: app.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  app.companyName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dynamic Feedback Alert Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StatusHelper.getStatusColor(app.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StatusHelper.getStatusColor(app.status).withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle_fill,
                        size: 16,
                        color: StatusHelper.getStatusColor(app.status),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: StatusHelper.getStatusColor(app.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Status Update Selector
                Text(
                  '${AppStrings.updateStatus}:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ApplicationStatus.values.map((st) {
                      final isSelected = app.status == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => _updateStatus(st),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? StatusHelper.getStatusColor(st)
                                  : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isSelected
                                    ? StatusHelper.getStatusColor(st)
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              AppStrings.localizedStatus(st),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                letterSpacing: -0.2,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detail Attributes Card
          Container(
            padding: const EdgeInsets.all(16),
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
                _buildInfoRow(AppStrings.appliedDateLabel, DateFormat('dd MMMM yyyy').format(app.appliedDate), CupertinoIcons.calendar, isDark),
                const Divider(height: 20),
                _buildInfoRow(AppStrings.workSystemLabel, AppStrings.localizedWorkSystem(app.workSystem), CupertinoIcons.briefcase, isDark),
                const Divider(height: 20),
                _buildInfoRow(AppStrings.jobSourceLabel, app.jobPortalCustom ?? AppStrings.localizedJobPortal(app.jobPortal), CupertinoIcons.globe, isDark),
                if (app.location != null && app.location!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildLocationBlock(app.location!, isDark),
                ],
                if (app.salaryExpectation != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(AppStrings.salaryExpectation, 'Rp ${NumberFormat('#,###').format(app.salaryExpectation)}', CupertinoIcons.creditcard, isDark),
                ],
                if (app.salaryOffered != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(AppStrings.salaryOffered, 'Rp ${NumberFormat('#,###').format(app.salaryOffered)}', CupertinoIcons.creditcard_fill, isDark),
                ],
                if (app.jobUrl != null && app.jobUrl!.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.link, size: 18, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                          const SizedBox(width: 8),
                          Text(AppStrings.jobUrlLabel, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 14),
                        label: Text(AppStrings.openUrl),
                        onPressed: () => UIHelper.openUrl(context, app.jobUrl),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (app.notes != null && app.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.notesTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.notes!,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Google Drive Document Attachment Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF27272A)
                                : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.cloud_upload_fill,
                            size: 15,
                            color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.attachedDriveFiles,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (app.cvFileName != null && app.cvFileName!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(CupertinoIcons.doc_fill, size: 18, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.cvFileName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'AppliQ / ${app.companyName}_${app.positionTitle}'.replaceAll(' ', '_'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (app.cvFileUrl != null && app.cvFileUrl!.isNotEmpty) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 15, color: Color(0xFF10B981)),
                              tooltip: AppStrings.openInDrive,
                              padding: EdgeInsets.zero,
                              onPressed: () => UIHelper.openUrl(context, app.cvFileUrl),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(CupertinoIcons.trash, size: 15, color: Color(0xFFEF4444)),
                              tooltip: AppStrings.delete,
                              padding: EdgeInsets.zero,
                              onPressed: _handleDeleteCvAttachment,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 14,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          AppStrings.noCvAttached,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recruitment Stage Timeline Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.recruitmentStages,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                label: Text(AppStrings.addStageBtn),
                onPressed: _showAddStageSheet,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_logs.isEmpty)
            NotchedCard(
              padding: const EdgeInsets.all(24),
              borderRadius: 20,
              child: Center(
                child: Text(
                  AppStrings.noStagesMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ),
            )
          else
            ..._logs.map((log) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NotchedCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.checkmark_seal_fill,
                                    size: 15,
                                    color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    log.stageName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      letterSpacing: -0.2,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Clickable Stage Result Badge
                          GestureDetector(
                            onTap: () => _showUpdateStageResultSheet(log),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLogResultColor(log.result).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: _getLogResultColor(log.result).withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppStrings.localizedResult(log.result),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _getLogResultColor(log.result),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 10,
                                    color: _getLogResultColor(log.result),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: Icon(
                              CupertinoIcons.ellipsis_vertical,
                              size: 16,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                                width: 0.8,
                              ),
                            ),
                            color: isDark
                                ? const Color(0xFF1E1E22)
                                : Colors.white,
                            elevation: 8,
                            onSelected: (value) async {
                              HapticFeedback.selectionClick();
                              if (value == 'edit') {
                                _showEditStageSheet(log);
                              } else if (value == 'delete') {
                                final confirm =
                                    await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (ctx) => CupertinoAlertDialog(
                                    title: Text(AppStrings.deleteStageConfirm),
                                    content: Text(
                                        AppStrings.deleteStageMsg(log.stageName)),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text(AppStrings.cancel),
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        child: Text(AppStrings.delete),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await widget.repository
                                        .deleteApplicationLog(log.id);
                                    UIHelper.showGlobalSuccessToast(
                                        AppStrings.stageDeletedSuccess);
                                    _loadData();
                                  } catch (e) {
                                    UIHelper.showGlobalErrorToast(
                                        UIHelper.parseErrorMessage(e));
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                height: 38,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.pencil,
                                      size: 15,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.editStage,
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
                              ),
                              const PopupMenuDivider(height: 1),
                              PopupMenuItem(
                                value: 'delete',
                                height: 38,
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.trash,
                                      size: 15,
                                      color: AppColors.expense,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.deleteStage,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.expense,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (log.scheduledAt != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    size: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${DateFormat('dd MMM yyyy, HH:mm').format(log.scheduledAt!)}${LanguageManager.isEnglish ? '' : ' WIB'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_application != null)
                              GestureDetector(
                                onTap: () {
                                  CalendarHelper.syncScheduleToCalendar(
                                    context: context,
                                    companyName: _application!.companyName,
                                    positionTitle: _application!.positionTitle,
                                    stageName: log.stageName,
                                    scheduledAt: log.scheduledAt!,
                                    meetingLink: log.meetingLink,
                                    interviewer: log.interviewerName,
                                    notes: log.notes,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(8),
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
                                        size: 13,
                                        color: isDark
                                            ? const Color(0xFFE4E4E7)
                                            : const Color(0xFF18181B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Sync',
                                        style: TextStyle(
                                          fontSize: 11.5,
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
                      if (log.interviewerName != null && log.interviewerName!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              size: 13,
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
                      if (log.meetingLink != null && log.meetingLink!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.videocam,
                              size: 14,
                              color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                                child: GestureDetector(
                                  onTap: () => UIHelper.openUrl(context, log.meetingLink),
                                  child: Text(
                                  log.meetingLink!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          log.notes!,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getLogResultColor(String result) {
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

  Widget _buildInfoRow(String title, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isDark ? AppColors.textHintDark : AppColors.textHint),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              height: 1.35,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationBlock(String location, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.location_solid,
              size: 17,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.locationLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: Text(
            location,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.2,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
