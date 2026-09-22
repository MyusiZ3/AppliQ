import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/notched_pill_card.dart';

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

  late EmploymentType _employmentType;
  late WorkSystem _workSystem;
  late JobPortal _jobPortal;
  late ApplicationStatus _status;
  late DateTime _appliedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final app = widget.applicationToEdit;
    final idFormat = NumberFormat.decimalPattern('id');
    _companyController = TextEditingController(text: app?.companyName ?? '');
    _positionController = TextEditingController(text: app?.positionTitle ?? '');
    _locationController = TextEditingController(text: app?.location ?? '');
    _portalCustomController =
        TextEditingController(text: app?.jobPortalCustom ?? '');
    _urlController = TextEditingController(text: app?.jobUrl ?? '');
    _salaryExpectationController = TextEditingController(
      text: app?.salaryExpectation != null
          ? idFormat.format(app!.salaryExpectation!.round())
          : '',
    );
    _salaryOfferedController = TextEditingController(
      text: app?.salaryOffered != null
          ? idFormat.format(app!.salaryOffered!.round())
          : '',
    );
    _notesController = TextEditingController(text: app?.notes ?? '');

    _employmentType = app?.employmentType ?? EmploymentType.fullTime;
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
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _appliedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _appliedDate = picked);
    }
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final isEditing = widget.applicationToEdit != null;
      final rawExpectation =
          _salaryExpectationController.text.replaceAll(RegExp(r'[^\d]'), '');
      final rawOffered =
          _salaryOfferedController.text.replaceAll(RegExp(r'[^\d]'), '');

      final application = JobApplication(
        id: isEditing ? widget.applicationToEdit!.id : '',
        userId: isEditing ? widget.applicationToEdit!.userId : '',
        companyName: _companyController.text.trim(),
        positionTitle: _positionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        employmentType: _employmentType,
        workSystem: _workSystem,
        jobPortal: _jobPortal,
        jobPortalCustom: _jobPortal == JobPortal.lainnya &&
                _portalCustomController.text.isNotEmpty
            ? _portalCustomController.text.trim()
            : null,
        jobUrl: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        status: _status,
        appliedDate: _appliedDate,
        salaryExpectation:
            rawExpectation.isNotEmpty ? double.tryParse(rawExpectation) : null,
        salaryOffered:
            rawOffered.isNotEmpty ? double.tryParse(rawOffered) : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isFavorite: widget.applicationToEdit?.isFavorite ?? false,
      );

      if (isEditing) {
        await widget.repository.updateApplication(application);
        if (mounted)
          UIHelper.showSuccessSnackBar(context, 'Lamaran berhasil diperbarui');
      } else {
        await widget.repository.createApplication(application);
        if (mounted)
          UIHelper.showSuccessSnackBar(context, 'Lamaran berhasil dicatat');
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.applicationToEdit != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          color: isDark ? Colors.white : const Color(0xFF18181B),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Lamaran' : 'Catat Lamaran Baru',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
            foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                  ),
                )
              : Text(
                  isEditing ? 'Simpan Perubahan' : 'Simpan Lamaran',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3),
                ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Section 1: Informasi Lowongan
            _buildSectionCard(
              title: 'Informasi Lowongan',
              icon: CupertinoIcons.building_2_fill,
              isDark: isDark,
              children: [
                _buildTextField(
                  controller: _companyController,
                  label: 'Nama Perusahaan *',
                  hint: 'e.g. PT Maju Bersama',
                  icon: CupertinoIcons.building_2_fill,
                  isDark: isDark,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama perusahaan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _positionController,
                  label: 'Posisi / Role *',
                  hint: 'e.g. Software Engineer, Finance Staff',
                  icon: CupertinoIcons.briefcase_fill,
                  isDark: isDark,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Posisi pekerjaan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _locationController,
                  label: 'Lokasi Perusahaan',
                  hint: 'e.g. Jakarta Selatan, Remote',
                  icon: CupertinoIcons.location_solid,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 2: Tipe & Sistem Kerja
            _buildSectionCard(
              title: 'Tipe & Sistem Kerja',
              icon: CupertinoIcons.slider_horizontal_3,
              isDark: isDark,
              children: [
                _buildLabel('Tipe Pekerjaan', isDark),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EmploymentType.values.map((type) {
                    final isSelected = _employmentType == type;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _employmentType = type);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF18181B))
                              : (isDark
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFF4F4F5)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF18181B))
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF18181B)
                                    : Colors.white)
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildLabel('Sistem Kerja', isDark),
                const SizedBox(height: 8),
                Row(
                  children: WorkSystem.values.map((sys) {
                    final isSelected = _workSystem == sys;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _workSystem = sys);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF18181B))
                                : (isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF18181B))
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              sys.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                        ? const Color(0xFF18181B)
                                        : Colors.white)
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
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
                        borderRadius: BorderRadius.circular(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tanggal Melamar', isDark),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(_appliedDate),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.calendar,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.textHintDark
                                        : AppColors.textHint,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 3: Sumber Portal Lowongan
            _buildSectionCard(
              title: 'Sumber Portal Lowongan',
              icon: CupertinoIcons.globe,
              isDark: isDark,
              children: [
                _buildLabel('Pilih Portal Loker', isDark),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JobPortal.values.map((portal) {
                    final isSelected = _jobPortal == portal;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _jobPortal = portal);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF18181B))
                              : (isDark
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFF4F4F5)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF18181B))
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          portal.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF18181B)
                                    : Colors.white)
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_jobPortal == JobPortal.lainnya) ...[
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _portalCustomController,
                    label: 'Sebutkan Nama Portal *',
                    hint: 'e.g. Kalibrr, TechInAsia, Telegram',
                    icon: CupertinoIcons.link,
                    isDark: isDark,
                    validator: (v) => _jobPortal == JobPortal.lainnya &&
                            (v == null || v.trim().isEmpty)
                        ? 'Sebutkan nama portal'
                        : null,
                  ),
                ],
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _urlController,
                  label: 'Link Lowongan (Opsional)',
                  hint: 'https://...',
                  icon: CupertinoIcons.link,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section 4: Kompensasi & Catatan
            _buildSectionCard(
              title: 'Kompensasi & Catatan',
              icon: Icons.account_balance_wallet_rounded,
              isDark: isDark,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildCurrencyField(
                        controller: _salaryExpectationController,
                        label: 'Ekspektasi Gaji',
                        hint: '8.000.000',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCurrencyField(
                        controller: _salaryOfferedController,
                        label: 'Penawaran Gaji',
                        hint: '8.500.000',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan Pribadi',
                  hint: 'e.g. CV ATS versi 2, kontak HR: Bpk. Dani',
                  icon: CupertinoIcons.doc_text,
                  maxLines: 3,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return NotchedCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? Colors.white70 : const Color(0xFF52525B),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            ThousandsSeparatorInputFormatter(),
          ],
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              width: 38,
              alignment: Alignment.center,
              child: Text(
                'Rp',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
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
        _buildLabel(label, isDark),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon: maxLines == 1
                ? Icon(
                    icon,
                    size: 18,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  )
                : null,
            filled: true,
            fillColor:
                isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
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
    final safeValue = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: safeValue,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
