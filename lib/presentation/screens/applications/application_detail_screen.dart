import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/status_helper.dart';
import '../../../data/models/application_log.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
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
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _updateStatus(ApplicationStatus newStatus) async {
    if (_application == null) return;
    final updated = _application!.copyWith(status: newStatus);
    await widget.repository.updateApplication(updated);
    _loadData();
  }

  Future<void> _deleteApplication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Lamaran?'),
        content: const Text('Seluruh data lamaran dan riwayat tahapan wawancara terkait akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRejected),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.deleteApplication(widget.applicationId);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _showAddStageSheet() async {
    final stageNameController = TextEditingController();
    final interviewerController = TextEditingController();
    final linkController = TextEditingController();
    final notesController = TextEditingController();
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
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
                  Text(
                    'Tambah Tahap Rekrutmen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (stageNameController.text.trim().isEmpty) return;
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
                      if (context.mounted) Navigator.of(context).pop();
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Simpan Tahap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _application == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final app = _application!;
    final feedback = StatusHelper.getFeedbackText(app.status, app.appliedDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          app.companyName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
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
            icon: const Icon(Icons.delete_outline, color: AppColors.statusRejected),
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
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
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
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Status Dynamic Feedback Alert Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StatusHelper.getStatusColor(app.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: StatusHelper.getStatusColor(app.status).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: StatusHelper.getStatusColor(app.status),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? StatusHelper.getStatusColor(st)
                                  : (isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? StatusHelper.getStatusColor(st)
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                            ),
                            child: Text(
                              st.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary),
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

          // Detail Attributes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow('Tanggal Melamar', DateFormat('dd MMMM yyyy').format(app.appliedDate), Icons.calendar_today, isDark),
                const Divider(height: 20),
                _buildInfoRow('Sistem Kerja', app.workSystem.label, Icons.work_outline, isDark),
                const Divider(height: 20),
                _buildInfoRow('Sumber Lowongan', app.jobPortalCustom ?? app.jobPortal.label, Icons.language_outlined, isDark),
                if (app.location != null && app.location!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Lokasi', app.location!, Icons.location_on_outlined, isDark),
                ],
                if (app.salaryExpectation != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Ekspektasi Gaji', 'Rp ${NumberFormat('#,###').format(app.salaryExpectation)}', Icons.payments_outlined, isDark),
                ],
                if (app.salaryOffered != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow('Gaji Ditawarkan', 'Rp ${NumberFormat('#,###').format(app.salaryOffered)}', Icons.attach_money, isDark),
                ],
                if (app.jobUrl != null && app.jobUrl!.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, size: 18, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          const SizedBox(width: 8),
                          Text('Link Lowongan', style: TextStyle(color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 14),
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
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
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
                'Tahapan Rekrutmen & Interview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
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
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Center(
                child: Text(
                  'Belum ada jadwal wawancara atau tahapan tes dicatat.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
            )
          else
            ..._logs.map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                            fontSize: 14,
                            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await widget.repository.deleteApplicationLog(log.id);
                            _loadData();
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
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                    if (log.interviewerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Pewawancara: ${log.interviewerName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                    if (log.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        log.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
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
            Icon(icon, size: 18, color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
      ],
    );
  }
}
