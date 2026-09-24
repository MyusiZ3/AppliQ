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
                  ? 'Signature loaded in memory (will not be saved to cloud)'
                  : 'Tanda tangan berhasil dimuat! (Hanya di memori lokal)',
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
      _isEnglish ? 'Digital signature cleared' : 'Tanda tangan digital dihapus',
    );
  }

  void _copyCoverLetterText() {
    final text = CoverLetterPdfBuilder.generatePlainText(
      widget.resume,
      companyName: _companyNameCtrl.text.trim(),
      companyAddress: _companyAddressCtrl.text.trim(),
      targetPosition: _targetPositionCtrl.text.trim(),
      letterDate: _letterDate,
      customAttachments: _attachments,
      isEnglish: _isEnglish,
    );
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    UIHelper.showSuccessSnackBar(
      context,
      _isEnglish
          ? 'Cover letter text copied to clipboard!'
          : 'Teks Cover Letter berhasil disalin ke clipboard!',
    );
  }

  void _showCoverLetterSettingsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;
    final cardBg = isDark ? const Color(0xFF202024) : const Color(0xFFF4F4F5);
    final borderColor = isDark ? const Color(0xFF27272A) : AppColors.borderLight;
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
              bottom: viewInsetsBottom + (bottomPadding > 0 ? bottomPadding + 16 : 28),
              left: 20,
              right: 20,
              top: 16,
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
                      width: 40,
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
                        AppStrings.customizeCoverLetter,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 12),

                  // 1. Company Name
                  TextField(
                    controller: _companyNameCtrl,
                    decoration: InputDecoration(
                      labelText: _isEnglish ? 'Target Company Name' : 'Nama Perusahaan Tujuan',
                      hintText: _isEnglish ? 'e.g. Google / Microsoft' : 'Contoh: PT Telkom Indonesia',
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. Target Position
                  TextField(
                    controller: _targetPositionCtrl,
                    decoration: InputDecoration(
                      labelText: _isEnglish ? 'Applied Position' : 'Posisi yang Dilamar',
                      hintText: _isEnglish ? 'e.g. Software Engineer' : 'Contoh: Mobile Developer',
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Company Address
                  TextField(
                    controller: _companyAddressCtrl,
                    decoration: InputDecoration(
                      labelText: _isEnglish ? 'Company Address / City' : 'Alamat / Kota Perusahaan',
                      hintText: _isEnglish ? 'e.g. Jakarta, Indonesia' : 'Contoh: Jakarta Selatan',
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Letter Date Picker
                  Text(
                    _isEnglish ? 'Letter Date' : 'Tanggal Surat',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar, size: 18, color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(width: 10),
                          Text(
                            '${_letterDate.day}/${_letterDate.month}/${_letterDate.year}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _isEnglish ? 'Change' : 'Ubah Tanggal',
                            style: TextStyle(
                              fontSize: 12,
                              color: isMonochrome
                                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                                  : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Enclosed Attachments List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEnglish
                            ? 'Enclosed Attachments (${_attachments.length} items)'
                            : 'Daftar Lampiran (${_attachments.length} berkas)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                              title: Text(
                                _isEnglish ? 'Add Attachment' : 'Tambah Lampiran',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              content: TextField(
                                controller: newAttachmentCtrl,
                                decoration: InputDecoration(
                                  hintText: _isEnglish ? 'e.g. Portfolio PDF' : 'Contoh: Surat Rekomendasi',
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
                        label: Text(_isEnglish ? 'Add' : 'Tambah', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
                      itemBuilder: (ctx, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _attachments[i],
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.trash, size: 16, color: Color(0xFFEF4444)),
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

                  // 6. Transient Digital Signature
                  Text(
                    AppStrings.digitalSignature,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEnglish
                        ? 'Signature is kept in local memory during PDF generation and never uploaded to cloud.'
                        : 'Tanda tangan hanya diproses di memori lokal saat generate PDF dan tidak disimpan di cloud.',
                    style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.textHintDark : AppColors.textHint),
                  ),
                  const SizedBox(height: 10),
                  if (_signatureBytes != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Image.memory(_signatureBytes!, width: 70, height: 40, fit: BoxFit.contain),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.signatureActive,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash, color: Color(0xFFEF4444)),
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
                          label: Text(_signatureBytes == null ? AppStrings.uploadSignature : AppStrings.changeSignature),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.applyChanges, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMonochrome = ThemeManager.isMonochrome;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
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
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F4F5),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Language switcher (available on both tabs)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ActionChip(
              avatar: Text(_isEnglish ? '🇬🇧' : '🇮🇩', style: const TextStyle(fontSize: 14)),
              label: Text(
                _isEnglish ? 'English' : 'Indonesia',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                ),
              ),
              backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _isEnglish = !_isEnglish);
              },
            ),
          ),
          if (_tabController.index == 1) ...[
            IconButton(
              tooltip: _isEnglish ? 'Copy Plain Text' : 'Salin Teks Lengkap',
              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 20),
              color: isDark ? Colors.white : const Color(0xFF18181B),
              onPressed: _copyCoverLetterText,
            ),
            IconButton(
              tooltip: _isEnglish ? 'Letter Settings' : 'Pengaturan Surat',
              icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
              color: isMonochrome
                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                  : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
              onPressed: _showCoverLetterSettingsSheet,
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isMonochrome
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : AppColors.pastelLime,
          indicatorWeight: 3,
          labelColor: isMonochrome
              ? (isDark ? Colors.white : const Color(0xFF18181B))
              : (isDark ? AppColors.pastelLime : const Color(0xFF18181B)),
          unselectedLabelColor: isDark ? AppColors.textHintDark : AppColors.textHint,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              icon: const Icon(CupertinoIcons.doc_text, size: 18),
              text: AppStrings.previewCvAts,
            ),
            Tab(
              icon: const Icon(CupertinoIcons.mail, size: 18),
              text: AppStrings.coverLetterTitle,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: CV ATS Preview
          PdfPreview(
            build: (format) => CvAtsPdfBuilder.buildPdf(
              widget.resume,
              isEnglish: _isEnglish,
            ),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: 'CV_ATS_${widget.resume.fullName.replaceAll(' ', '_')}.pdf',
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
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: 'Cover_Letter_${widget.resume.fullName.replaceAll(' ', '_')}.pdf',
          ),
        ],
      ),
    );
  }
}
