import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/job_application.dart';
import '../../utils/language_manager.dart';
import '../../utils/ui_helper.dart';

class ExportSheet extends StatefulWidget {
  final List<JobApplication> applications;

  const ExportSheet({super.key, required this.applications});

  static void show(BuildContext context, List<JobApplication> applications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(applications: applications),
    );
  }

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  bool _isPdfLoading = false;
  bool _isCsvLoading = false;

  String _generateCsv() {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
        'No,Perusahaan,Posisi,Sistem Kerja,Portal Lowongan,Status,Tanggal Melamar,Ekspektasi Gaji,Gaji Ditawarkan,Lokasi,Catatan');

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int i = 0; i < widget.applications.length; i++) {
      final app = widget.applications[i];
      final applied = dateFormat.format(app.appliedDate);
      final expSalary = app.salaryExpectation?.toStringAsFixed(0) ?? '-';
      final offSalary = app.salaryOffered?.toStringAsFixed(0) ?? '-';
      final notes =
          (app.notes ?? '-').replaceAll('\n', ' ').replaceAll(',', ';');
      final location = (app.location ?? '-').replaceAll(',', ';');

      buffer.writeln(
        '"${i + 1}","${app.companyName}","${app.positionTitle}","${app.workSystem.label}","${app.jobPortal.label}","${app.status.label}","$applied","$expSalary","$offSalary","$location","$notes"',
      );
    }

    return buffer.toString();
  }

  Future<void> _copyCsv() async {
    if (_isCsvLoading || _isPdfLoading) return;
    setState(() => _isCsvLoading = true);
    HapticFeedback.lightImpact();

    try {
      final csv = _generateCsv();
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        Navigator.of(context).pop();
        UIHelper.showSuccessSnackBar(context,
            'Format CSV (${widget.applications.length} lamaran) berhasil disalin!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCsvLoading = false);
        UIHelper.handleError(context, e);
      }
    }
  }

  Future<void> _exportPdf() async {
    if (_isPdfLoading || _isCsvLoading) return;
    setState(() => _isPdfLoading = true);
    HapticFeedback.lightImpact();

    try {
      final doc = pw.Document();
      final dateFormat = DateFormat('dd MMM yyyy');
      final currencyFormat = NumberFormat('#,###', 'id_ID');

      pw.Font? regularFont;
      pw.Font? boldFont;

      try {
        regularFont = await PdfGoogleFonts.interRegular();
        boldFont = await PdfGoogleFonts.interBold();
      } catch (_) {
        regularFont = pw.Font.helvetica();
        boldFont = pw.Font.helveticaBold();
      }

      final theme = pw.ThemeData.withFont(
        base: regularFont,
        bold: boldFont,
      );

      // Load AppliQ Logo
      pw.MemoryImage? logoImage;
      try {
        final logoData = await rootBundle.load('assets/images/appliq_logo.png');
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (_) {}

      // Calculate Stats for KPI Cards
      final totalApps = widget.applications.length;
      final interviewApps = widget.applications
          .where((a) =>
              a.status == ApplicationStatus.interview ||
              a.status == ApplicationStatus.offering ||
              a.status == ApplicationStatus.accepted)
          .length;
      final acceptedApps = widget.applications
          .where((a) =>
              a.status == ApplicationStatus.accepted ||
              a.status == ApplicationStatus.offering)
          .length;
      final activeApps = widget.applications
          .where((a) => a.status == ApplicationStatus.applied)
          .length;

      doc.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          header: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                      color: PdfColor.fromInt(0xFFE4E4E7), width: 1),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 32,
                          height: 32,
                          margin: const pw.EdgeInsets.only(right: 10),
                          child: pw.Image(logoImage),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'AppliQ',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor.fromInt(0xFF18181B),
                              letterSpacing: -0.5,
                            ),
                          ),
                          pw.Text(
                            'Laporan Rekapitulasi Lamaran Kerja',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFFF4F4F5),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFFE4E4E7),
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          'Total: $totalApps Lamaran',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF18181B),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Dicetak: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromInt(0xFFA1A1AA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context ctx) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 12),
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColor.fromInt(0xFFE4E4E7), width: 0.8),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'AppliQ | Smart Job Application Tracker',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColor.fromInt(0xFFA1A1AA)),
                  ),
                  pw.Text(
                    'Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColor.fromInt(0xFF71717A)),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context ctx) => [
            // KPI Summary Row (Executive Summary at top)
            pw.Row(
              children: [
                _buildPdfKpiCard('TOTAL LAMARAN', '$totalApps',
                    const PdfColor.fromInt(0xFF18181B)),
                pw.SizedBox(width: 8),
                _buildPdfKpiCard('TAHAP INTERVIEW', '$interviewApps',
                    const PdfColor.fromInt(0xFF2563EB)),
                pw.SizedBox(width: 8),
                _buildPdfKpiCard('OFFERING / DITERIMA', '$acceptedApps',
                    const PdfColor.fromInt(0xFF059669)),
                pw.SizedBox(width: 8),
                _buildPdfKpiCard('MENUNGGU RESPON', '$activeApps',
                    const PdfColor.fromInt(0xFFD97706)),
              ],
            ),
            pw.SizedBox(height: 14),

            if (widget.applications.isEmpty)
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 40),
                  child: pw.Text(
                    'Belum ada data riwayat lamaran kerja yang tersimpan.',
                    style: const pw.TextStyle(
                        fontSize: 11, color: PdfColor.fromInt(0xFF71717A)),
                  ),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: const pw.BorderSide(
                    color: PdfColor.fromInt(0xFFF1F5F9),
                    width: 0.6,
                  ),
                  bottom: const pw.BorderSide(
                    color: PdfColor.fromInt(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                columnWidths: const {
                  0: pw.FixedColumnWidth(24), // No
                  1: pw.FlexColumnWidth(3.0), // Perusahaan & Posisi
                  2: pw.FlexColumnWidth(1.8), // Status
                  3: pw.FlexColumnWidth(1.8), // Sistem / Portal
                  4: pw.FlexColumnWidth(1.6), // Tanggal
                  5: pw.FlexColumnWidth(1.8), // Ekspektasi Gaji
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF18181B),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    children: [
                      _buildHeaderCell('#', align: pw.TextAlign.center),
                      _buildHeaderCell('Perusahaan & Posisi'),
                      _buildHeaderCell('Status'),
                      _buildHeaderCell('Sistem & Portal'),
                      _buildHeaderCell('Tgl Melamar'),
                      _buildHeaderCell('Ekspektasi Gaji'),
                    ],
                  ),
                  // Table Rows
                  ...List<pw.TableRow>.generate(widget.applications.length,
                      (i) {
                    final app = widget.applications[i];
                    final isEven = i % 2 == 0;
                    final rowBg = isEven
                        ? const PdfColor.fromInt(0xFFFFFFFF)
                        : const PdfColor.fromInt(0xFFF8FAFC);

                    final salaryStr = app.salaryExpectation != null
                        ? 'Rp ${currencyFormat.format(app.salaryExpectation)}'
                        : '-';

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: rowBg),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          child: pw.Text(
                            '${i + 1}',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColor.fromInt(0xFF64748B)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                app.companyName,
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor.fromInt(0xFF0F172A),
                                ),
                              ),
                              pw.Text(
                                app.positionTitle,
                                style: const pw.TextStyle(
                                  fontSize: 7.5,
                                  color: PdfColor.fromInt(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: _buildStatusPdfPill(app.status),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: pw.Text(
                            '${app.workSystem.label} / ${app.jobPortalCustom ?? app.jobPortal.label}',
                            style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColor.fromInt(0xFF334155)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: pw.Text(
                            dateFormat.format(app.appliedDate),
                            style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColor.fromInt(0xFF334155)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 6),
                          child: pw.Text(
                            salaryStr,
                            style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColor.fromInt(0xFF334155)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      );

      final pdfBytes = await doc.save();

      // Launch PDF print preview / share dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'AppliQ_Laporan_Lamaran.pdf',
      );

      if (mounted) {
        setState(() => _isPdfLoading = false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPdfLoading = false);
        UIHelper.handleError(context, e);
      }
    }
  }

  pw.Widget _buildPdfKpiCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8FAFC),
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(
              color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(
                fontSize: 6.5,
                color: PdfColor.fromInt(0xFF64748B),
                letterSpacing: 0.4,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildStatusPdfPill(ApplicationStatus status) {
    PdfColor bgColor;
    PdfColor textColor;

    switch (status) {
      case ApplicationStatus.accepted:
      case ApplicationStatus.offering:
        bgColor = const PdfColor.fromInt(0xFFD1FAE5);
        textColor = const PdfColor.fromInt(0xFF047857);
        break;
      case ApplicationStatus.interview:
        bgColor = const PdfColor.fromInt(0xFFFEF3C7);
        textColor = const PdfColor.fromInt(0xFFB45309);
        break;
      case ApplicationStatus.rejected:
        bgColor = const PdfColor.fromInt(0xFFFEE2E2);
        textColor = const PdfColor.fromInt(0xFFB91C1C);
        break;
      case ApplicationStatus.applied:
        bgColor = const PdfColor.fromInt(0xFFDBEAFE);
        textColor = const PdfColor.fromInt(0xFF1D4ED8);
        break;
      case ApplicationStatus.noResponse:
      default:
        bgColor = const PdfColor.fromInt(0xFFF1F5F9);
        textColor = const PdfColor.fromInt(0xFF475569);
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        status.label,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.exportSheetTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            AppStrings.exportSheetSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Summary Stats Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    LanguageManager.isEnglish ? 'Total Records' : 'Total Catatan',
                    '${widget.applications.length}',
                    isDark),
                Container(
                    height: 28,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.black12),
                _buildStatItem(
                    LanguageManager.isEnglish ? 'Formats' : 'Format',
                    'PDF & CSV',
                    isDark),
                Container(
                    height: 28,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.black12),
                _buildStatItem(
                    LanguageManager.isEnglish ? 'Status' : 'Status',
                    LanguageManager.isEnglish ? 'Ready' : 'Siap Ekspor',
                    isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Option 1: PDF Export Button with Rotating Spinner (Strict 1 Line Text)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isPdfLoading || _isCsvLoading) ? null : _exportPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Colors.white : const Color(0xFF18181B),
                foregroundColor:
                    isDark ? const Color(0xFF18181B) : Colors.white,
                disabledBackgroundColor:
                    (isDark ? Colors.white : const Color(0xFF18181B))
                        .withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPdfLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color:
                              isDark ? const Color(0xFF18181B) : Colors.white,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 17,
                        color: isDark ? const Color(0xFF18181B) : Colors.white,
                      ),
                    ),
                  Text(
                    _isPdfLoading
                        ? (LanguageManager.isEnglish ? 'Generating PDF...' : 'Menyiapkan PDF...')
                        : (LanguageManager.isEnglish ? 'Save as PDF' : 'Simpan Sebagai PDF'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Option 2: CSV Export Button with Rotating Spinner (Strict 1 Line Text)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: (_isPdfLoading || _isCsvLoading) ? null : _copyCsv,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCsvLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color:
                              isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 17,
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                      ),
                    ),
                  Text(
                    _isCsvLoading
                        ? (LanguageManager.isEnglish ? 'Copying CSV...' : 'Menyalin CSV...')
                        : (LanguageManager.isEnglish ? 'Save as CSV' : 'Simpan Sebagai CSV'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
