import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

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
    final company = widget.defaultCompanyName?.isNotEmpty == true ? widget.defaultCompanyName! : '[Nama Perusahaan]';
    final position = widget.defaultPosition?.isNotEmpty == true ? widget.defaultPosition! : '[Posisi yang Dilamar]';

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
        content: Text('$label berhasil disalin ke clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templates = _getTemplates();
    final categories = ['Semua', 'Follow-up', 'Interview', 'Offering'];

    final filtered = _selectedCategoryIndex == 0
        ? templates
        : templates.where((t) => t['category'] == categories[_selectedCategoryIndex]).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : Colors.white,
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
                      'Template Pesan HR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Format email profesional siap salin & pakai.',
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
                          ? (isDark ? Colors.white : const Color(0xFF18181B))
                          : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      categories[idx],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? const Color(0xFF18181B) : Colors.white)
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
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
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
                              onPressed: () => _copyToClipboard(item['subject']!, 'Subject Email'),
                              icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 13),
                              label: const Text(
                                'Salin Subject',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
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
                              onPressed: () => _copyToClipboard(item['body']!, 'Template Email'),
                              icon: const Icon(CupertinoIcons.doc_text, size: 13),
                              label: const Text(
                                'Salin Body Email',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
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
