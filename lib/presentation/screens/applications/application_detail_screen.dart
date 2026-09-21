import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/status_helper.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/status_badge.dart';
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
    if (_application == null) return;
    try {
      final updated = _application!.copyWith(status: newStatus);
      await widget.repository.updateApplication(updated);
      if (mounted) UIHelper.showSuccessSnackBar(context, 'Status diubah ke ${newStatus.label}');
      _loadData();
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
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

    await UIHelper.showPremiumBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tambah Tahap Rekrutmen',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stageNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Tahap *',
                    hintText: 'e.g. HR Interview, Technical Test, User Interview',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: interviewerController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pewawancara',
                    hintText: 'e.g. Ibu Sarah (HRD)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'Tautan Meeting / Lokasi',
                    hintText: 'https://meet.google.com/...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan / Kisi-kisi',
                    hintText: 'Poin penting yang perlu dipersiapkan...',
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () async {
                    if (stageNameController.text.trim().isEmpty) return;
                    try {
                      final log = ApplicationLog(
                        id: '',
                        applicationId: widget.applicationId,
                        userId: '',
                        stageName: stageNameController.text.trim(),
                        scheduledAt: scheduledDate,
                        interviewerName: interviewerController.text.trim().isEmpty ? null : interviewerController.text.trim(),
                        meetingLink: linkController.text.trim().isEmpty ? null : linkController.text.trim(),
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      await widget.repository.createApplicationLog(log);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        UIHelper.showSuccessSnackBar(context, 'Tahap wawancara berhasil ditambahkan');
                      }
                      _loadData();
                    } catch (e) {
                      if (context.mounted) UIHelper.handleError(context, e);
                    }
                  },
                  child: const Text('Simpan Tahap'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _application == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final app = _application!;
    final feedback = StatusHelper.getFeedbackText(app.status, app.appliedDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        title: Text(
          app.companyName,
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
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
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
                  _buildInfoRow('Ekspektasi Gaji', 'Rp ${NumberFormat('#,###').format(app.salaryExpectation)}', CupertinoIcons.money_dollar_circle, isDark),
                ],
                if (app.salaryOffered != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Gaji Ditawarkan', 'Rp ${NumberFormat('#,###').format(app.salaryOffered)}', CupertinoIcons.money_dollar, isDark),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
              ),
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
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
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
                        Text(
                          log.stageName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.xmark_circle, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          onPressed: () async {
                            try {
                              await widget.repository.deleteApplicationLog(log.id);
                              UIHelper.showGlobalSuccessToast('Tahap berhasil dihapus');
                              _loadData();
                            } catch (e) {
                              UIHelper.showGlobalErrorToast(UIHelper.parseErrorMessage(e));
                            }
                          },
                        ),
                      ],
                    ),
                    if (log.scheduledAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Jadwal: ${DateFormat('dd MMM yyyy, HH:mm').format(log.scheduledAt!)} WIB',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (log.interviewerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Pewawancara: ${log.interviewerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (log.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        log.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
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
