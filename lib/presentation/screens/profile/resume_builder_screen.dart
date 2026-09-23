import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/user_resume.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/appliq_loading.dart';
import 'document_preview_screen.dart';

class ResumeBuilderScreen extends StatefulWidget {
  final JobRepository repository;

  const ResumeBuilderScreen({super.key, required this.repository});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _uuid = const Uuid();
  bool _isLoading = true;
  bool _isSaving = false;
  UserResume? _resume;

  // Controllers - Header & Contact
  final _fullNameCtrl = TextEditingController();
  final _cityCountryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  // Controller - Summary
  final _summaryCtrl = TextEditingController();

  // Structured Lists
  List<EducationItem> _educations = [];
  List<ExperienceItem> _experiences = [];
  List<CertificationItem> _certifications = [];
  List<String> _technicalSkills = [];
  List<String> _softSkills = [];

  // Controllers - Cover Letter Specific
  final _birthPlaceDateCtrl = TextEditingController();
  final _fullAddressCtrl = TextEditingController();
  final _lastEducationCtrl = TextEditingController();
  final _targetPositionCtrl = TextEditingController();
  String _maritalStatus = 'Belum Menikah';
  String _citizenship = 'Indonesia';
  List<String> _selectedAttachments = [];

  // Card Expansion State
  final Map<int, bool> _expandedSections = {
    0: true,  // Header
    1: false, // Summary
    2: false, // Education
    3: false, // Experience
    4: false, // Certifications
    5: false, // Technical Skills
    6: false, // Soft Skills
    7: false, // Cover Letter Info
  };

