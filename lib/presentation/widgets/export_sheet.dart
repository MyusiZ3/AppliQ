import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/job_application.dart';

class ExportSheet extends StatelessWidget {
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

  String _generateCsv() {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('ID,Perusahaan,Posisi,Tipe Pekerjaan,Portal Lowongan,Status,Tanggal Melamar,Ekspektasi Gaji,Gaji Ditawarkan,Lokasi,Catatan');

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var app in applications) {
      final applied = app.appliedDate != null ? dateFormat.format(app.appliedDate!) : '';
      final expSalary = app.salaryExpectation?.toStringAsFixed(0) ?? '';
      final offSalary = app.salaryOffered?.toStringAsFixed(0) ?? '';
      final notes = (app.notes ?? '').replaceAll('\n', ' ').replaceAll(',', ';');
      final location = (app.location ?? '').replaceAll(',', ';');

      buffer.writeln(
        '"${app.id}","${app.companyName}","${app.positionTitle}","${app.workSystem.label}","${app.jobPortal.label}","${app.status.label}","$applied","$expSalary","$offSalary","$location","$notes"',
      );
    }

    return buffer.toString();
  }

  void _copyCsv(BuildContext context) {
    HapticFeedback.lightImpact();
    final csv = _generateCsv();
    Clipboard.setData(ClipboardData(text: csv));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menyalin data ${applications.length} lamaran dalam format CSV!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
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
                'Ekspor Data Lamaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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

          const SizedBox(height: 6),
          Text(
            'Ekspor seluruh catatan lamaran Anda ke format CSV / Spreadsheet untuk backup atau analisis pribadi.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Summary Stats Box
          Container(
            padding: const EdgeInsets.all(16),
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
                _buildStatItem('Total Catatan', '${applications.length}', isDark),
                Container(height: 30, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                _buildStatItem('Format', 'CSV / Excel', isDark),
                Container(height: 30, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                _buildStatItem('Status', 'Siap Salin', isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _copyCsv(context),
              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 18),
              label: const Text(
                'Salin Format CSV (Siap Paste di Excel / GSheets)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
