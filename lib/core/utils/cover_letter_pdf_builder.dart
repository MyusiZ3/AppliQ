import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_resume.dart';

class CoverLetterPdfBuilder {
  static String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatEnglishDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static Future<Uint8List> buildPdf(
    UserResume resume, {
    required String companyName,
    String? companyAddress,
    String? targetPosition,
    Uint8List? signatureImageBytes,
    DateTime? letterDate,
    List<String>? customAttachments,
    bool isEnglish = false,
  }) async {
    final effectiveAttachments = customAttachments ?? resume.selectedAttachments;
    final doc = pw.Document(
      title: isEnglish ? 'Cover Letter - ${resume.fullName}' : 'Surat Lamaran - ${resume.fullName}',
      author: resume.fullName,
    );

    final effectiveDate = letterDate ?? DateTime.now();
    final dateStr = isEnglish ? _formatEnglishDate(effectiveDate) : _formatIndonesianDate(effectiveDate);
    final cityName = resume.cityCountry.isNotEmpty
        ? resume.cityCountry.split(',').first.trim()
        : (isEnglish ? 'Jakarta' : 'Jakarta');

    final position = (targetPosition != null && targetPosition.isNotEmpty)
        ? targetPosition
        : (resume.targetJobPosition ?? (isEnglish ? 'Target Job Position' : 'Posisi yang Dilamar'));

    final company = companyName.isNotEmpty
        ? companyName
        : (isEnglish ? '[Company Name]' : 'PT [Nama Perusahaan]');
    final address = (companyAddress != null && companyAddress.isNotEmpty)
        ? companyAddress
        : (isEnglish ? 'City, Country' : 'Di Tempat');

    // Find education details
    String lastEdu = resume.lastEducation ?? '';
    String univName = '';
    if (resume.educations.isNotEmpty) {
      final firstEdu = resume.educations.first;
      if (lastEdu.isEmpty) {
        lastEdu = firstEdu.degreeAndMajor;
      }
      univName = firstEdu.institution;
    }
    if (lastEdu.isEmpty) lastEdu = '-';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (pw.Context context) {
          if (isEnglish) {
            return _buildEnglishLayout(
              resume: resume,
              company: company,
              address: address,
              position: position,
              cityName: cityName,
              dateStr: dateStr,
              lastEdu: lastEdu,
              univName: univName,
              attachments: effectiveAttachments,
              signatureImageBytes: signatureImageBytes,
            );
          }

          return _buildIndonesianLayout(
            resume: resume,
            company: company,
            address: address,
            position: position,
            cityName: cityName,
            dateStr: dateStr,
            lastEdu: lastEdu,
            univName: univName,
            attachments: effectiveAttachments,
            signatureImageBytes: signatureImageBytes,
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildIndonesianLayout({
    required UserResume resume,
    required String company,
    required String address,
    required String position,
    required String cityName,
    required String dateStr,
    required String lastEdu,
    required String univName,
    required List<String> attachments,
    required Uint8List? signatureImageBytes,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. Header (Perihal / Lampiran & Lokasi, Tanggal Surat)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeaderRow('Perihal', 'Lamaran Pekerjaan'),
                pw.SizedBox(height: 3),
                _buildHeaderRow(
                  'Lampiran',
                  attachments.isNotEmpty ? '${attachments.length} lembar' : '-',
                ),
              ],
            ),
            pw.Text(
              '$cityName, $dateStr',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 18),

        // 2. Tujuan Surat
        pw.Text(
          'Yth. Pimpinan HRD $company',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          address,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 14),

        // 3. Salam Pembuka
        pw.Text(
          'Dengan hormat,',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Saya yang bertanda tangan di bawah ini:',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 8),

        // 4. Data Diri Singkat (Tabel Format Resmi)
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4),
          child: pw.Column(
            children: [
              _buildBioRow('Nama Lengkap', resume.fullName),
              if (resume.birthPlaceDate != null && resume.birthPlaceDate!.isNotEmpty)
                _buildBioRow('Tempat/Tanggal Lahir', resume.birthPlaceDate!),
              _buildBioRow(
                'Alamat',
                (resume.fullAddress != null && resume.fullAddress!.isNotEmpty)
                    ? resume.fullAddress!
                    : (resume.cityCountry.isNotEmpty ? resume.cityCountry : '-'),
              ),
              _buildBioRow('Nomor Telepon', resume.phoneNumber.isNotEmpty ? resume.phoneNumber : '-'),
              _buildBioRow('Email', resume.email.isNotEmpty ? resume.email : '-'),
              _buildBioRow('Pendidikan Terakhir', lastEdu),
              if (univName.isNotEmpty)
                _buildBioRow('Nama Universitas', univName),
              _buildBioRow('Status', resume.maritalStatus),
              _buildBioRow('Kewarganegaraan', resume.citizenship),
            ],
          ),
        ),
        pw.SizedBox(height: 12),

        // 5. Paragraf Isi
        pw.Text(
          'Bermaksud untuk mengajukan lamaran kerja untuk posisi $position di $company. Informasi lowongan ini saya peroleh melalui pengumuman lowongan kerja resmi, dan saya merasa posisi tersebut sangat sesuai dengan latar belakang pendidikan serta pengalaman saya. Saya memiliki motivasi tinggi, dedikasi kerja yang baik, dan terbiasa bekerja secara mandiri maupun berkolaborasi dalam tim. Saya yakin dapat memberikan kontribusi positif bagi perusahaan dengan kemampuan yang saya miliki. Sebagai bahan pertimbangan, saya juga melampirkan dokumen pelengkap:',
          style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.35),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 8),

        // 6. Daftar Lampiran (Numbered List)
        if (attachments.isNotEmpty) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(
                attachments.length,
                (index) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    '${index + 1}.  ${attachments[index]}',
                    style: const pw.TextStyle(fontSize: 9.5),
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 10),
        ],

