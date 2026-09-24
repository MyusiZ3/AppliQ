import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/job_description_parser.dart';
import '../../utils/theme_manager.dart';
import '../../utils/ui_helper.dart';

class JobDescriptionParserSheet extends StatefulWidget {
  final Set<String>? userCompanies;
  final Set<String>? userPositions;
  final Set<String>? userLocations;

  const JobDescriptionParserSheet({
    super.key,
    this.userCompanies,
    this.userPositions,
    this.userLocations,
  });

  static Future<ParsedJobDescription?> show(
    BuildContext context, {
    Set<String>? userCompanies,
    Set<String>? userPositions,
    Set<String>? userLocations,
  }) {
    return showModalBottomSheet<ParsedJobDescription>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDescriptionParserSheet(
        userCompanies: userCompanies,
        userPositions: userPositions,
        userLocations: userLocations,
      ),
    );
  }

  @override
  State<JobDescriptionParserSheet> createState() => _JobDescriptionParserSheetState();
}

class _JobDescriptionParserSheetState extends State<JobDescriptionParserSheet> {
  final TextEditingController _textController = TextEditingController();
  ParsedJobDescription? _preview;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      if (_preview != null) {
        setState(() => _preview = null);
      }
      return;
    }

    final parsed = JobDescriptionParser.parse(
      text,
      extraCompanies: widget.userCompanies,
      extraPositions: widget.userPositions,
      extraLocations: widget.userLocations,
    );
    setState(() => _preview = parsed);
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.lightImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      _textController.text = data.text!.trim();
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    } else {
      if (mounted) {
        UIHelper.showInfoSnackBar(context, AppStrings.smartParserNoText);
      }
    }
  }

  void _clearText() {
    HapticFeedback.selectionClick();
    _textController.clear();
  }

  void _applyToForm() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      UIHelper.showErrorSnackBar(context, AppStrings.smartParserNoText);
      return;
    }

    HapticFeedback.mediumImpact();
    final result = _preview ??
        JobDescriptionParser.parse(
          text,
          extraCompanies: widget.userCompanies,
          extraPositions: widget.userPositions,
          extraLocations: widget.userLocations,
        );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final primaryColor = isMonochrome
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : AppColors.pastelLime;
    final cardBg = AppColors.getSurface(isDark: isDark, isMonochrome: isMonochrome);
    final cardBorder = AppColors.getBorder(isDark: isDark, isMonochrome: isMonochrome);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final detectedCount = _preview?.detectedFieldCount ?? 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
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

            // Header Title & Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isMonochrome ? const Color(0xFF27272A) : AppColors.darkSurfaceVariantPastel)
                          : (isMonochrome ? const Color(0xFFF4F4F5) : AppColors.lightSurfaceVariantPastel),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: cardBorder, width: 0.8),
                    ),
                    child: Icon(
                      CupertinoIcons.doc_text_search,
                      color: primaryColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.smartParserTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          AppStrings.smartParserSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Toolbar: Paste from Clipboard & Clear
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pasteFromClipboard,
                          icon: Icon(
                            CupertinoIcons.doc_on_clipboard,
                            size: 14,
                            color: isDark ? Colors.white : const Color(0xFF18181B),
                          ),
                          label: Text(
                            AppStrings.smartParserPasteClipboard,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF18181B),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const Spacer(),
                        if (_textController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: _clearText,
                            icon: const Icon(CupertinoIcons.trash, size: 14),
                            label: Text(
                              AppStrings.smartParserClear,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.expense,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Input Text Area
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isMonochrome ? const Color(0xFF27272A).withValues(alpha: 0.6) : const Color(0xFF1A191F))
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF33323B) : const Color(0xFFE4E4E7),
                          width: 0.8,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: TextField(
                        controller: _textController,
                        maxLines: 7,
                        minLines: 4,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: AppStrings.smartParserPasteHint,
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),

                    // Live Detection Preview
                    if (_preview != null && detectedCount > 0) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.text_badge_checkmark,
                            size: 16,
                            color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            AppStrings.smartParserDetectedBadge,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (isMonochrome ? const Color(0xFF3F3F46) : AppColors.pastelLime.withValues(alpha: 0.18))
                                  : (isMonochrome ? const Color(0xFFE4E4E7) : AppColors.pastelLime.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$detectedCount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.pastelLime : const Color(0xFF18181B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_preview!.companyName != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.building_2_fill,
                              label: _preview!.companyName!,
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.positionTitle != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.briefcase,
                              label: _preview!.positionTitle!,
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.location != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.location_solid,
                              label: _preview!.location!,
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.workSystem != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.desktopcomputer,
                              label: AppStrings.localizedWorkSystem(_preview!.workSystem!),
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.employmentType != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.tag,
                              label: AppStrings.localizedEmploymentType(_preview!.employmentType!),
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.salaryExpectation != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.money_dollar_circle,
                              label: 'Rp ${_preview!.salaryExpectation!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.jobPortal != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.globe,
                              label: _preview!.jobPortal!.label,
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                          if (_preview!.jobUrl != null)
                            _buildPreviewChip(
                              icon: CupertinoIcons.link,
                              label: 'URL Link',
                              isDark: isDark,
                              isMonochrome: isMonochrome,
                              primaryColor: primaryColor,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: ElevatedButton(
                onPressed: _applyToForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: isMonochrome
                      ? (isDark ? const Color(0xFF18181B) : Colors.white)
                      : AppColors.textOnPastel,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _textController.text.isEmpty
                      ? AppStrings.smartParserButton
                      : AppStrings.smartParserApplyToForm,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewChip({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isMonochrome,
    required Color primaryColor,
  }) {
    final chipBg = isDark
        ? (isMonochrome ? const Color(0xFF27272A) : const Color(0xFF1A191F))
        : const Color(0xFFF4F4F5);
    final chipBorder = isDark
        ? (isMonochrome ? const Color(0xFF3F3F46) : const Color(0xFF33323B))
        : const Color(0xFFE4E4E7);
    final iconColor = isMonochrome
        ? (isDark ? Colors.white70 : const Color(0xFF52525B))
        : (isDark ? AppColors.pastelLime : const Color(0xFF18181B));
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: chipBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