  @override
  void initState() {
    super.initState();
    _loadResume();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _cityCountryCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
    _summaryCtrl.dispose();
    _birthPlaceDateCtrl.dispose();
    _fullAddressCtrl.dispose();
    _lastEducationCtrl.dispose();
    _targetPositionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResume() async {
    setState(() => _isLoading = true);
    try {
      final resume = await widget.repository.getUserResume();
      if (resume != null) {
        _resume = resume;
        _fullNameCtrl.text = resume.fullName;
        _cityCountryCtrl.text = resume.cityCountry;
        _phoneCtrl.text = resume.phoneNumber;
        _emailCtrl.text = resume.email;
        _linkedinCtrl.text = resume.linkedinUrl ?? '';
        _portfolioCtrl.text = resume.portfolioUrl ?? '';
        _summaryCtrl.text = resume.summary ?? '';

        _educations = List.from(resume.educations);
        _experiences = List.from(resume.experiences);
        _certifications = List.from(resume.certifications);
        _technicalSkills = List.from(resume.technicalSkills);
        _softSkills = List.from(resume.softSkills);

        _birthPlaceDateCtrl.text = resume.birthPlaceDate ?? '';
        _fullAddressCtrl.text = resume.fullAddress ?? '';
        _lastEducationCtrl.text = resume.lastEducation ?? '';
        _targetPositionCtrl.text = resume.targetJobPosition ?? '';
        _maritalStatus = resume.maritalStatus;
        _citizenship = resume.citizenship;
        _selectedAttachments = List.from(resume.selectedAttachments);
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  UserResume _collectResumeData() {
    return UserResume(
      id: _resume?.id ?? '',
      userId: _resume?.userId ?? '',
      fullName: _fullNameCtrl.text.trim(),
      cityCountry: _cityCountryCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      linkedinUrl: _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
      portfolioUrl: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
      summary: _summaryCtrl.text.trim().isEmpty ? null : _summaryCtrl.text.trim(),
      educations: _educations,
      experiences: _experiences,
      certifications: _certifications,
      technicalSkills: _technicalSkills,
      softSkills: _softSkills,
      birthPlaceDate: _birthPlaceDateCtrl.text.trim().isEmpty ? null : _birthPlaceDateCtrl.text.trim(),
      fullAddress: _fullAddressCtrl.text.trim().isEmpty ? null : _fullAddressCtrl.text.trim(),
      maritalStatus: _maritalStatus,
      citizenship: _citizenship,
      lastEducation: _lastEducationCtrl.text.trim().isEmpty ? null : _lastEducationCtrl.text.trim(),
      targetJobPosition: _targetPositionCtrl.text.trim().isEmpty ? null : _targetPositionCtrl.text.trim(),
      selectedAttachments: _selectedAttachments,
      createdAt: _resume?.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveResume({bool showToast = true}) async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      final updatedResume = _collectResumeData();
      final saved = await widget.repository.saveUserResume(updatedResume);
      _resume = saved;
      if (mounted && showToast) {
        UIHelper.showSuccessSnackBar(
          context,
          AppStrings.resumeSavedSuccess,
        );
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openPreview({required int initialTab}) async {
    final currentData = _collectResumeData();
    // Auto-save silently before opening preview
    widget.repository.saveUserResume(currentData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentPreviewScreen(
          resume: currentData,
          initialTab: initialTab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          AppStrings.resumeBuilderTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.saveResume,
            icon: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                : Icon(
                    CupertinoIcons.cloud_upload_fill,
                    size: 22,
                    color: isMonochrome
                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                        : const Color(0xFF6366F1),
                  ),
            onPressed: _isSaving ? null : () => _saveResume(showToast: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppliqLoading())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      // Header Card 1: Contact Info
                      _buildSectionCard(
                        index: 0,
                        icon: CupertinoIcons.person_crop_circle_fill,
                        title: AppStrings.rbSectionContactTitle,
                        subtitle: AppStrings.rbSectionContactSubtitle,
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildContactForm(isDark),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 2: Summary
                      _buildSectionCard(
                        index: 1,
                        icon: CupertinoIcons.text_quote,
                        title: AppStrings.rbSectionSummaryTitle,
                        subtitle: AppStrings.rbSectionSummarySubtitle,
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildSummaryForm(isDark),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 3: Education
                      _buildSectionCard(
                        index: 2,
                        icon: CupertinoIcons.book_fill,
                        title: AppStrings.rbSectionEducationTitle,
                        subtitle: AppStrings.rbSectionEducationSubtitle(_educations.length),
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildEducationSection(isDark),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 4: Experience
                      _buildSectionCard(
                        index: 3,
                        icon: CupertinoIcons.briefcase_fill,
                        title: AppStrings.rbSectionExperienceTitle,
                        subtitle: AppStrings.rbSectionExperienceSubtitle(_experiences.length),
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildExperienceSection(isDark),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 5: Certifications
                      _buildSectionCard(
                        index: 4,
                        icon: CupertinoIcons.doc_checkmark_fill,
                        title: AppStrings.rbSectionCertificationTitle,
                        subtitle: AppStrings.rbSectionCertificationSubtitle(_certifications.length),
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildCertificationSection(isDark),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 6: Technical Skills
                      _buildSectionCard(
                        index: 5,
                        icon: CupertinoIcons.wrench_fill,
                        title: AppStrings.rbSectionTechSkillsTitle,
                        subtitle: AppStrings.rbSectionTechSkillsSubtitle(_technicalSkills.length),
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildSkillsSection(
                          skills: _technicalSkills,
                          isDark: isDark,
                          isTechnical: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 7: Soft Skills
                      _buildSectionCard(
                        index: 6,
                        icon: CupertinoIcons.person_2_fill,
                        title: AppStrings.rbSectionSoftSkillsTitle,
                        subtitle: AppStrings.rbSectionSoftSkillsSubtitle(_softSkills.length),
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildSkillsSection(
                          skills: _softSkills,
                          isDark: isDark,
                          isTechnical: false,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Section Card 8: Cover Letter Specific
                      _buildSectionCard(
                        index: 7,
                        icon: CupertinoIcons.mail_solid,
                        title: AppStrings.rbSectionCoverLetterTitle,
                        subtitle: AppStrings.rbSectionCoverLetterSubtitle,
                        isDark: isDark,
                        isMonochrome: isMonochrome,
                        primaryColor: primaryColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        child: _buildCoverLetterExtraForm(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          border: Border(top: BorderSide(color: borderColor, width: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                // Preview CV ATS Button (Tanpa Icon)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openPreview(initialTab: 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      foregroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: _roundedRectangle(12),
                    ),
                    child: Text(
                      AppStrings.previewCvAts,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Preview Cover Letter Button (Tanpa Icon)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openPreview(initialTab: 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMonochrome
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : const Color(0xFF6366F1),
                      foregroundColor: isMonochrome
                          ? (isDark ? const Color(0xFF18181B) : Colors.white)
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: _roundedRectangle(12),
                    ),
                    child: Text(
                      AppStrings.coverLetterTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static RoundedRectangleBorder _roundedRectangle(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  // --- Modular Section Card Builder ---
  Widget _buildSectionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool isMonochrome,
    required Color primaryColor,
    required Color cardBg,
    required Color borderColor,
    required Widget child,
  }) {
    final isExpanded = _expandedSections[index] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? (isMonochrome
                  ? (isDark ? Colors.white54 : const Color(0xFF18181B))
                  : const Color(0xFF6366F1).withValues(alpha: 0.6))
              : borderColor,
          width: isExpanded ? 1.4 : 0.8,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _expandedSections[index] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? (isMonochrome
                              ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08))
                              : const Color(0xFF6366F1).withValues(alpha: 0.15))
                          : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isExpanded
                          ? (isMonochrome
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : const Color(0xFF6366F1))
                          : (isDark ? Colors.white : const Color(0xFF18181B)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 16,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  // --- Form 1: Contact Form ---
  Widget _buildContactForm(bool isDark) {
    return Column(
      children: [
        _buildTextField(
          controller: _fullNameCtrl,
          label: AppStrings.fullNameLabel,
          hint: AppStrings.fullNameHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _cityCountryCtrl,
          label: AppStrings.cityCountryLabel,
          hint: AppStrings.cityCountryHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _phoneCtrl,
                label: AppStrings.phoneNumberLabel,
                hint: AppStrings.phoneNumberHint,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _emailCtrl,
                label: AppStrings.emailLabel,
                hint: AppStrings.emailHint,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _linkedinCtrl,
          label: AppStrings.linkedinLabel,
          hint: AppStrings.linkedinHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _portfolioCtrl,
          label: AppStrings.portfolioLabel,
          hint: AppStrings.portfolioHint,
          isDark: isDark,
        ),
      ],
    );
  }

  // --- Form 2: Summary Form ---
  Widget _buildSummaryForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _summaryCtrl,
          label: AppStrings.summaryLabel,
          hint: AppStrings.summaryHint,
          maxLines: 4,
          isDark: isDark,
        ),
      ],
    );
  }

  // --- Form 3: Education Section ---
  Widget _buildEducationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._educations.asMap().entries.map((entry) {
          final i = entry.key;
          final edu = entry.value;
          return _buildItemCard(
            title: edu.institution,
            subtitle: '${edu.degreeAndMajor} (${edu.period})',
            extra: edu.gpa != null ? '${AppStrings.gpaLabel}: ${edu.gpa}' : null,
            isDark: isDark,
            onEdit: () => _showEducationDialog(existing: edu, index: i),
            onDelete: () {
              setState(() => _educations.removeAt(i));
            },
          );
        }),
        const SizedBox(height: 8),
        _buildAddButton(
          title: AppStrings.addEducationButton,
          onTap: () => _showEducationDialog(),
          isDark: isDark,
        ),
      ],
    );
  }

  // --- Form 4: Experience Section ---
  Widget _buildExperienceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._experiences.asMap().entries.map((entry) {
          final i = entry.key;
          final exp = entry.value;
          return _buildItemCard(
            title: exp.position,
            subtitle: '${exp.companyOrProject} (${exp.period})',
            extra: exp.cityCountry.isNotEmpty ? exp.cityCountry : null,
            isDark: isDark,
            onEdit: () => _showExperienceDialog(existing: exp, index: i),
            onDelete: () {
              setState(() => _experiences.removeAt(i));
            },
          );
        }),
        const SizedBox(height: 8),
        _buildAddButton(
          title: AppStrings.addExperienceButton,
          onTap: () => _showExperienceDialog(),
          isDark: isDark,
        ),
      ],
    );
  }

  // --- Form 5: Certification Section ---
  Widget _buildCertificationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._certifications.asMap().entries.map((entry) {
          final i = entry.key;
          final cert = entry.value;
          return _buildItemCard(
            title: cert.title,
            subtitle: cert.organization ?? '',
            extra: cert.year != null ? '${AppStrings.obtainedYear}: ${cert.year}' : null,
            isDark: isDark,
            onEdit: () => _showCertificationDialog(existing: cert, index: i),
            onDelete: () {
              setState(() => _certifications.removeAt(i));
            },
          );
        }),
        const SizedBox(height: 8),
        _buildAddButton(
          title: AppStrings.addCertificationButton,
          onTap: () => _showCertificationDialog(),
          isDark: isDark,
        ),
      ],
    );
  }

  // --- Form 6 & 7: Skills Section (Chips & Input) ---
  Widget _buildSkillsSection({
    required List<String> skills,
    required bool isDark,
    required bool isTechnical,
  }) {
    final inputCtrl = TextEditingController();
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Chip(
              label: Text(skill),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              deleteIcon: const Icon(CupertinoIcons.xmark, size: 14),
              onDeleted: () {
                setState(() => skills.remove(skill));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide.none,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildTextField(
                controller: inputCtrl,
                label: isTechnical ? AppStrings.addTechSkillLabel : AppStrings.addSoftSkillLabel,
                hint: isTechnical ? AppStrings.addTechSkillHint : AppStrings.addSoftSkillHint,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 46,
              width: 46,
              child: IconButton.filled(
                onPressed: () {
                  final val = inputCtrl.text.trim();
                  if (val.isNotEmpty && !skills.contains(val)) {
                    setState(() => skills.add(val));
                    inputCtrl.clear();
                  }
                },
                icon: const Icon(CupertinoIcons.plus, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isMonochrome
                      ? (isDark ? const Color(0xFF18181B) : Colors.white)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Form 8: Cover Letter Specific ---
  Widget _buildCoverLetterExtraForm(bool isDark) {
    const attachmentOptions = [
      'Curriculum Vitae (CV)',
      'Fotokopi Ijazah & Transkrip Nilai',
      'Fotokopi KTP',
      'Fotokopi SKCK',
      'Pas Foto Terbaru (3x4)',
      'Portofolio',
      'Sertifikat Pelatihan / Keahlian',
      'Surat Keterangan Sehat',
    ];

    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _birthPlaceDateCtrl,
          label: AppStrings.birthPlaceDateLabel,
          hint: AppStrings.birthPlaceDateHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _fullAddressCtrl,
          label: AppStrings.fullAddressLabel,
          hint: AppStrings.fullAddressHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _lastEducationCtrl,
          label: AppStrings.lastEducationLabel,
          hint: AppStrings.lastEducationHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _targetPositionCtrl,
          label: AppStrings.targetJobPositionLabel,
          hint: AppStrings.targetJobPositionHint,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.maritalStatusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _maritalStatus,
                        isExpanded: true,
                        icon: Icon(
                          CupertinoIcons.chevron_down,
                          size: 14,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                        dropdownColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        items: ['Belum Menikah', 'Menikah', 'Cerai Hidup', 'Cerai Mati']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _maritalStatus = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.citizenshipLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _citizenship,
                        isExpanded: true,
                        icon: Icon(
                          CupertinoIcons.chevron_down,
                          size: 14,
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                        dropdownColor: isDark ? const Color(0xFF27272A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        items: ['Indonesia', 'WNA']
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _citizenship = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.attachmentListLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        ...attachmentOptions.map((opt) {
          final isChecked = _selectedAttachments.contains(opt);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(opt, style: const TextStyle(fontSize: 13)),
            value: isChecked,
            activeColor: primaryColor,
            checkColor: isMonochrome
                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                : Colors.white,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedAttachments.add(opt);
                } else {
                  _selectedAttachments.remove(opt);
                }
              });
            },
          );
        }),
      ],
    );
  }

  // --- Modern Modal Bottom Sheet Helpers ---
  void _showEducationDialog({EducationItem? existing, int? index}) {
    final instCtrl = TextEditingController(text: existing?.institution ?? '');
    final majorCtrl = TextEditingController(text: existing?.degreeAndMajor ?? '');
    final cityCtrl = TextEditingController(text: existing?.cityCountry ?? '');
    final periodCtrl = TextEditingController(text: existing?.period ?? '');
    final gpaCtrl = TextEditingController(text: existing?.gpa ?? '');
    final bulletCtrl = TextEditingController(text: existing?.bulletPoints.join('\n') ?? '');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        final viewInsetsBottom = MediaQuery.of(ctx).viewInsets.bottom;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            bottom: viewInsetsBottom + (bottomPadding > 0 ? bottomPadding + 16 : 28),
            left: 20,
            right: 20,
            top: 14,
          ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existing != null ? AppStrings.editEducation : AppStrings.addEducation,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: instCtrl,
                label: AppStrings.institutionName,
                hint: AppStrings.institutionHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: majorCtrl,
                label: AppStrings.degreeAndMajor,
                hint: AppStrings.degreeHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: periodCtrl,
                      label: AppStrings.educationPeriod,
                      hint: AppStrings.educationPeriodHint,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: gpaCtrl,
                      label: AppStrings.gpaLabel,
                      hint: AppStrings.gpaHint,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: cityCtrl,
                label: AppStrings.institutionLocation,
                hint: AppStrings.institutionLocationHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: bulletCtrl,
                label: AppStrings.educationActivities,
                hint: AppStrings.educationActivitiesHint,
                isDark: isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF52525B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (instCtrl.text.trim().isEmpty) return;
                        final bullets = bulletCtrl.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        final item = EducationItem(
                          id: existing?.id ?? _uuid.v4(),
                          institution: instCtrl.text.trim(),
                          degreeAndMajor: majorCtrl.text.trim(),
                          cityCountry: cityCtrl.text.trim(),
                          period: periodCtrl.text.trim(),
                          gpa: gpaCtrl.text.trim().isEmpty ? null : gpaCtrl.text.trim(),
                          bulletPoints: bullets,
                        );

                        setState(() {
                          if (index != null) {
                            _educations[index] = item;
                          } else {
                            _educations.add(item);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonochrome
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : primaryColor,
                        foregroundColor: isMonochrome
                            ? (isDark ? const Color(0xFF18181B) : Colors.white)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.save, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _showExperienceDialog({ExperienceItem? existing, int? index}) {
    final posCtrl = TextEditingController(text: existing?.position ?? '');
    final compCtrl = TextEditingController(text: existing?.companyOrProject ?? '');
    final cityCtrl = TextEditingController(text: existing?.cityCountry ?? '');
    final periodCtrl = TextEditingController(text: existing?.period ?? '');
    final bulletCtrl = TextEditingController(text: existing?.bulletPoints.join('\n') ?? '');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        final viewInsetsBottom = MediaQuery.of(ctx).viewInsets.bottom;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            bottom: viewInsetsBottom + (bottomPadding > 0 ? bottomPadding + 16 : 28),
            left: 20,
            right: 20,
            top: 14,
          ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existing != null ? AppStrings.editExperience : AppStrings.addExperience,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: posCtrl,
                label: AppStrings.positionLabel,
                hint: AppStrings.positionHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: compCtrl,
                label: AppStrings.companyNameLabel,
                hint: AppStrings.companyNameHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: periodCtrl,
                      label: AppStrings.workPeriod,
                      hint: AppStrings.workPeriodHint,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: cityCtrl,
                      label: AppStrings.locationLabel,
                      hint: AppStrings.locationHint,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: bulletCtrl,
                label: AppStrings.responsibilitiesLabel,
                hint: AppStrings.responsibilitiesHint,
                isDark: isDark,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF52525B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (posCtrl.text.trim().isEmpty) return;
                        final bullets = bulletCtrl.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        final item = ExperienceItem(
                          id: existing?.id ?? _uuid.v4(),
                          position: posCtrl.text.trim(),
                          companyOrProject: compCtrl.text.trim(),
                          cityCountry: cityCtrl.text.trim(),
                          period: periodCtrl.text.trim(),
                          bulletPoints: bullets,
                        );

                        setState(() {
                          if (index != null) {
                            _experiences[index] = item;
                          } else {
                            _experiences.add(item);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonochrome
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : primaryColor,
                        foregroundColor: isMonochrome
                            ? (isDark ? const Color(0xFF18181B) : Colors.white)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.save, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  void _showCertificationDialog({CertificationItem? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final orgCtrl = TextEditingController(text: existing?.organization ?? '');
    final yearCtrl = TextEditingController(text: existing?.year ?? '');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        final viewInsetsBottom = MediaQuery.of(ctx).viewInsets.bottom;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            bottom: viewInsetsBottom + (bottomPadding > 0 ? bottomPadding + 16 : 28),
            left: 20,
            right: 20,
            top: 14,
          ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    existing != null ? AppStrings.editCertification : AppStrings.addCertification,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: titleCtrl,
                label: AppStrings.certificateName,
                hint: AppStrings.certificateHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: orgCtrl,
                label: AppStrings.issuerOrg,
                hint: AppStrings.issuerHint,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: yearCtrl,
                label: AppStrings.obtainedYear,
                hint: AppStrings.yearHint,
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        AppStrings.cancel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF52525B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        final item = CertificationItem(
                          id: existing?.id ?? _uuid.v4(),
                          title: titleCtrl.text.trim(),
                          organization: orgCtrl.text.trim().isEmpty ? null : orgCtrl.text.trim(),
                          year: yearCtrl.text.trim().isEmpty ? null : yearCtrl.text.trim(),
                        );

                        setState(() {
                          if (index != null) {
                            _certifications[index] = item;
                          } else {
                            _certifications.add(item);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonochrome
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : primaryColor,
                        foregroundColor: isMonochrome
                            ? (isDark ? const Color(0xFF18181B) : Colors.white)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.save, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // --- Reusable UI Helpers ---
  Widget _buildItemCard({
    required String title,
    required String subtitle,
    String? extra,
    required bool isDark,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    extra,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isMonochrome
                          ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))
                          : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.pencil, size: 17),
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, size: 17, color: Color(0xFFEF4444)),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMonochrome
                ? (isDark ? Colors.white38 : Colors.black26)
                : const Color(0xFF6366F1).withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isMonochrome
                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                  : primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = AppColors.getPrimary(isDark: isDark, isMonochrome: isMonochrome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isMonochrome
                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                    : primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
