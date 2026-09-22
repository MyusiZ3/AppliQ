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
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/notched_pill_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/appliq_loading.dart';
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
        UIHelper.showSuccessSnackBar(context, 'Status diubah ke ${newStatus.label}');
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
        title: const Text('Hapus Lamaran?'),
        content: const Text('Seluruh data lamaran dan riwayat tahapan wawancara terkait akan dihapus permanen.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.repository.deleteApplication(widget.applicationId);
        if (mounted) {
          UIHelper.showSuccessSnackBar(context, 'Lamaran telah dihapus');
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _showAddStageSheet() async {
    final stageNameController = TextEditingController();
    final interviewerController = TextEditingController();
    final linkController = TextEditingController();
    final notesController = TextEditingController();
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));
    bool isSubmitting = false;

    final quickStages = [
      'HR Screening',
      'Technical Test',
      'User Interview',
      'Final Interview',
      'Offering Call',
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

                        // iOS Nav Header: [Batal] [Tahap Baru] [Simpan]
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
                                    'Batal',
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
                                'Tahap Baru',
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
                                            .isEmpty) return;

                                        setSheetState(
                                            () => isSubmitting = true);
                                        HapticFeedback.mediumImpact();

                                        try {
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
                                            notes: notesController
                                                    .text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : notesController.text
                                                    .trim(),
                                          );
                                          await widget.repository
                                              .createApplicationLog(log);
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            UIHelper.showSuccessSnackBar(
                                                context,
                                                'Tahap wawancara berhasil ditambahkan');
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
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF18181B),
                                          ),
                                        )
                                      : Text(
                                          'Simpan',
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
                            'TIPE TAHAP',
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
                            'INFORMASI UTAMA',
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

                        // Inset Grouped Form Card (Matching Screenshot exactly)
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
                                      hintText:
                                          'Nama tahap (misal: HR Interview)',
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
                                      hintText:
                                          'Pewawancara (misal: Ibu Sarah)',
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
                                            '${DateFormat('dd MMM yyyy, HH:mm').format(scheduledDate)} WIB',
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
                                      hintText:
                                          'Tautan Google Meet / Zoom / Lokasi',
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
                                      hintText:
                                          'Catatan / kisi-kisi persiapan...',
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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          color: isDark ? Colors.white : const Color(0xFF18181B),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Lamaran',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil, size: 20),
            color: isDark ? Colors.white : const Color(0xFF18181B),
            tooltip: 'Edit Lamaran',
            onPressed: () async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ApplicationFormScreen(
                    repository: widget.repository,
                    applicationToEdit: app,
                  ),
                ),
              );
              if (updated == true) _loadData();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: AppColors.expense, size: 20),
            tooltip: 'Hapus',
            onPressed: _deleteApplication,
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
                  'Ubah Status:',
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
                              st.label,
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
                _buildInfoRow('Tanggal Melamar', DateFormat('dd MMMM yyyy').format(app.appliedDate), CupertinoIcons.calendar, isDark),
                const Divider(height: 20),
                _buildInfoRow('Sistem Kerja', app.workSystem.label, CupertinoIcons.briefcase, isDark),
                const Divider(height: 20),
                _buildInfoRow('Sumber Lowongan', app.jobPortalCustom ?? app.jobPortal.label, CupertinoIcons.globe, isDark),
                if (app.location != null && app.location!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Lokasi', app.location!, CupertinoIcons.location_solid, isDark),
                ],
                if (app.salaryExpectation != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Ekspektasi Gaji', 'Rp ${NumberFormat('#,###').format(app.salaryExpectation)}', CupertinoIcons.creditcard, isDark),
                ],
                if (app.salaryOffered != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Gaji Ditawarkan', 'Rp ${NumberFormat('#,###').format(app.salaryOffered)}', CupertinoIcons.creditcard_fill, isDark),
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
                          Text('Link Lowongan', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(CupertinoIcons.arrow_up_right_square, size: 14),
                        label: const Text('Buka URL'),
                        onPressed: () => launchUrl(Uri.parse(app.jobUrl!), mode: LaunchMode.externalApplication),
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
                    'Catatan Tambahan',
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

          const SizedBox(height: 24),

          // Recruitment Stage Timeline Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tahapan Rekrutmen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                label: const Text('Tambah Tahap'),
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
                  'Belum ada jadwal wawancara atau tahapan tes dicatat.',
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
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 15,
                                  color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
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
                            ],
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            onPressed: () async {
                              final confirm = await showCupertinoDialog<bool>(
                                context: context,
                                builder: (ctx) => CupertinoAlertDialog(
                                  title: const Text('Hapus Tahap?'),
                                  content: Text('Hapus tahap "${log.stageName}" dari lamaran ini?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Batal'),
                                      onPressed: () => Navigator.pop(ctx, false),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: const Text('Hapus'),
                                      onPressed: () => Navigator.pop(ctx, true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await widget.repository.deleteApplicationLog(log.id);
                                  UIHelper.showGlobalSuccessToast('Tahap berhasil dihapus');
                                  _loadData();
                                } catch (e) {
                                  UIHelper.showGlobalErrorToast(UIHelper.parseErrorMessage(e));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      if (log.scheduledAt != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                size: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${DateFormat('dd MMM yyyy, HH:mm').format(log.scheduledAt!)} WIB',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
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
                                onTap: () => launchUrl(Uri.parse(log.meetingLink!), mode: LaunchMode.externalApplication),
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

  Widget _buildInfoRow(String title, String value, IconData icon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: isDark ? AppColors.textHintDark : AppColors.textHint),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
