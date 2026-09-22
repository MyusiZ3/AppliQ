import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../data/models/job_application.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/google_drive_service.dart';
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

  final FocusNode _companyFocusNode = FocusNode();
  final FocusNode _positionFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  late EmploymentType _employmentType;
  late WorkSystem _workSystem;
  late JobPortal _jobPortal;
  late ApplicationStatus _status;
  late DateTime _appliedDate;
  String? _cvFileName;
  String? _cvFileUrl;
  bool _isUploadingDrive = false;
  bool _isLoading = false;
  bool _showAllPortals = false;

  Set<String> _userCompanies = {};
  Set<String> _userPositions = {};
  Set<String> _userLocations = {};

  static const List<String> _defaultCompanies = [
    // Top Indonesian Startups & Tech
    'GoTo', 'Tokopedia', 'Gojek', 'Shopee Indonesia', 'Traveloka', 'Grab Indonesia',
    'Blibli', 'Bukalapak', 'TikTok Indonesia', 'ByteDance', 'Lazada Indonesia',
    'DANA Indonesia', 'OVO', 'Xendit', 'Midtrans', 'Tiket.com', 'Kredivo',
    'Ajaib', 'Bibit', 'Stockbit', 'Ruangguru', 'Halodoc', 'Alodokter',
    'Sirclo', 'Mekari', 'Pinhome', 'Sayurbox', 'eFishery', 'Kopi Kenangan',
    // Banking & Finance
    'Bank Central Asia (BCA)', 'Bank Mandiri', 'Bank Rakyat Indonesia (BRI)',
    'Bank Negara Indonesia (BNI)', 'Bank Syariah Indonesia (BSI)', 'Bank Danamon',
    'Bank CIMB Niaga', 'Bank Jago', 'Jenius (BTPN)', 'SeaBank', 'Blu by BCA Digital',
    // BUMN, Telco & Energy
    'Telkom Indonesia', 'Telkomsel', 'Pertamina', 'PLN', 'Pegadaian',
    'Kereta Api Indonesia (KAI)', 'Garuda Indonesia', 'Pelindo', 'Adaro Energy',
    'Freeport Indonesia', 'Vale Indonesia', 'Aneka Tambang (Antam)',
    // FMCG, Healthcare & Conglomerates
    'Astra International', 'Unilever Indonesia', 'Indofood', 'Mayora Indah',
    'Kalbe Farma', 'Djarum', 'Wings Group', 'Paragon Technology and Innovation',
    'Nutrifood', 'HM Sampoerna',
    // Consulting & Professional Services
    'McKinsey & Company', 'Boston Consulting Group (BCG)', 'Bain & Company',
    'PwC Indonesia', 'EY (Ernst & Young)', 'Deloitte Indonesia', 'KPMG Indonesia', 'Accenture',
    // Big Tech & Global
    'Google', 'Microsoft', 'Amazon (AWS)', 'Meta', 'Apple', 'Canva', 'Spotify',
  ];

  static const List<String> _defaultPositions = [
    'Software Engineer', 'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
    'Mobile Developer (Flutter)', 'Mobile Developer (React Native)', 'Android Developer', 'iOS Developer',
    'UI/UX Designer', 'Product Designer', 'Product Manager', 'Project Manager', 'Scrum Master',
    'Data Analyst', 'Data Scientist', 'Data Engineer', 'AI / ML Engineer',
    'DevOps Engineer', 'Cloud Engineer', 'QA / Quality Assurance Engineer', 'Cyber Security Specialist',
    'Digital Marketing Specialist', 'Content Creator / Specialist', 'Social Media Specialist', 'SEO Specialist',
    'Human Resources (HR / HRGA)', 'Talent Acquisition / Recruiter', 'Finance & Accounting Specialist',
    'Business Development / Sales', 'Account Executive', 'Customer Success / Support',
    'Operations Specialist', 'Graphic Designer', 'Copywriter',
  ];

  static const List<String> _defaultLocations = [
    'Jakarta Selatan', 'Jakarta Pusat', 'Jakarta Barat', 'Jakarta Timur', 'Jakarta Utara',
    'DKI Jakarta', 'Tangerang', 'Tangerang Selatan (BSD / Bintaro)', 'Bekasi', 'Depok', 'Bogor',
    'Bandung', 'Cimahi', 'Karawang', 'Cirebon',
    'Semarang', 'Solo / Surakarta', 'Yogyakarta (DIY)', 'Sleman',
    'Surabaya', 'Sidoarjo', 'Malang', 'Denpasar, Bali',
    'Medan', 'Palembang', 'Batam', 'Pekanbaru', 'Bandar Lampung',
    'Balikpapan', 'Samarinda', 'Banjarmasin', 'Pontianak',
    'Makassar', 'Manado',
    'Remote (Indonesia)', 'Remote (Worldwide / Global)', 'Hybrid (Jakarta)', 'Hybrid (Bandung)', 'Hybrid (Surabaya)',
    'Singapura', 'Kuala Lumpur, Malaysia',
  ];

  List<String> get _combinedCompanySuggestions {
    final seen = <String>{};
    final list = <String>[];
    for (final c in _userCompanies) {
      if (seen.add(c.toLowerCase())) list.add(c);
    }
    for (final c in _defaultCompanies) {
      if (seen.add(c.toLowerCase())) list.add(c);
    }
    return list;
  }

  List<String> get _combinedPositionSuggestions {
    final seen = <String>{};
    final list = <String>[];
    for (final p in _userPositions) {
      if (seen.add(p.toLowerCase())) list.add(p);
    }
    for (final p in _defaultPositions) {
      if (seen.add(p.toLowerCase())) list.add(p);
    }
    return list;
  }

  List<String> get _combinedLocationSuggestions {
    final seen = <String>{};
    final list = <String>[];
    for (final l in _userLocations) {
      if (seen.add(l.toLowerCase())) list.add(l);
    }
    for (final l in _defaultLocations) {
      if (seen.add(l.toLowerCase())) list.add(l);
    }
    return list;
  }

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
    _cvFileName = app?.cvFileName;
    _cvFileUrl = app?.cvFileUrl;

    const topPortals = [
      JobPortal.linkedIn,
      JobPortal.jobStreet,
      JobPortal.glints,
      JobPortal.kalibrr,
      JobPortal.dealls,
      JobPortal.referral,
    ];
    if (!topPortals.contains(_jobPortal)) {
      _showAllPortals = true;
    }

    _loadHistoricalSuggestions();
  }

  Future<void> _loadHistoricalSuggestions() async {
    try {
      final apps = await widget.repository.getApplications(forceRefresh: false);
      if (!mounted) return;
      setState(() {
        _userCompanies = apps
            .map((a) => a.companyName.trim())
            .where((name) => name.isNotEmpty)
            .toSet();
        _userPositions = apps
            .map((a) => a.positionTitle.trim())
            .where((p) => p.isNotEmpty)
            .toSet();
        _userLocations = apps
            .map((a) => a.location?.trim() ?? '')
            .where((loc) => loc.isNotEmpty)
            .toSet();
      });
    } catch (_) {}
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
    _companyFocusNode.dispose();
    _positionFocusNode.dispose();
    _locationFocusNode.dispose();
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

  Future<void> _handleDriveUpload() async {
    final company = _companyController.text.trim();
    final position = _positionController.text.trim();

    if (company.isEmpty || position.isEmpty) {
      UIHelper.showGlobalErrorToast('Isi nama perusahaan dan posisi terlebih dahulu');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isUploadingDrive = true);

    try {
      final uploadResult = await GoogleDriveService.pickAndUploadDocument(
        companyName: company,
        positionTitle: position,
      );

      if (uploadResult != null) {
        setState(() {
          _cvFileName = uploadResult['fileName'];
          _cvFileUrl = uploadResult['fileUrl'];
          _isUploadingDrive = false;
        });
        if (mounted) {
          UIHelper.showSuccessSnackBar(
            context,
            'Berkas berhasil diupload ke Google Drive folder: ${uploadResult['folderPath']}',
          );
        }
      } else {
        setState(() => _isUploadingDrive = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingDrive = false);
        UIHelper.handleError(context, e);
      }
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
        cvFileName: _cvFileName,
        cvFileUrl: _cvFileUrl,
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
                _buildAutocompleteTextField(
                  controller: _companyController,
                  focusNode: _companyFocusNode,
                  label: 'Nama Perusahaan *',
                  hint: 'e.g. GoTo, Shopee, BCA, Telkom',
                  icon: CupertinoIcons.building_2_fill,
                  isDark: isDark,
                  allSuggestions: _combinedCompanySuggestions,
                  userHistory: _userCompanies,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama perusahaan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildAutocompleteTextField(
                  controller: _positionController,
                  focusNode: _positionFocusNode,
                  label: 'Posisi / Role *',
                  hint: 'e.g. Software Engineer, Finance Staff',
                  icon: CupertinoIcons.briefcase_fill,
                  isDark: isDark,
                  allSuggestions: _combinedPositionSuggestions,
                  userHistory: _userPositions,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Posisi pekerjaan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildAutocompleteTextField(
                  controller: _locationController,
                  focusNode: _locationFocusNode,
                  label: 'Lokasi Perusahaan',
                  hint: 'e.g. Jakarta Selatan, BSD, Remote',
                  icon: CupertinoIcons.location_solid,
                  isDark: isDark,
                  allSuggestions: _combinedLocationSuggestions,
                  userHistory: _userLocations,
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WorkSystem.values.map((sys) {
                    final isSelected = _workSystem == sys;
                    final icon = _getWorkSystemIcon(sys);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _workSystem = sys);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 14,
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF18181B)
                                      : Colors.white)
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
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
                          ],
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
                Builder(
                  builder: (context) {
                    const topPortals = [
                      JobPortal.linkedIn,
                      JobPortal.jobStreet,
                      JobPortal.glints,
                      JobPortal.kalibrr,
                      JobPortal.dealls,
                      JobPortal.referral,
                    ];

                    final visiblePortals = _showAllPortals
                        ? JobPortal.values
                        : (topPortals.contains(_jobPortal)
                            ? topPortals
                            : [...topPortals, _jobPortal]);

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...visiblePortals.map((portal) {
                          final isSelected = _jobPortal == portal;
                          final icon = _getJobPortalIcon(portal);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _jobPortal = portal);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: isSelected
                                        ? (isDark
                                            ? const Color(0xFF18181B)
                                            : Colors.white)
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    portal.label,
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
                                ],
                              ),
                            ),
                          );
                        }),
                        // Show More / Show Less Toggle Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _showAllPortals = !_showAllPortals);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3F3F46).withValues(alpha: 0.35)
                                  : const Color(0xFFE4E4E7).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
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
                                Text(
                                  _showAllPortals
                                      ? 'Lebih Sedikit'
                                      : '+${JobPortal.values.length - topPortals.length} Opsi Lainnya',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showAllPortals
                                      ? CupertinoIcons.chevron_up
                                      : CupertinoIcons.chevron_down,
                                  size: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_jobPortal == JobPortal.referral) ...[
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _portalCustomController,
                    label: 'Nama Pemberi Referensi / Kontak (Opsional)',
                    hint: 'Contoh: Kak Kevin (Tech Lead di Perusahaan ini)',
                    icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                    isDark: isDark,
                  ),
                ],
                if (_jobPortal == JobPortal.directEmail) ...[
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _portalCustomController,
                    label: 'Email / Nama Recruiter (Opsional)',
                    hint: 'Contoh: recruiter@company.com / HR Talenta',
                    icon: CupertinoIcons.mail,
                    isDark: isDark,
                  ),
                ],
                if (_jobPortal == JobPortal.lainnya) ...[
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _portalCustomController,
                    label: 'Sebutkan Nama Portal *',
                    hint: 'e.g. Indeed, Glassdoor, Dribbble',
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

            const SizedBox(height: 16),

            // Section 5: Lampiran Berkas & CV (Google Drive)
            _buildSectionCard(
              title: 'Lampiran Berkas & CV',
              icon: CupertinoIcons.cloud_upload_fill,
              isDark: isDark,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.folder_badge_plus,
                            size: 16,
                            color: isDark ? Colors.white70 : const Color(0xFF52525B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Penyimpanan Google Drive Otomatis',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'File CV & berkas akan otomatis disimpan rapi di folder:\nAppliQ / ${_companyController.text.trim().isNotEmpty ? _companyController.text.trim() : "Perusahaan"}_${_positionController.text.trim().isNotEmpty ? _positionController.text.trim() : "Posisi"}',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_cvFileName != null && _cvFileName!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        const Icon(CupertinoIcons.doc_fill, size: 20, color: Color(0xFF10B981)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cvFileName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tersimpan di Google Drive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.trash, size: 16, color: Color(0xFFEF4444)),
                          onPressed: () {
                            setState(() {
                              _cvFileName = null;
                              _cvFileUrl = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isUploadingDrive ? null : _handleDriveUpload,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isUploadingDrive)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.white : const Color(0xFF18181B),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                CupertinoIcons.cloud_upload,
                                size: 17,
                                color: isDark ? Colors.white : const Color(0xFF18181B),
                              ),
                            ),
                          Text(
                            _isUploadingDrive ? 'Mengupload ke Google Drive...' : 'Upload CV / Berkas ke Google Drive',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

  Widget _buildAutocompleteTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required List<String> allSuggestions,
    required Set<String> userHistory,
    String? Function(String?)? validator,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label, isDark),
            const SizedBox(height: 6),
            RawAutocomplete<String>(
              textEditingController: controller,
              focusNode: focusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                final query = textEditingValue.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return const Iterable<String>.empty();
                }
                final startsWithList = <String>[];
                final containsList = <String>[];
                for (final option in allSuggestions) {
                  final optLower = option.toLowerCase();
                  if (optLower.startsWith(query)) {
                    startsWithList.add(option);
                  } else if (optLower.contains(query)) {
                    containsList.add(option);
                  }
                }
                return [...startsWithList, ...containsList].take(5);
              },
              onSelected: (String selection) {
                HapticFeedback.selectionClick();
                controller.text = selection;
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.25),
                    color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: isDark
                                ? AppColors.borderDark.withValues(alpha: 0.5)
                                : AppColors.borderLight,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            final isRecent = userHistory.contains(option);
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      isRecent ? CupertinoIcons.clock_fill : icon,
                                      size: 15,
                                      color: isRecent
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.textHintDark
                                              : AppColors.textHint),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: isRecent
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isRecent)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Riwayat',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder: (context, fieldTextEditingController,
                  fieldFocusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  validator: validator,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.textHintDark
                          : AppColors.textHint,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      icon,
                      size: 18,
                      color: isDark
                          ? AppColors.textHintDark
                          : AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFF4F4F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
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

  IconData _getWorkSystemIcon(WorkSystem sys) {
    switch (sys) {
      case WorkSystem.onSite:
        return CupertinoIcons.building_2_fill;
      case WorkSystem.hybrid:
        return CupertinoIcons.arrow_2_squarepath;
      case WorkSystem.wfh:
        return CupertinoIcons.house_fill;
      case WorkSystem.remoteOverseas:
        return CupertinoIcons.globe;
      case WorkSystem.flexible:
        return CupertinoIcons.sparkles;
    }
  }

  IconData _getJobPortalIcon(JobPortal portal) {
    switch (portal) {
      case JobPortal.linkedIn:
        return CupertinoIcons.person_2_fill;
      case JobPortal.jobStreet:
        return CupertinoIcons.briefcase_fill;
      case JobPortal.glints:
        return CupertinoIcons.flame_fill;
      case JobPortal.kalibrr:
        return CupertinoIcons.compass_fill;
      case JobPortal.dealls:
        return CupertinoIcons.star_fill;
      case JobPortal.techInAsia:
        return CupertinoIcons.bolt_fill;
      case JobPortal.referral:
        return CupertinoIcons.person_crop_circle_badge_checkmark;
      case JobPortal.directEmail:
        return CupertinoIcons.mail_solid;
      case JobPortal.kitaLulus:
        return CupertinoIcons.check_mark_circled_solid;
      case JobPortal.jobFair:
        return CupertinoIcons.placemark_fill;
      case JobPortal.website:
        return CupertinoIcons.globe;
      case JobPortal.instagram:
        return CupertinoIcons.camera_fill;
      case JobPortal.komunitas:
        return CupertinoIcons.chat_bubble_2_fill;
      case JobPortal.freelance:
        return CupertinoIcons.device_laptop;
      case JobPortal.lainnya:
        return CupertinoIcons.ellipsis_circle_fill;
    }
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
