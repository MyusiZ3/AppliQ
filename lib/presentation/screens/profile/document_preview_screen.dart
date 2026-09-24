import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/cover_letter_pdf_builder.dart';
import '../../../core/utils/cv_ats_pdf_builder.dart';
import '../../../data/models/user_resume.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/ui_helper.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final UserResume resume;
  final int initialTab; // 0 = CV ATS, 1 = Cover Letter
  final String? initialCompanyName;
  final String? initialPosition;
  final String? initialCompanyAddress;

  const DocumentPreviewScreen({
    super.key,
    required this.resume,
    this.initialTab = 0,
    this.initialCompanyName,
    this.initialPosition,
    this.initialCompanyAddress,
  });

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isEnglish;

  // Cover Letter Dynamic Parameters
  late TextEditingController _companyNameCtrl;
  late TextEditingController _targetPositionCtrl;
  late TextEditingController _companyAddressCtrl;
  DateTime _letterDate = DateTime.now();
  late List<String> _attachments;

  // Single-use Transient Digital Signature (In-Memory Only)
  Uint8List? _signatureBytes;

  @override
  void initState() {
    super.initState();
    _isEnglish = LanguageManager.isEnglish;
    _attachments = List<String>.from(
      widget.resume.selectedAttachments.isNotEmpty
          ? widget.resume.selectedAttachments
          : [
              'Curriculum Vitae (CV)',
              'Fotokopi Ijazah & Transkrip Nilai',
              'Fotokopi KTP',
              'Fotokopi SKCK',
              'Pas Foto Terbaru (ukuran 3x4)',
              'Dokumen pendukung lainnya (jika ada)',
            ],
    );

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _companyNameCtrl = TextEditingController(
      text: widget.initialCompanyName ?? '',
    );
    _targetPositionCtrl = TextEditingController(
      text: widget.initialPosition ?? (widget.resume.targetJobPosition ?? ''),
    );
    _companyAddressCtrl = TextEditingController(
      text: widget.initialCompanyAddress ?? '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameCtrl.dispose();
    _targetPositionCtrl.dispose();
    _companyAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSignatureImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes != null) {
          setState(() {
            _signatureBytes = bytes;
          });
          if (mounted) {
            UIHelper.showSuccessSnackBar(
              context,
              _isEnglish
                  ? 'Digital signature loaded (in memory only, never saved to cloud)'
                  : 'Tanda tangan berhasil dimuat! (Hanya di memori lokal, aman)',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  void _clearSignature() {
    setState(() {
      _signatureBytes = null;
    });
    UIHelper.showInfoSnackBar(
      context,
      _isEnglish ? 'Digital signature removed' : 'Tanda tangan digital dihapus',
    );
  }

  void _copyCurrentText() {
    HapticFeedback.selectionClick();
    final String text;
    if (_tabController.index == 0) {
      text = CvAtsPdfBuilder.generatePlainText(widget.resume,
          isEnglish: _isEnglish);
    } else {
      text = CoverLetterPdfBuilder.generatePlainText(
        widget.resume,
        companyName: _companyNameCtrl.text.trim(),
        companyAddress: _companyAddressCtrl.text.trim(),
        targetPosition: _targetPositionCtrl.text.trim(),
        letterDate: _letterDate,
        customAttachments: _attachments,
        isEnglish: _isEnglish,
      );
    }
    Clipboard.setData(ClipboardData(text: text));
    UIHelper.showSuccessSnackBar(
      context,
      _isEnglish
          ? (_tabController.index == 0
              ? 'CV plain text copied to clipboard!'
              : 'Cover letter text copied to clipboard!')
          : (_tabController.index == 0
              ? 'Teks CV berhasil disalin ke clipboard!'
              : 'Teks Surat Lamaran berhasil disalin ke clipboard!'),
    );
  }

  Future<void> _shareOrSaveCurrentPdf() async {
    HapticFeedback.mediumImpact();
    try {
      final Uint8List pdfBytes;
      final String fileName;
      if (_tabController.index == 0) {
        pdfBytes = await CvAtsPdfBuilder.buildPdf(widget.resume,
            isEnglish: _isEnglish);
        fileName = 'CV_ATS_${widget.resume.fullName.replaceAll(' ', '_')}.pdf';
      } else {
        pdfBytes = await CoverLetterPdfBuilder.buildPdf(
          widget.resume,
          companyName: _companyNameCtrl.text.trim(),
          companyAddress: _companyAddressCtrl.text.trim(),
          targetPosition: _targetPositionCtrl.text.trim(),
          signatureImageBytes: _signatureBytes,
          letterDate: _letterDate,
          customAttachments: _attachments,
          isEnglish: _isEnglish,
        );
        fileName =
            'Cover_Letter_${widget.resume.fullName.replaceAll(' ', '_')}.pdf';
      }
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  Future<void> _printCurrentPdf() async {
    HapticFeedback.lightImpact();
    try {
      if (_tabController.index == 0) {
        await Printing.layoutPdf(
          onLayout: (format) =>
              CvAtsPdfBuilder.buildPdf(widget.resume, isEnglish: _isEnglish),
          name: 'CV_ATS_${widget.resume.fullName.replaceAll(' ', '_')}',
        );
      } else {
        await Printing.layoutPdf(
          onLayout: (format) => CoverLetterPdfBuilder.buildPdf(
            widget.resume,
            companyName: _companyNameCtrl.text.trim(),
            companyAddress: _companyAddressCtrl.text.trim(),
            targetPosition: _targetPositionCtrl.text.trim(),
            signatureImageBytes: _signatureBytes,
            letterDate: _letterDate,
            customAttachments: _attachments,
            isEnglish: _isEnglish,
          ),
          name: 'Cover_Letter_${widget.resume.fullName.replaceAll(' ', '_')}',
        );
      }
    } catch (e) {
      if (mounted) UIHelper.handleError(context, e);
    }
  }

  void _showCoverLetterSettingsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final cardBg = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final newAttachmentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            padding: EdgeInsets.only(
              bottom: viewInsetsBottom +
                  (bottomPadding > 0 ? bottomPadding + 16 : 28),
              left: 20,
              right: 20,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3F3F46)
                            : const Color(0xFFD4D4D8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.customizeCoverLetter,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEnglish
                                ? 'Customize recipient, date, signature & attachments'
                                : 'Sesuaikan tujuan surat, tanggal, tanda tangan & lampiran',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill,
                            size: 22),
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 1: Detail Tujuan
                  Text(
                    _isEnglish
                        ? 'TARGET COMPANY & ROLE'
                        : 'DETAIL PERUSAHAAN TUJUAN',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color:
                          isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 1. Company Name
                  TextField(
                    controller: _companyNameCtrl,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF18181B)),
                    decoration: InputDecoration(
                      labelText: _isEnglish
                          ? 'Target Company Name'
                          : 'Nama Perusahaan Tujuan',
                      hintText: _isEnglish
                          ? 'e.g. Google / Microsoft'
                          : 'Contoh: PT Telkom Indonesia',
                      filled: true,
                      fillColor: cardBg,
                      prefixIcon:
                          const Icon(CupertinoIcons.building_2_fill, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Target Position
                  TextField(
                    controller: _targetPositionCtrl,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF18181B)),
                    decoration: InputDecoration(
                      labelText: _isEnglish
                          ? 'Applied Position'
                          : 'Posisi yang Dilamar',
                      hintText: _isEnglish
                          ? 'e.g. Software Engineer'
                          : 'Contoh: Mobile Developer',
                      filled: true,
                      fillColor: cardBg,
                      prefixIcon:
                          const Icon(CupertinoIcons.briefcase_fill, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Company Address
                  TextField(
                    controller: _companyAddressCtrl,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF18181B)),
                    decoration: InputDecoration(
                      labelText: _isEnglish
                          ? 'Company Address / City'
                          : 'Alamat / Kota Perusahaan',
                      hintText: _isEnglish
                          ? 'e.g. Jakarta, Indonesia'
                          : 'Contoh: Jakarta Selatan',
                      filled: true,
                      fillColor: cardBg,
                      prefixIcon:
                          const Icon(CupertinoIcons.location_solid, size: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor, width: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Tanggal Surat
                  Text(
                    _isEnglish ? 'LETTER DATE' : 'TANGGAL SURAT',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color:
                          isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _letterDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => _letterDate = picked);
                        setState(() => _letterDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(width: 10),
                          Text(
                            '${_letterDate.day}/${_letterDate.month}/${_letterDate.year}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _isEnglish ? 'Change' : 'Ubah Tanggal',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMonochrome
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF18181B))
                                  : (isDark
                                      ? AppColors.pastelLime
                                      : const Color(0xFF18181B)),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Daftar Lampiran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEnglish
                            ? 'ENCLOSED ATTACHMENTS (${_attachments.length})'
                            : 'DAFTAR LAMPIRAN BERKAS (${_attachments.length})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor:
                                  isDark ? AppColors.surfaceDark : Colors.white,
                              title: Text(
                                _isEnglish
                                    ? 'Add Attachment'
                                    : 'Tambah Lampiran',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              content: TextField(
                                controller: newAttachmentCtrl,
                                decoration: InputDecoration(
                                  hintText: _isEnglish
                                      ? 'e.g. Portfolio PDF'
                                      : 'Contoh: Surat Rekomendasi',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dCtx),
                                  child: Text(AppStrings.cancel),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final val = newAttachmentCtrl.text.trim();
                                    if (val.isNotEmpty) {
                                      setSheetState(() {
                                        _attachments.add(val);
                                      });
                                      setState(() {});
                                      newAttachmentCtrl.clear();
                                    }
                                    Navigator.pop(dCtx);
                                  },
                                  child: Text(AppStrings.save),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.plus, size: 14),
                        label: Text(_isEnglish ? 'Add' : 'Tambah',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: borderColor, indent: 32),
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textHintDark
                                      : AppColors.textHint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _attachments[i],
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.trash,
                                    size: 16, color: Color(0xFFEF4444)),
                                onPressed: () {
                                  setSheetState(() {
                                    _attachments.removeAt(i);
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Digital Signature
                  Text(
                    _isEnglish ? 'DIGITAL SIGNATURE' : 'TANDA TANGAN DIGITAL',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color:
                          isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEnglish
                        ? 'Signature is kept in local memory during PDF generation and never uploaded to cloud.'
                        : 'Tanda tangan hanya diproses di memori lokal saat generate PDF dan tidak disimpan di cloud.',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint),
                  ),
                  const SizedBox(height: 10),
                  if (_signatureBytes != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Image.memory(_signatureBytes!,
                              width: 70, height: 40, fit: BoxFit.contain),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.signatureActive,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash,
                                color: Color(0xFFEF4444)),
                            onPressed: () {
                              _clearSignature();
                              setSheetState(() {});
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _pickSignatureImage();
                            setSheetState(() {});
                            setState(() {});
                          },
                          icon: const Icon(CupertinoIcons.signature, size: 16),
                          label: Text(_signatureBytes == null
                              ? AppStrings.uploadSignature
                              : AppStrings.changeSignature),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonochrome
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : AppColors.pastelLime,
                        foregroundColor: isMonochrome
                            ? (isDark ? const Color(0xFF18181B) : Colors.white)
                            : AppColors.textOnPastel,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.applyChanges,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      newAttachmentCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryBtnTextColor = isMonochrome
        ? (isDark ? const Color(0xFF18181B) : Colors.white)
        : AppColors.textOnPastel;
    final outlinedTextColor = isDark ? Colors.white : const Color(0xFF18181B);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          AppStrings.documentPreviewTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Language Switcher Pill Toggle
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isEnglish = !_isEnglish);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFE4E4E7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFD4D4D8),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isEnglish ? '🇬🇧 English' : '🇮🇩 Indonesia',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Sleek Segmented Switcher (CV ATS vs Cover Letter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isMonochrome
                      ? (isDark ? Colors.white : const Color(0xFF18181B))
                      : AppColors.pastelLime,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: isMonochrome
                    ? (isDark ? const Color(0xFF18181B) : Colors.white)
                    : AppColors.textOnPastel,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.doc_text_fill, size: 15),
                        const SizedBox(width: 6),
                        Text(AppStrings.previewCvAts),
                      ],
                    ),
                  ),
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.mail_solid, size: 15),
                        const SizedBox(width: 6),
                        Text(AppStrings.coverLetterTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Contextual Cover Letter Target Info Banner (Only when Cover Letter tab is active)
          if (_tabController.index == 1) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF27272A)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.building_2_fill,
                        size: 14,
                        color: isDark
                            ? AppColors.pastelLime
                            : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _companyNameCtrl.text.trim().isNotEmpty
                                ? _companyNameCtrl.text.trim()
                                : (_isEnglish
                                    ? 'Target Company (Not Set)'
                                    : 'Nama Perusahaan (Belum Diisi)'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${_targetPositionCtrl.text.trim().isNotEmpty ? _targetPositionCtrl.text.trim() : (_isEnglish ? 'Position' : 'Posisi')} • ${_letterDate.day}/${_letterDate.month}/${_letterDate.year}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showCoverLetterSettingsSheet();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isMonochrome
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF18181B))
                              : (isDark
                                  ? AppColors.pastelLime.withValues(alpha: 0.18)
                                  : AppColors.pastelLime
                                      .withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMonochrome
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF18181B))
                                : (isDark
                                    ? AppColors.pastelLime
                                    : const Color(0xFF18181B)),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.slider_horizontal_3,
                              size: 13,
                              color: isMonochrome
                                  ? (isDark
                                      ? const Color(0xFF18181B)
                                      : Colors.white)
                                  : (isDark
                                      ? AppColors.pastelLime
                                      : const Color(0xFF18181B)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isEnglish ? 'Customize' : 'Atur Surat',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isMonochrome
                                    ? (isDark
                                        ? const Color(0xFF18181B)
                                        : Colors.white)
                                    : (isDark
                                        ? AppColors.pastelLime
                                        : const Color(0xFF18181B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 3. Document View Area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: CV ATS Preview
                PdfPreview(
                  build: (format) => CvAtsPdfBuilder.buildPdf(
                    widget.resume,
                    isEnglish: _isEnglish,
                  ),
                  useActions: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName:
                      'CV_ATS_${widget.resume.fullName.replaceAll(' ', '_')}.pdf',
                ),

                // Tab 2: Cover Letter Preview
                PdfPreview(
                  build: (format) => CoverLetterPdfBuilder.buildPdf(
                    widget.resume,
                    companyName: _companyNameCtrl.text.trim(),
                    companyAddress: _companyAddressCtrl.text.trim(),
                    targetPosition: _targetPositionCtrl.text.trim(),
                    signatureImageBytes: _signatureBytes,
                    letterDate: _letterDate,
                    customAttachments: _attachments,
                    isEnglish: _isEnglish,
                  ),
                  useActions: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName:
                      'Cover_Letter_${widget.resume.fullName.replaceAll(' ', '_')}.pdf',
                ),
              ],
            ),
          ),

          // 4. Sleek Floating Bottom Action Dock
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 14,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: cardBorder,
                  width: 0.8,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Copy Plain Text button (Expanded)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyCurrentText,
                    icon: Icon(CupertinoIcons.doc_on_clipboard,
                        size: 16, color: outlinedTextColor),
                    label: Text(
                      _isEnglish ? 'Copy Text' : 'Salin Teks',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: outlinedTextColor,
                      iconColor: outlinedTextColor,
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF3F3F46)
                            : const Color(0xFFD4D4D8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Print button (Centered)
                IconButton(
                  tooltip: _isEnglish ? 'Print Document' : 'Cetak Dokumen',
                  icon: const Icon(CupertinoIcons.printer, size: 18),
                  color: isDark ? Colors.white70 : const Color(0xFF52525B),
                  onPressed: _printCurrentPdf,
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFF4F4F5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Primary Share PDF Button (Expanded - symmetric width)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareOrSaveCurrentPdf,
                    icon: Icon(
                      CupertinoIcons.share,
                      size: 18,
                      color: primaryBtnTextColor,
                    ),
                    label: Text(
                      _isEnglish ? 'Share PDF' : 'Bagikan PDF',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: primaryBtnTextColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMonochrome
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : AppColors.pastelLime,
                      foregroundColor: primaryBtnTextColor,
                      iconColor: primaryBtnTextColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
