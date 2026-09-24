import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../data/models/user_resume.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';
import '../../widgets/appliq_loading.dart';

class CareerScreen extends StatefulWidget {
  final JobRepository repository;

  const CareerScreen({super.key, required this.repository});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  UserResume? _resume;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResumeData();
  }

  Future<void> _loadResumeData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    try {
      final resume = await widget.repository.getUserResume(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _resume = resume ??
              UserResume(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: 'current_user',
                fullName: '',
                email: '',
                phoneNumber: '',
                cityCountry: '',
              );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _saveResume(UserResume updated) async {
    setState(() => _resume = updated);
    try {
      await widget.repository.saveUserResume(updated);
      widget.repository.notifyDataChanged();
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  String _formatDuration(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + end.month - start.month;
    final isEn = LanguageManager.isEnglish;
    if (months <= 0) {
      return isEn ? '< 1 mo' : '< 1 bln';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years > 0 && remainingMonths > 0) {
      return isEn
          ? '$years yr $remainingMonths mos'
          : '$years thn $remainingMonths bln';
    } else if (years > 0) {
      return isEn
          ? (years == 1 ? '1 yr' : '$years yrs')
          : '$years thn';
    } else {
      return isEn
          ? (remainingMonths == 1 ? '1 mo' : '$remainingMonths mos')
          : '$remainingMonths bln';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM yyyy').format(date);
  }

  Future<void> _showExperienceForm({ExperienceItem? itemToEdit, bool defaultAsCurrent = false}) async {
    _triggerHaptic();
    final isEditing = itemToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;

    final companyCtrl = TextEditingController(text: itemToEdit?.companyOrProject ?? '');
    final positionCtrl = TextEditingController(text: itemToEdit?.position ?? '');
    final locationCtrl = TextEditingController(text: itemToEdit?.cityCountry ?? '');
    final salaryCtrl = TextEditingController(
      text: (itemToEdit?.monthlySalary ?? 0) > 0
          ? NumberFormat('#,###', 'id_ID').format(itemToEdit!.monthlySalary)
          : '',
    );
    final notesCtrl = TextEditingController(text: itemToEdit?.notes ?? itemToEdit?.bulletPoints.join('\n') ?? '');

    bool isCurrent = itemToEdit?.isCurrentlyWorking ?? defaultAsCurrent;
    DateTime startDate = itemToEdit?.startDate ?? DateTime.now();
    DateTime? endDate = itemToEdit?.endDate ?? (isCurrent ? null : DateTime.now());
    String selectedType = itemToEdit?.employmentType ?? 'Full-time';

    final types = ['Full-time', 'Contract', 'Internship', 'Freelance', 'Part-time'];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final bottomInset = MediaQuery.of(modalCtx).viewInsets.bottom;
            final cardBg = AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
            final borderColor = AppColors.getBorder(isDark: isDark, isMonochrome: isMono);
            final primaryColor = isMono
                ? (isDark ? Colors.white : const Color(0xFF18181B))
                : AppColors.pastelLime;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalCtx).size.height * 0.90,
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: borderColor, width: 0.8),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? AppStrings.editExperience : AppStrings.addExperienceBtn,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 22),
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: borderColor),

                    // Form Fields
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Company Name
                            _buildInputLabel(AppStrings.companyNameLabel, isDark),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: companyCtrl,
                              hint: 'e.g. Google Indonesia / Tokopedia',
                              icon: CupertinoIcons.building_2_fill,
                              isDark: isDark,
                              isMono: isMono,
                            ),
                            const SizedBox(height: 14),

                            // Position Title
                            _buildInputLabel(AppStrings.positionLabel, isDark),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: positionCtrl,
                              hint: 'e.g. Senior Flutter Developer',
                              icon: CupertinoIcons.briefcase_fill,
                              isDark: isDark,
                              isMono: isMono,
                            ),
                            const SizedBox(height: 14),

                            // Location
                            _buildInputLabel(AppStrings.locationLabel, isDark),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: locationCtrl,
                              hint: 'e.g. Jakarta, Indonesia (Hybrid)',
                              icon: CupertinoIcons.location_solid,
                              isDark: isDark,
                              isMono: isMono,
                            ),
                            const SizedBox(height: 14),

                            // Currently Working Toggle
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: 0.8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.briefcase_fill,
                                    size: 16,
                                    color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppStrings.isCurrentlyWorkingCheckbox,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isCurrent,
                                    activeTrackColor: primaryColor,
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      setModalState(() {
                                        isCurrent = val;
                                        if (val) endDate = null;
                                        if (!val && endDate == null) endDate = DateTime.now();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Start & End Date Pickers
                            Row(
                              children: [
                                // Start Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel(AppStrings.startDateLabel, isDark),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () async {
                                          HapticFeedback.selectionClick();
                                          final firstDate = DateTime(1990);
                                          final lastDate = DateTime(2100);
                                          final initialDate = startDate.isBefore(firstDate)
                                              ? firstDate
                                              : (startDate.isAfter(lastDate) ? lastDate : startDate);
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: initialDate,
                                            firstDate: firstDate,
                                            lastDate: lastDate,
                                          );
                                          if (picked != null) {
                                            setModalState(() => startDate = picked);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF27272A)
                                                : const Color(0xFFF4F4F5),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: borderColor, width: 0.8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.calendar, size: 15, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat('MMM yyyy').format(startDate),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // End Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInputLabel(AppStrings.endDateLabel, isDark),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: isCurrent
                                            ? null
                                            : () async {
                                                HapticFeedback.selectionClick();
                                                final firstDate = DateTime(1990);
                                                final lastDate = DateTime(2100);
                                                final targetInitial = endDate ?? (startDate.isAfter(DateTime.now()) ? startDate : DateTime.now());
                                                final initialDate = targetInitial.isBefore(firstDate)
                                                    ? firstDate
                                                    : (targetInitial.isAfter(lastDate) ? lastDate : targetInitial);

                                                final picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: initialDate,
                                                  firstDate: firstDate,
                                                  lastDate: lastDate,
                                                );
                                                if (picked != null) {
                                                  setModalState(() => endDate = picked);
                                                }
                                              },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? (isDark ? const Color(0xFF1A191E) : const Color(0xFFEBECEF))
                                                : (isDark
                                                    ? const Color(0xFF27272A)
                                                    : const Color(0xFFF4F4F5)),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: borderColor, width: 0.8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isCurrent ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.calendar,
                                                size: 15,
                                                color: isCurrent
                                                    ? (isDark ? AppColors.pastelLime : const Color(0xFF18181B))
                                                    : (isDark ? AppColors.textHintDark : AppColors.textHint),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isCurrent
                                                    ? AppStrings.presentLabel
                                                    : (endDate != null ? DateFormat('MMM yyyy').format(endDate!) : '-'),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCurrent
                                                      ? (isDark ? AppColors.pastelLime : const Color(0xFF18181B))
                                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Employment Type Chips
                            _buildInputLabel(AppStrings.filterEmploymentType, isDark),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: types.map((t) {
                                final isSelected = selectedType.toLowerCase() == t.toLowerCase();
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setModalState(() => selectedType = t);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isMono
                                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                                              : (isDark ? AppColors.pastelLime.withValues(alpha: 0.18) : AppColors.pastelLime.withValues(alpha: 0.35)))
                                          : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isMono
                                                ? (isDark ? Colors.white : const Color(0xFF18181B))
                                                : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)))
                                            : borderColor,
                                        width: isSelected ? 1.2 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected
                                            ? (isMono
                                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                                : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)))
                                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // Monthly Salary (Optional)
                            _buildInputLabel('${AppStrings.careerMonthlySalary} (Opsional)', isDark),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: salaryCtrl,
                              hint: 'e.g. 15.000.000',
                              icon: CupertinoIcons.money_dollar_circle,
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                              isMono: isMono,
                            ),
                            const SizedBox(height: 14),

                            // Notes / Responsibilities
                            _buildInputLabel(AppStrings.responsibilitiesLabel, isDark),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: notesCtrl,
                              hint: 'Contoh:\n• Mengembangkan fitur real-time tracking\n• Mengelola tim 4 engineer',
                              icon: CupertinoIcons.list_bullet,
                              maxLines: 4,
                              minLines: 3,
                              isDark: isDark,
                              isMono: isMono,
                            ),
                            const SizedBox(height: 20),

                            // Save Button
                            ElevatedButton(
                              onPressed: () {
                                final company = companyCtrl.text.trim();
                                final position = positionCtrl.text.trim();
                                if (company.isEmpty || position.isEmpty) {
                                  UIHelper.showErrorSnackBar(context, AppStrings.fillRequiredFields);
                                  return;
                                }

                                HapticFeedback.mediumImpact();
                                final salaryVal = double.tryParse(salaryCtrl.text.replaceAll(RegExp(r'\D'), ''));
                                final bulletList = notesCtrl.text
                                    .split('\n')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                                final formattedP = '${DateFormat('MMM yyyy').format(startDate)} - ${isCurrent ? AppStrings.presentLabel : (endDate != null ? DateFormat('MMM yyyy').format(endDate!) : '')}';

                                final updatedItem = ExperienceItem(
                                  id: itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                  companyOrProject: company,
                                  position: position,
                                  cityCountry: locationCtrl.text.trim(),
                                  period: formattedP,
                                  startDate: startDate,
                                  endDate: isCurrent ? null : endDate,
                                  isCurrentlyWorking: isCurrent,
                                  employmentType: selectedType,
                                  monthlySalary: salaryVal,
                                  notes: notesCtrl.text.trim(),
                                  bulletPoints: bulletList,
                                );

                                List<ExperienceItem> exps = List.from(_resume?.experiences ?? []);
                                if (isCurrent) {
                                  // Mark other items as not currently working if this is active
                                  exps = exps.map((e) {
                                    if (itemToEdit != null && e.id == itemToEdit.id) return e;
                                    return e.copyWith(isCurrentlyWorking: false);
                                  }).toList();
                                }

                                if (isEditing) {
                                  final idx = exps.indexWhere((e) => e.id == itemToEdit.id);
                                  if (idx != -1) {
                                    exps[idx] = updatedItem;
                                  } else {
                                    exps.insert(0, updatedItem);
                                  }
                                } else {
                                  exps.insert(0, updatedItem);
                                }

                                final updatedResume = (_resume ??
                                    UserResume(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      userId: 'current_user',
                                      fullName: '',
                                      email: '',
                                      phoneNumber: '',
                                      cityCountry: '',
                                    ))
                                    .copyWith(experiences: exps);

                                _saveResume(updatedResume);
                                Navigator.pop(modalCtx);
                                UIHelper.showSuccessSnackBar(context, AppStrings.resumeSavedSuccess);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: isMono
                                    ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                    : AppColors.textOnPastel,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                isEditing ? AppStrings.save : AppStrings.addExperienceBtn,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    companyCtrl.dispose();
    positionCtrl.dispose();
    locationCtrl.dispose();
    salaryCtrl.dispose();
    notesCtrl.dispose();
  }

  Future<void> _endJob(ExperienceItem item) async {
    _triggerHaptic();
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: item.startDate ?? DateTime(1990),
      lastDate: now.add(const Duration(days: 30)),
      helpText: AppStrings.endJobConfirmTitle,
    );

    if (pickedDate == null) return;

    final updatedPeriod = '${item.startDate != null ? DateFormat('MMM yyyy').format(item.startDate!) : ''} - ${DateFormat('MMM yyyy').format(pickedDate)}';
    final updatedItem = item.copyWith(
      isCurrentlyWorking: false,
      endDate: pickedDate,
      period: updatedPeriod,
    );

    if (_resume == null) return;
    final exps = _resume!.experiences.map((e) => e.id == item.id ? updatedItem : e).toList();
    final updatedResume = _resume!.copyWith(experiences: exps);
    await _saveResume(updatedResume);

    if (mounted) {
      UIHelper.showSuccessSnackBar(
        context,
        LanguageManager.isEnglish
            ? 'Position ended and moved to past work history.'
            : 'Masa kerja diselesaikan dan dipindahkan ke riwayat kerja.',
      );
    }
  }

  Future<void> _deleteExperience(ExperienceItem item) async {
    _triggerHaptic();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(AppStrings.deleteExperienceConfirmTitle),
        content: Text(AppStrings.deleteExperienceConfirmMessage),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_resume == null) return;
      final exps = _resume!.experiences.where((e) => e.id != item.id).toList();
      final updatedResume = _resume!.copyWith(experiences: exps);
      await _saveResume(updatedResume);
      if (mounted) {
        UIHelper.showSuccessSnackBar(context, AppStrings.successDeleted);
      }
    }
  }

  Widget _buildInputLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required bool isMono,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
    int minLines = 1,
  }) {
    final borderColor = AppColors.getBorder(isDark: isDark, isMonochrome: isMono);
    final isMulti = maxLines > 1;
    final effectiveKeyboardType = keyboardType ?? (isMulti ? TextInputType.multiline : TextInputType.text);
    final effectiveAction = textInputAction ?? (isMulti ? TextInputAction.newline : TextInputAction.next);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF27272A)
            : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 10 : 2),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 3 : 0),
            child: Icon(icon, size: 16, color: isDark ? AppColors.textHintDark : AppColors.textHint),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              minLines: minLines,
              keyboardType: effectiveKeyboardType,
              textInputAction: effectiveAction,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<AccentThemeMode>(
      valueListenable: ThemeManager.accentNotifier,
      builder: (context, accentMode, _) {
        final isMono = accentMode == AccentThemeMode.monochrome;
        final cardBg = AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
        final borderColor = AppColors.getBorder(isDark: isDark, isMonochrome: isMono);
        final primaryColor = isMono
            ? (isDark ? Colors.white : const Color(0xFF18181B))
            : AppColors.pastelLime;

        final experiences = _resume?.experiences ?? [];
        final activeRole = experiences.cast<ExperienceItem?>().firstWhere(
              (e) => e?.isCurrentlyWorking == true,
              orElse: () => null,
            );
        final pastExperiences = experiences.where((e) => e.isCurrentlyWorking != true).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
                          : const Color(0xFFF4F4F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_left,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              AppStrings.careerScreenTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () => _showExperienceForm(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isMono
                          ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                          : (isDark ? AppColors.pastelLime.withValues(alpha: 0.18) : AppColors.pastelLime.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isMono ? borderColor : (isDark ? AppColors.pastelLime.withValues(alpha: 0.4) : const Color(0xFF18181B)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.plus,
                          size: 13,
                          color: isMono
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          LanguageManager.isEnglish ? 'Add' : 'Tambah',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isMono
                                ? (isDark ? Colors.white : const Color(0xFF18181B))
                                : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: AppliqLoading())
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => _loadResumeData(forceRefresh: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      children: [
                        // Section 1: Currently Working (Active Role)
                        _buildCurrentlyWorkingSection(
                          activeRole: activeRole,
                          isDark: isDark,
                          isMono: isMono,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryColor: primaryColor,
                        ),
                        const SizedBox(height: 22),

                        // Section 2: Work History Timeline
                        _buildWorkHistorySection(
                          pastExperiences: pastExperiences,
                          isDark: isDark,
                          isMono: isMono,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCurrentlyWorkingSection({
    required ExperienceItem? activeRole,
    required bool isDark,
    required bool isMono,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentlyWorkingHeader,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppStrings.currentlyWorkingSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (activeRole != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppStrings.activeRoleBadge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (activeRole == null)
          // Empty State Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.briefcase,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.noCurrentlyWorking,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.noCurrentlyWorkingDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showExperienceForm(defaultAsCurrent: true),
                  icon: Icon(
                    CupertinoIcons.plus,
                    size: 14,
                    color: isMono
                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                        : (isDark ? AppColors.pastelLime : const Color(0xFF65A30D)),
                  ),
                  label: Text(AppStrings.setCurrentlyWorkingBtn),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isMono
                        ? (isDark ? Colors.white : const Color(0xFF18181B))
                        : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
                    side: BorderSide(
                      color: isMono
                          ? borderColor
                          : (isDark ? AppColors.pastelLime.withValues(alpha: 0.6) : const Color(0xFF18181B)),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          )
        else
          // Active Role Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isMono
                    ? borderColor
                    : (isDark ? AppColors.pastelLime.withValues(alpha: 0.3) : const Color(0xFF18181B).withValues(alpha: 0.15)),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
                            : (isMono ? const Color(0xFFF4F4F5) : AppColors.lightSurfaceVariantPastel),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Icon(
                        CupertinoIcons.building_2_fill,
                        color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeRole.position,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeRole.companyOrProject,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showActiveRoleOptions(activeRole),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Period & Duration Pill
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Start Date & Duration
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.clock, size: 12, color: isDark ? AppColors.pastelAmber : const Color(0xFF18181B)),
                          const SizedBox(width: 5),
                          Text(
                            activeRole.startDate != null
                                ? '${_formatDate(activeRole.startDate!)} – ${AppStrings.presentLabel} • ${_formatDuration(activeRole.startDate!, DateTime.now())}'
                                : activeRole.period,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Employment Type
                    if (activeRole.employmentType != null && activeRole.employmentType!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Text(
                          activeRole.employmentType!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),

                    // Location
                    if (activeRole.cityCountry.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.location_solid, size: 11, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              activeRole.cityCountry,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Notes / Bullet points if available
                if (activeRole.bulletPoints.isNotEmpty || (activeRole.notes != null && activeRole.notes!.isNotEmpty)) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (activeRole.bulletPoints.isNotEmpty
                              ? activeRole.bulletPoints
                              : (activeRole.notes?.split('\n') ?? []))
                          .take(3)
                          .map(
                            (pt) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pt.startsWith(RegExp(r'^(\d+|[a-zA-Z])[\.\)]')) ? '' : '• ',
                                    style: TextStyle(
                                      color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      pt.replaceFirst(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'), ''),
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _endJob(activeRole),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.expense : const Color(0xFFDC2626),
                          side: BorderSide(
                            color: (isDark ? AppColors.expense : const Color(0xFFDC2626)).withValues(alpha: 0.5),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          LanguageManager.isEnglish ? 'End Position' : 'Selesaikan Pekerjaan',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showExperienceForm(itemToEdit: activeRole),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: isMono
                              ? (isDark ? const Color(0xFF18181B) : Colors.white)
                              : AppColors.textOnPastel,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.edit,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showActiveRoleOptions(ExperienceItem item) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text('${item.position} @ ${item.companyOrProject}'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _showExperienceForm(itemToEdit: item);
            },
            child: Text(AppStrings.edit),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _endJob(item);
            },
            child: Text(LanguageManager.isEnglish ? 'End Position (Set End Date)' : 'Selesaikan Pekerjaan (Atur Tgl Selesai)'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _deleteExperience(item);
            },
            child: Text(AppStrings.delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(AppStrings.cancel),
        ),
      ),
    );
  }

  Widget _buildWorkHistorySection({
    required List<ExperienceItem> pastExperiences,
    required bool isDark,
    required bool isMono,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.workHistoryHeader,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${pastExperiences.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  AppStrings.workHistorySubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.plus_circle_fill, size: 24),
              color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
              onPressed: () => _showExperienceForm(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (pastExperiences.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(CupertinoIcons.archivebox, size: 28, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noWorkHistory,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.noWorkHistoryDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pastExperiences.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exp = pastExperiences[index];
              return _buildPastExperienceCard(
                exp: exp,
                isDark: isDark,
                isMono: isMono,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryColor: primaryColor,
              );
            },
          ),
      ],
    );
  }

  Widget _buildPastExperienceCard({
    required ExperienceItem exp,
    required bool isDark,
    required bool isMono,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Icon(
                  CupertinoIcons.briefcase,
                  color: isDark ? Colors.white70 : const Color(0xFF3F3F46),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.position,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exp.companyOrProject,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.pencil, size: 16),
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showExperienceForm(itemToEdit: exp),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, size: 16),
                    color: isDark ? AppColors.expense : const Color(0xFFDC2626),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _deleteExperience(exp),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Period & metadata row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exp.startDate != null && exp.endDate != null
                      ? '${_formatDate(exp.startDate!)} – ${_formatDate(exp.endDate!)} • ${_formatDuration(exp.startDate!, exp.endDate!)}'
                      : exp.period,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
              if (exp.employmentType != null && exp.employmentType!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exp.employmentType!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              if (exp.cityCountry.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exp.cityCountry,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                ),
            ],
          ),

          if (exp.bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...exp.bulletPoints.take(2).map(
                  (pt) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      pt.startsWith(RegExp(r'^(\d+|[a-zA-Z])[\.\)]'))
                          ? pt
                          : '• ${pt.replaceFirst(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'), '')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
