import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';

class ApplicationFormScreen extends StatefulWidget {
  final JobRepository repository;
  final JobApplication? applicationToEdit;

  const ApplicationFormScreen({
    super.key,
    required this.repository,
    this.applicationToEdit,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;
  late TextEditingController _portalCustomController;
  late TextEditingController _urlController;
  late TextEditingController _salaryExpectationController;
  late TextEditingController _salaryOfferedController;
  late TextEditingController _notesController;

  late WorkSystem _workSystem;
  late JobPortal _jobPortal;
  late ApplicationStatus _status;
  late DateTime _appliedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final app = widget.applicationToEdit;
    _companyController = TextEditingController(text: app?.companyName ?? '');
    _positionController = TextEditingController(text: app?.positionTitle ?? '');
    _locationController = TextEditingController(text: app?.location ?? '');
    _portalCustomController = TextEditingController(text: app?.jobPortalCustom ?? '');
    _urlController = TextEditingController(text: app?.jobUrl ?? '');
    _salaryExpectationController = TextEditingController(
      text: app?.salaryExpectation != null ? app!.salaryExpectation!.toStringAsFixed(0) : '',
    );
    _salaryOfferedController = TextEditingController(
      text: app?.salaryOffered != null ? app!.salaryOffered!.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: app?.notes ?? '');

    _workSystem = app?.workSystem ?? WorkSystem.onSite;
    _jobPortal = app?.jobPortal ?? JobPortal.linkedIn;
    _status = app?.status ?? ApplicationStatus.applied;
    _appliedDate = app?.appliedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _portalCustomController.dispose();
    _urlController.dispose();
    _salaryExpectationController.dispose();
    _salaryOfferedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appliedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _appliedDate = picked);
    }
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEditing = widget.applicationToEdit != null;
      final application = JobApplication(
        id: isEditing ? widget.applicationToEdit!.id : '',
        userId: isEditing ? widget.applicationToEdit!.userId : '',
        companyName: _companyController.text.trim(),
        positionTitle: _positionController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        workSystem: _workSystem,
        jobPortal: _jobPortal,
        jobPortalCustom: _jobPortal == JobPortal.lainnya && _portalCustomController.text.isNotEmpty
            ? _portalCustomController.text.trim()
            : null,
        jobUrl: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        status: _status,
        appliedDate: _appliedDate,
        salaryExpectation: double.tryParse(_salaryExpectationController.text.trim()),
        salaryOffered: double.tryParse(_salaryOfferedController.text.trim()),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isFavorite: widget.applicationToEdit?.isFavorite ?? false,
      );

      if (isEditing) {
        await widget.repository.updateApplication(application);
      } else {
        await widget.repository.createApplication(application);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.applicationToEdit != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Lamaran' : 'Catat Lamaran Baru',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Company Name
            _buildTextField(
              controller: _companyController,
              label: 'Nama Perusahaan *',
              hint: 'e.g. PT Maju Bersama',
              icon: Icons.business_outlined,
              isDark: isDark,
              validator: (v) => v == null || v.trim().isEmpty ? 'Nama perusahaan wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Position Title
            _buildTextField(
              controller: _positionController,
              label: 'Posisi / Role *',
              hint: 'e.g. Software Engineer, Finance Staff',
              icon: Icons.badge_outlined,
              isDark: isDark,
              validator: (v) => v == null || v.trim().isEmpty ? 'Posisi pekerjaan wajib diisi' : null,
            ),
            const SizedBox(height: 14),

            // Location
            _buildTextField(
              controller: _locationController,
              label: 'Lokasi Perusahaan',
              hint: 'e.g. Jakarta Selatan, Remote',
              icon: Icons.location_on_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // Work System & Job Portal
            Row(
              children: [
                Expanded(
                  child: _buildDropdown<WorkSystem>(
                    label: 'Sistem Kerja',
                    value: _workSystem,
                    items: WorkSystem.values,
                    getLabel: (e) => e.label,
                    onChanged: (val) => setState(() => _workSystem = val!),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown<JobPortal>(
                    label: 'Job Portal',
                    value: _jobPortal,
                    items: JobPortal.values,
                    getLabel: (e) => e.label,
                    onChanged: (val) => setState(() => _jobPortal = val!),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            if (_jobPortal == JobPortal.lainnya) ...[
              const SizedBox(height: 14),
              _buildTextField(
                controller: _portalCustomController,
                label: 'Nama Portal Lainnya *',
                hint: 'e.g. Kalibrr, TechInAsia, Telegram',
                icon: Icons.link,
                isDark: isDark,
                validator: (v) => _jobPortal == JobPortal.lainnya && (v == null || v.trim().isEmpty)
                    ? 'Sebutkan nama portal'
                    : null,
              ),
            ],

            const SizedBox(height: 14),

            // Status & Applied Date
            Row(
              children: [
                Expanded(
                  child: _buildDropdown<ApplicationStatus>(
                    label: 'Status Lamaran',
                    value: _status,
                    items: ApplicationStatus.values,
                    getLabel: (e) => e.label,
                    onChanged: (val) => setState(() => _status = val!),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Melamar',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy').format(_appliedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Job URL
            _buildTextField(
              controller: _urlController,
              label: 'Link Lowongan (Opsional)',
              hint: 'https://...',
              icon: Icons.open_in_new,
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // Salary Expectations & Offered
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _salaryExpectationController,
                    label: 'Ekspektasi Gaji (Rp)',
                    hint: '8000000',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _salaryOfferedController,
                    label: 'Penawaran Gaji (Rp)',
                    hint: '8500000',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Notes
            _buildTextField(
              controller: _notesController,
              label: 'Catatan Pribadi',
              hint: 'e.g. Menggunakan CV ATS versi 2, kontak HR: Bpk. Dani',
              icon: Icons.notes_outlined,
              maxLines: 3,
              isDark: isDark,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isEditing ? 'Simpan Perubahan' : 'Simpan Lamaran',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              fontSize: 14,
            ),
            prefixIcon: maxLines == 1
                ? Icon(
                    icon,
                    size: 18,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  )
                : null,
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(getLabel(item)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