        // 7. Paragraf Penutup
        pw.Text(
          'Saya sangat berharap dapat diberi kesempatan untuk wawancara agar saya dapat menjelaskan lebih detail mengenai potensi dan kemampuan saya. Terima kasih atas perhatian Bapak/Ibu.',
          style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.35),
          textAlign: pw.TextAlign.justify,
        ),

        pw.Spacer(),

        // 8. Tanda Tangan (Kanan Bawah)
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Hormat Saya,',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              if (signatureImageBytes != null && signatureImageBytes.isNotEmpty)
                pw.Container(
                  height: 52,
                  width: 120,
                  child: pw.Image(
                    pw.MemoryImage(signatureImageBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.SizedBox(height: 52),
              pw.SizedBox(height: 6),
              pw.Text(
                resume.fullName.isNotEmpty ? resume.fullName : 'Pelamar',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildEnglishLayout({
    required UserResume resume,
    required String company,
    required String address,
    required String position,
    required String cityName,
    required String dateStr,
    required String lastEdu,
    required String univName,
    required List<String> attachments,
    required Uint8List? signatureImageBytes,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // 1. Header (Subject & Date)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeaderRow('Subject', 'Job Application - $position'),
                pw.SizedBox(height: 3),
                _buildHeaderRow(
                  'Enclosure',
                  attachments.isNotEmpty ? '${attachments.length} Document(s)' : '-',
                ),
              ],
            ),
            pw.Text(
              dateStr,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.SizedBox(height: 18),

        // 2. Recipient
        pw.Text(
          'To: Hiring Manager & Recruitment Team',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          company,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          address,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 14),

        // 3. Salutation
        pw.Text(
          'Dear Hiring Manager,',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 8),

        // 4. Body Paragraph 1
        pw.Text(
          'I am writing to formally express my interest in the $position position at $company. With a strong commitment to excellence and relevant skills developed through my academic background and hands-on projects, I am confident in my ability to make a meaningful and positive contribution to your esteemed organization.',
          style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.35),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 10),

        // 5. Applicant Brief Profile
        pw.Text(
          'Applicant Summary:',
          style: pw.TextStyle(fontSize: 9.8, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4),
          child: pw.Column(
            children: [
              _buildBioRow('Full Name', resume.fullName),
              _buildBioRow('Email Address', resume.email.isNotEmpty ? resume.email : '-'),
              _buildBioRow('Phone Number', resume.phoneNumber.isNotEmpty ? resume.phoneNumber : '-'),
              _buildBioRow('Location', resume.cityCountry.isNotEmpty ? resume.cityCountry : '-'),
              _buildBioRow('Highest Education', lastEdu),
              if (univName.isNotEmpty)
                _buildBioRow('Institution / Univ', univName),
            ],
          ),
        ),
        pw.SizedBox(height: 10),

        // 6. Body Paragraph 2
        pw.Text(
          'I am a proactive and adaptive professional with a strong work ethic, effective communication skills, and the capacity to collaborate seamlessly in dynamic team environments. Enclosed are the supporting documents for your consideration:',
          style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.35),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 8),

        // 7. Enclosures
        if (attachments.isNotEmpty) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(
                attachments.length,
                (index) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    '${index + 1}.  ${attachments[index]}',
                    style: const pw.TextStyle(fontSize: 9.5),
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 10),
        ],

        // 8. Closing Paragraph
        pw.Text(
          'Thank you very much for considering my application. I look forward to the opportunity to discuss my qualifications and how I can contribute to $company in an interview.',
          style: const pw.TextStyle(fontSize: 9.8, lineSpacing: 1.35),
          textAlign: pw.TextAlign.justify,
        ),

        pw.Spacer(),

        // 9. Sign-off
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Sincerely,',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              if (signatureImageBytes != null && signatureImageBytes.isNotEmpty)
                pw.Container(
                  height: 52,
                  width: 120,
                  child: pw.Image(
                    pw.MemoryImage(signatureImageBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.SizedBox(height: 52),
              pw.SizedBox(height: 6),
              pw.Text(
                resume.fullName.isNotEmpty ? resume.fullName : 'Applicant',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Text(':  $value', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildBioRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 135,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9.5),
            ),
          ),
          pw.Text(':  ', style: const pw.TextStyle(fontSize: 9.5)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }

  static String generatePlainText(
    UserResume resume, {
    required String companyName,
    String? companyAddress,
    String? targetPosition,
    DateTime? letterDate,
    List<String>? customAttachments,
    bool isEnglish = false,
  }) {
    final effectiveAttachments = customAttachments ?? resume.selectedAttachments;
    final effectiveDate = letterDate ?? DateTime.now();
    final dateStr = isEnglish ? _formatEnglishDate(effectiveDate) : _formatIndonesianDate(effectiveDate);
    final cityName = resume.cityCountry.isNotEmpty
        ? resume.cityCountry.split(',').first.trim()
        : 'Jakarta';

    final position = (targetPosition != null && targetPosition.isNotEmpty)
        ? targetPosition
        : (resume.targetJobPosition ?? (isEnglish ? 'Target Job Position' : 'Posisi yang Dilamar'));

    final company = companyName.isNotEmpty
        ? companyName
        : (isEnglish ? '[Company Name]' : 'PT [Nama Perusahaan]');
    final address = (companyAddress != null && companyAddress.isNotEmpty)
        ? companyAddress
        : (isEnglish ? 'City, Country' : 'Di Tempat');

    String lastEdu = resume.lastEducation ?? '';
    String univName = '';
    if (resume.educations.isNotEmpty) {
      final firstEdu = resume.educations.first;
      if (lastEdu.isEmpty) {
        lastEdu = firstEdu.degreeAndMajor;
      }
      univName = firstEdu.institution;
    }
    if (lastEdu.isEmpty) lastEdu = '-';

    final buffer = StringBuffer();

    if (isEnglish) {
      buffer.writeln('$dateStr\n');
      buffer.writeln('Subject    : Job Application - $position');
      buffer.writeln('Enclosure  : ${effectiveAttachments.isNotEmpty ? "${effectiveAttachments.length} Document(s)" : "-"}\n');
      buffer.writeln('To: Hiring Manager & Recruitment Team');
      buffer.writeln(company);
      buffer.writeln('$address\n');
      buffer.writeln('Dear Hiring Manager,\n');
      buffer.writeln(
          'I am writing to formally express my interest in the $position position at $company. With a strong commitment to excellence and relevant skills developed through my academic background and hands-on projects, I am confident in my ability to make a meaningful and positive contribution to your esteemed organization.\n');
      buffer.writeln('Applicant Summary:');
      buffer.writeln('Full Name         : ${resume.fullName}');
      buffer.writeln('Email Address     : ${resume.email}');
      buffer.writeln('Phone Number      : ${resume.phoneNumber}');
      buffer.writeln('Location          : ${resume.cityCountry}');
      buffer.writeln('Highest Education : $lastEdu');
      if (univName.isNotEmpty) {
        buffer.writeln('Institution       : $univName');
      }
      buffer.writeln('');
      buffer.writeln(
          'I am a proactive and adaptive professional with a strong work ethic, effective communication skills, and the capacity to collaborate seamlessly in dynamic team environments. Enclosed are the supporting documents for your consideration:\n');
      if (effectiveAttachments.isNotEmpty) {
        for (var i = 0; i < effectiveAttachments.length; i++) {
          buffer.writeln('${i + 1}. ${effectiveAttachments[i]}');
        }
        buffer.writeln('');
      }
      buffer.writeln(
          'Thank you very much for considering my application. I look forward to the opportunity to discuss my qualifications and how I can contribute to $company in an interview.\n');
      buffer.writeln('Sincerely,\n\n\n');
      buffer.writeln(resume.fullName.isNotEmpty ? resume.fullName : 'Applicant');
    } else {
      buffer.writeln('$cityName, $dateStr\n');
      buffer.writeln('Perihal  : Lamaran Pekerjaan');
      buffer.writeln(
          'Lampiran : ${effectiveAttachments.isNotEmpty ? "${effectiveAttachments.length} lembar" : "-"}\n');
      buffer.writeln('Yth. Pimpinan HRD $company');
      buffer.writeln('$address\n');
      buffer.writeln('Dengan hormat,');
      buffer.writeln('Saya yang bertanda tangan di bawah ini:\n');
      buffer.writeln('Nama Lengkap        : ${resume.fullName}');
      if (resume.birthPlaceDate != null && resume.birthPlaceDate!.isNotEmpty) {
        buffer.writeln('Tempat/Tanggal Lahir: ${resume.birthPlaceDate}');
      }
      buffer.writeln(
          'Alamat              : ${(resume.fullAddress != null && resume.fullAddress!.isNotEmpty) ? resume.fullAddress : resume.cityCountry}');
      buffer.writeln('Nomor Telepon       : ${resume.phoneNumber}');
      buffer.writeln('Email               : ${resume.email}');
      buffer.writeln('Pendidikan Terakhir : $lastEdu');
      if (univName.isNotEmpty) {
        buffer.writeln('Nama Universitas    : $univName');
      }
      buffer.writeln('Status              : ${resume.maritalStatus}');
      buffer.writeln('Kewarganegaraan     : ${resume.citizenship}\n');

      buffer.writeln(
          'Bermaksud untuk mengajukan lamaran kerja untuk posisi $position di $company. Informasi lowongan ini saya peroleh melalui pengumuman lowongan kerja resmi, dan saya merasa posisi tersebut sangat sesuai dengan latar belakang pendidikan serta pengalaman saya. Saya memiliki motivasi tinggi, dedikasi kerja yang baik, dan terbiasa bekerja secara mandiri maupun berkolaborasi dalam tim. Saya yakin dapat memberikan kontribusi positif bagi perusahaan dengan kemampuan yang saya miliki. Sebagai bahan pertimbangan, saya juga melampirkan dokumen pelengkap:\n');

      if (effectiveAttachments.isNotEmpty) {
        for (var i = 0; i < effectiveAttachments.length; i++) {
          buffer.writeln('${i + 1}. ${effectiveAttachments[i]}');
        }
        buffer.writeln('');
      }

      buffer.writeln(
          'Saya sangat berharap dapat diberi kesempatan untuk wawancara agar saya dapat menjelaskan lebih detail mengenai potensi dan kemampuan saya. Terima kasih atas perhatian Bapak/Ibu.\n');

      buffer.writeln('Hormat Saya,\n\n\n');
      buffer.writeln(resume.fullName.isNotEmpty ? resume.fullName : 'Pelamar');
    }

    return buffer.toString();
  }
}
