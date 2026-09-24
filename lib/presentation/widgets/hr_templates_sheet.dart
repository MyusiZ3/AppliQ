import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../utils/language_manager.dart';
import '../../utils/theme_manager.dart';

class HrTemplatesSheet extends StatefulWidget {
  final String? defaultCompanyName;
  final String? defaultPosition;

  const HrTemplatesSheet({
    super.key,
    this.defaultCompanyName,
    this.defaultPosition,
  });

  static void show(BuildContext context, {String? defaultCompanyName, String? defaultPosition}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HrTemplatesSheet(
        defaultCompanyName: defaultCompanyName,
        defaultPosition: defaultPosition,
      ),
    );
  }

  @override
  State<HrTemplatesSheet> createState() => _HrTemplatesSheetState();
}

class _HrTemplatesSheetState extends State<HrTemplatesSheet> {
  int _selectedCategoryIndex = 0;

  List<Map<String, String>> _getTemplates() {
    final isEn = LanguageManager.isEnglish;
    final company = widget.defaultCompanyName?.isNotEmpty == true
        ? widget.defaultCompanyName!
        : (isEn ? '[Company Name]' : '[Nama Perusahaan]');
    final position = widget.defaultPosition?.isNotEmpty == true
        ? widget.defaultPosition!
        : (isEn ? '[Applied Position]' : '[Posisi yang Dilamar]');

    if (isEn) {
      return [
        {
          'title': 'Job Application Follow-Up',
          'category': 'Follow-up',
          'desc': 'Use this template when you have not received an update > 7 days after applying.',
          'subject': 'Job Application Follow-Up - $position - [Your Name]',
          'body': 'Dear Hiring Team at $company,\n\n'
              'I hope this email finds you well.\n\n'
              'I am writing to respectfully check in on the status of my application for the $position role at $company, which I submitted recently.\n\n'
              'I remain very enthusiastic about the opportunity to contribute to $company and would be pleased to provide any additional information or work samples if needed.\n\n'
              'Thank you very much for your time and consideration.\n\n'
              'Warm regards,\n[Your Name]\n[Phone Number / WhatsApp]\n[LinkedIn Profile]',
        },
        {
          'title': 'Interview Confirmation',
          'category': 'Interview',
          'desc': 'Confirm your attendance after receiving an interview invitation.',
          'subject': 'Interview Confirmation - $position - [Your Name]',
          'body': 'Dear HR / Recruitment Team at $company,\n\n'
              'Thank you very much for the invitation to interview for the $position role at $company.\n\n'
              'I am pleased to confirm my attendance for the scheduled interview session:\n\n'
              '• Date: [Day, Date]\n'
              '• Time: [Time & Timezone]\n'
              '• Platform / Location: [Google Meet / Zoom / Office]\n\n'
              'I look forward to discussing how my experience and skills align with your team\'s goals.\n\n'
              'Sincerely,\n[Your Name]\n[Contact Details]',
        },
        {
          'title': 'Post-Interview Thank You Note',
          'category': 'Interview',
          'desc': 'Send within 24 hours after your interview session finishes.',
          'subject': 'Thank You - Interview for $position - [Your Name]',
          'body': 'Dear [Interviewer Name / HR Team at $company],\n\n'
              'Thank you so much for taking the time to speak with me today regarding the $position role.\n\n'
              'I thoroughly enjoyed learning more about the team\'s vision and the upcoming projects at $company. The conversation further strengthened my excitement about joining your team.\n\n'
              'Please let me know if you need any further materials or references from my end.\n\n'
              'Best regards,\n[Your Name]',
        },
        {
          'title': 'Interview Reschedule Request',
          'category': 'Interview',
          'desc': 'Politely request a schedule change due to unforeseen conflicts.',
          'subject': 'Interview Reschedule Request - $position - [Your Name]',
          'body': 'Dear Recruitment Team at $company,\n\n'
              'Thank you very much for the interview invitation for the $position position.\n\n'
              'Unfortunately, due to an unavoidable conflict ([briefly state urgent reason]), I will not be able to attend at the originally scheduled time. Please accept my sincere apologies.\n\n'
              'Would it be possible to reschedule the session to one of the following time slots?\n'
              '• Option 1: [Day, Date, Time]\n'
              '• Option 2: [Day, Date, Time]\n\n'
              'Thank you very much for your understanding and flexibility.\n\n'
              'Sincerely,\n[Your Name]',
        },
        {
          'title': 'Job Offer Acceptance / Discussion',
          'category': 'Offering',
          'desc': 'Professional response upon receiving a formal employment offer.',
          'subject': 'Job Offer Response - $position - [Your Name]',
          'body': 'Dear HR Team at $company,\n\n'
              'Thank you very much for extending the formal offer for the $position position at $company. I am thrilled and honored to receive this opportunity.\n\n'
              'After reviewing the terms and compensation package, I would love to [formally accept this offer / discuss a few specifics regarding ...] before signing the final agreement.\n\n'
              'Thank you again for your support throughout the recruitment process.\n\n'
              'Warm regards,\n[Your Name]',
        },
      ];
    }

    return [
      {
        'title': 'Follow-Up Status Lamaran',
        'category': 'Follow-up',
        'desc': 'Gunakan template ini jika sudah > 7 hari belum ada kabar setelah melamar.',
        'subject': 'Follow-Up Status Lamaran Pekerjaan - $position - [Nama Anda]',
        'body': 'Yth. Tim Rekrutmen $company,\n\n'
            'Semoga Bapak/Ibu dalam keadaan sehat.\n\n'
            'Saya menulis email ini untuk menanyakan kelanjutan status lamaran saya untuk posisi $position di $company, yang telah saya ajukan beberapa waktu lalu.\n\n'
            'Saya sangat tertarik dengan kesempatan untuk berkontribusi di $company dan siap memberikan informasi tambahan yang dibutuhkan jika diperlukan.\n\n'
            'Terima kasih atas waktu dan perhatian Bapak/Ibu.\n\n'
            'Salam hangat,\n[Nama Anda]\n[Nomor Telepon/WhatsApp]\n[LinkedIn Profile]',
      },
      {
        'title': 'Konfirmasi Jadwal Interview',
        'category': 'Interview',
        'desc': 'Konfirmasi kehadiran setelah menerima undangan wawancara.',
        'subject': 'Konfirmasi Jadwal Wawancara - $position - [Nama Anda]',
        'body': 'Yth. Tim HR / Rekrutmen $company,\n\n'
            'Terima kasih atas undangan wawancara untuk posisi $position di $company.\n\n'
            'Melalui email ini, saya mengonfirmasi kesediaan dan kesiapan saya untuk menghadiri sesi wawancara sesuai jadwal yang telah ditentukan:\n\n'
            '• Hari/Tanggal: [Hari, Tanggal]\n'
            '• Waktu: [Waktu WIB]\n'
            '• Media: [Google Meet / Zoom / On-site]\n\n'
            'Saya sangat menantikan kesempatan untuk berdiskusi lebih lanjut.\n\n'
            'Hormat saya,\n[Nama Anda]\n[Nomor Kontak]',
      },
      {
        'title': 'Thank You Note (Pasca Interview)',
        'category': 'Interview',
        'desc': 'Kirimkan dalam 24 jam setelah sesi interview selesai.',
        'subject': 'Terima Kasih - Sesi Wawancara $position - [Nama Anda]',
        'body': 'Yth. [Nama Pewawancara / Tim HR $company],\n\n'
            'Terima kasih banyak atas waktu dan kesempatan diskusi pada sesi wawancara untuk posisi $position hari ini.\n\n'
            'Setelah mendengar lebih banyak tentang visi tim dan proyek yang sedang dikembangkan di $company, saya semakin antusias untuk dapat bergabung dan berkontribusi secara langsung.\n\n'
            'Jangan ragu untuk menghubungi saya kembali jika ada informasi pendukung lainnya yang dibutuhkan.\n\n'
            'Salam hormat,\n[Nama Anda]',
      },
      {
        'title': 'Permintaan Reschedule Interview',
        'category': 'Interview',
        'desc': 'Gunakan dengan sopan jika ada kendala mendesak.',
        'subject': 'Permohonan Penjadwalan Ulang Wawancara - $position - [Nama Anda]',
        'body': 'Yth. Tim Rekrutmen $company,\n\n'
            'Terima kasih banyak atas kesempatan wawancara yang diberikan untuk posisi $position.\n\n'
            'Dengan penuh rasa hormat, saya memohon maaf karena belum dapat menghadiri sesi pada waktu yang dijadwalkan karena adanya [alasan mendesak yang relevan].\n\n'
            'Apakah memungkinkan apabila sesi dijadwalkan ulang pada:\n'
            '• Opsi 1: [Hari, Tanggal, Jam]\n'
            '• Opsi 2: [Hari, Tanggal, Jam]\n\n'
            'Mohon maaf atas ketidaknyamanan yang ditimbulkan dan terima kasih atas fleksibilitas Bapak/Ibu.\n\n'
            'Hormat saya,\n[Nama Anda]',
      },
      {
        'title': 'Penerimaan / Diskusi Offering Gaji',
        'category': 'Offering',
        'desc': 'Format profesional saat menerima penawaran kerja.',
        'subject': 'Tanggapan Penawaran Kerja - $position - [Nama Anda]',
        'body': 'Yth. Tim HR $company,\n\n'
            'Terima kasih atas tawaran kerja resmi (Offering Letter) yang diberikan untuk posisi $position di $company. Saya sangat mengapresiasi apresiasi dan kepercayaan yang diberikan kepada saya.\n\n'
            'Setelah mempelajari rincian kompensasi dan benefit yang diajukan, saya ingin [mengonfirmasi penerimaan penawaran ini / mendiskusikan penyesuaian pada komponen ...] sebelum menandatangani dokumen final.\n\n'
            'Terima kasih atas bantuan dan kerjasamanya.\n\n'
            'Salam hangat,\n[Nama Anda]',
      },
    ];
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.copiedToast(label)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;
    final templates = _getTemplates();
    final categories = [
      AppStrings.categoryAll,
      AppStrings.categoryFollowUp,
      AppStrings.categoryInterview,
      AppStrings.categoryOffering,
    ];

    final rawCategories = ['All', 'Follow-up', 'Interview', 'Offering'];

    final filtered = _selectedCategoryIndex == 0
        ? templates
        : templates.where((t) => t['category'] == rawCategories[_selectedCategoryIndex] || t['category'] == categories[_selectedCategoryIndex]).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark: isDark, isMonochrome: isMono),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.hrTemplatesSheetTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.hrTemplatesSheetSubtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
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
          ),

          // Category Pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _selectedCategoryIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isMono
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : AppColors.pastelLime)
                          : (isMono
                              ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                              : (isDark ? AppColors.darkSurfaceVariantPastel : AppColors.lightSurfaceVariantPastel)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      categories[idx],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isMono
                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                : AppColors.textOnPastel)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: AppColors.getBorder(isDark: isDark, isMonochrome: isMono),
          ),

          // Templates List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfacePastel)
                        : (isMono ? const Color(0xFFFAFAFA) : AppColors.lightSurfaceVariantPastel),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.getBorder(isDark: isDark, isMonochrome: isMono),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : const Color(0xFFE4E4E7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['category']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subject Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black38 : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Subject: ${item['subject']}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE4E4E7) : const Color(0xFF3F3F46),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Body Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          item['body']!,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copyToClipboard(item['subject']!, AppStrings.copySubjectButton),
                              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 13),
                              label: Text(
                                AppStrings.copySubjectButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _copyToClipboard(item['body']!, AppStrings.copyBodyButton),
                              icon: const Icon(CupertinoIcons.doc_text, size: 13),
                              label: Text(
                                AppStrings.copyBodyButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMono
                                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                                    : AppColors.pastelLavender,
                                foregroundColor: isMono
                                    ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                    : AppColors.textOnPastel,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
