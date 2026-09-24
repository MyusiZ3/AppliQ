import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_resume.dart';

class CvAtsPdfBuilder {
  static Future<Uint8List> buildPdf(
    UserResume resume, {
    required bool isEnglish,
  }) async {
    final doc = pw.Document(
      title: isEnglish ? 'CV - ${resume.fullName}' : 'CV ATS - ${resume.fullName}',
      author: resume.fullName,
    );

    // Section Titles based on language
    final summaryTitle = isEnglish ? 'PROFESSIONAL SUMMARY' : 'PROFIL PERSONAL';
    final educationTitle = isEnglish ? 'EDUCATION' : 'RIWAYAT PENDIDIKAN';
    final experienceTitle = isEnglish ? 'WORK & PROJECT EXPERIENCE' : 'PENGALAMAN';
    final certificationTitle = isEnglish ? 'CERTIFICATIONS' : 'SERTIFIKASI';
    final technicalSkillsTitle = isEnglish ? 'TECHNICAL SKILLS' : 'KEMAMPUAN TEKNIS';
    final softSkillsTitle = isEnglish ? 'SOFT SKILLS' : 'KEMAMPUAN PERSONAL';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (pw.Context context) {
          return [
            // 1. Header (Centered Name & Contact)
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    resume.fullName.isNotEmpty ? resume.fullName.toUpperCase() : 'NAMA LENGKAP',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _buildContactLine(resume),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // 2. Summary
            if (resume.summary != null && resume.summary!.trim().isNotEmpty) ...[
              _buildSectionHeader(summaryTitle),
              pw.SizedBox(height: 5),
              pw.Text(
                resume.summary!.trim(),
                style: pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
            ],

            // 3. Education
            if (resume.educations.isNotEmpty) ...[
              _buildSectionHeader(educationTitle),
              pw.SizedBox(height: 6),
              ...resume.educations.map((edu) => _buildEducationItem(edu, isEnglish)),
              pw.SizedBox(height: 8),
            ],

            // 4. Experience
            if (resume.experiences.isNotEmpty) ...[
              _buildSectionHeader(experienceTitle),
              pw.SizedBox(height: 6),
              ...resume.experiences.map((exp) => _buildExperienceItem(exp)),
              pw.SizedBox(height: 8),
            ],

            // 5. Certifications
            if (resume.certifications.isNotEmpty) ...[
              _buildSectionHeader(certificationTitle),
              pw.SizedBox(height: 6),
              ...resume.certifications.map((cert) => _buildCertificationItem(cert)),
              pw.SizedBox(height: 12),
            ],

            // 6. Technical Skills
            if (resume.technicalSkills.isNotEmpty) ...[
              _buildSectionHeader(technicalSkillsTitle),
              pw.SizedBox(height: 5),
              _buildSkillsWrap(resume.technicalSkills),
              pw.SizedBox(height: 12),
            ],

            // 7. Soft Skills (3 Columns)
            if (resume.softSkills.isNotEmpty) ...[
              _buildSectionHeader(softSkillsTitle),
              pw.SizedBox(height: 6),
              _buildSoftSkillsGrid(resume.softSkills),
              pw.SizedBox(height: 10),
            ],
          ];
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildContactLine(UserResume resume) {
    final parts = <String>[];
    if (resume.cityCountry.isNotEmpty) parts.add(resume.cityCountry);
    if (resume.phoneNumber.isNotEmpty) parts.add(resume.phoneNumber);
    if (resume.email.isNotEmpty) parts.add(resume.email);
    if (resume.linkedinUrl != null && resume.linkedinUrl!.isNotEmpty) {
      parts.add(resume.linkedinUrl!.replaceAll('https://', '').replaceAll('http://', ''));
    }
    if (resume.portfolioUrl != null && resume.portfolioUrl!.isNotEmpty) {
      parts.add(resume.portfolioUrl!.replaceAll('https://', '').replaceAll('http://', ''));
    }

    return pw.Text(
      parts.join('  |  '),
      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      textAlign: pw.TextAlign.center,
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          height: 1,
          color: PdfColors.black,
        ),
      ],
    );
  }

  static pw.Widget _buildEducationItem(EducationItem edu, bool isEnglish) {
    final degreeMajorBuffer = StringBuffer();
    if (edu.degreeAndMajor.isNotEmpty) {
      degreeMajorBuffer.write(edu.degreeAndMajor);
    }
    if (edu.cityCountry.isNotEmpty) {
      final loc = edu.cityCountry.trim();
      if (degreeMajorBuffer.isNotEmpty) {
        if (!degreeMajorBuffer.toString().toLowerCase().contains(loc.toLowerCase())) {
          degreeMajorBuffer.write(', $loc');
        }
      } else {
        degreeMajorBuffer.write(loc);
      }
    }
    final degreeMajorStr = degreeMajorBuffer.toString().trim();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Line 1: Institution Name in BOLD
          pw.Text(
            edu.institution,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 1.5),

          // Line 2: Degree/Major (Left) & Period (Right) in ITALIC
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(
                  degreeMajorStr,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              if (edu.period.isNotEmpty)
                pw.Text(
                  edu.period,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
            ],
          ),

          if (edu.gpa != null && edu.gpa!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 1.5),
            pw.Text(
              '${isEnglish ? "GPA" : "IPK"}: ${edu.gpa!.trim()}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
            ),
          ],

          if (edu.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            ..._buildSmartContentLines(edu.bulletPoints),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildExperienceItem(ExperienceItem exp) {
    final companyLocationBuffer = StringBuffer();
    if (exp.companyOrProject.isNotEmpty) {
      companyLocationBuffer.write(exp.companyOrProject);
    }
    if (exp.cityCountry.isNotEmpty) {
      final loc = exp.cityCountry.trim();
      if (companyLocationBuffer.isNotEmpty) {
        if (!companyLocationBuffer.toString().toLowerCase().contains(loc.toLowerCase())) {
          companyLocationBuffer.write(', $loc');
        }
      } else {
        companyLocationBuffer.write(loc);
      }
    }
    final companyLocationStr = companyLocationBuffer.toString().trim();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Line 1: Job Title / Position in BOLD
          pw.Text(
            exp.position,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 1.5),

          // Line 2: Company/Location (Left) & Period (Right) in ITALIC
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(
                child: pw.Text(
                  companyLocationStr,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              if (exp.period.isNotEmpty)
                pw.Text(
                  exp.period,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 3),

          // Line 3+: Bullet points, numbered lists, or descriptions
          if (exp.bulletPoints.isNotEmpty)
            ..._buildSmartContentLines(exp.bulletPoints),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildSmartContentLines(List<String> rawLines) {
    if (rawLines.isEmpty) return [];

    final lines = rawLines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final widgets = <pw.Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isBullet = line.startsWith(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'));
      final isNumberList = line.startsWith(RegExp(r'^(\d+|[a-zA-Z])[\.\)]\s+'));
      final isColonHeader = line.endsWith(':') && line.length < 40;

      if (isBullet) {
        final cleanText = line.replaceFirst(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'), '').trim();
        widgets.add(_buildBulletPoint(cleanText));
      } else if (isNumberList) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 6, bottom: 2.5),
            child: pw.Text(
              line,
              style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.25),
              textAlign: pw.TextAlign.left,
            ),
          ),
        );
      } else if (isColonHeader) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
            child: pw.Text(
              line,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                lineSpacing: 1.2,
              ),
            ),
          ),
        );
      } else {
        // Setiap baris baru yang dibuat dengan enter otomatis dibuatkan dot
        widgets.add(_buildBulletPoint(line));
      }
    }

    return widgets;
  }

  static pw.Widget _buildCertificationItem(CertificationItem cert) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text: cert.title,
                      style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                      children: [
                        if (cert.organization != null && cert.organization!.isNotEmpty)
                          pw.TextSpan(
                            text: '  -  ${cert.organization}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.normal,
                              color: PdfColors.grey800,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (cert.year != null && cert.year!.isNotEmpty)
            pw.Text(
              cert.year!,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildSkillsWrap(List<String> skills) {
    if (skills.isEmpty) return pw.SizedBox();

    pw.Widget buildSkillLine(List<String> rowSkills) {
      return pw.Wrap(
        spacing: 10,
        runSpacing: 4.5,
        children: rowSkills.map((skill) {
          return pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 3,
                height: 3,
                margin: const pw.EdgeInsets.only(right: 4.5),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.black,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.Text(
                skill.trim(),
                style: const pw.TextStyle(fontSize: 9.5),
              ),
            ],
          );
        }).toList(),
      );
    }

    if (skills.length <= 1) {
      return buildSkillLine(skills);
    }

    // Urutan dari atas ke bawah, lalu mulai lagi dari atas ke bawah (2 row):
    // Baris 1 (Atas): Index 0, 2, 4, 6...
    // Baris 2 (Bawah): Index 1, 3, 5, 7...
    final row1Skills = <String>[];
    final row2Skills = <String>[];

    for (var i = 0; i < skills.length; i++) {
      if (i % 2 == 0) {
        row1Skills.add(skills[i]);
      } else {
        row2Skills.add(skills[i]);
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        buildSkillLine(row1Skills),
        pw.SizedBox(height: 4.5),
        buildSkillLine(row2Skills),
      ],
    );
  }

  static pw.Widget _buildSoftSkillsGrid(List<String> skills) {
    const colCount = 3;
    final rowCount = (skills.length / colCount).ceil();

    return pw.Column(
      children: List.generate(rowCount, (rowIndex) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: List.generate(colCount, (colIndex) {
              final index = rowIndex * colCount + colIndex;
              if (index >= skills.length) {
                return pw.Expanded(child: pw.SizedBox());
              }
              final skill = skills[index];
              return pw.Expanded(
                child: _buildBulletPoint(skill, fontSize: 9),
              );
            }),
          ),
        );
      }),
    );
  }

  static pw.Widget _buildBulletPoint(String text, {double fontSize = 9.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3.5, right: 6),
            child: pw.Container(
              width: 3,
              height: 3,
              decoration: const pw.BoxDecoration(
                color: PdfColors.black,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(fontSize: fontSize, lineSpacing: 1.25),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  static String generatePlainText(UserResume resume, {required bool isEnglish}) {
    final sb = StringBuffer();
    sb.writeln(resume.fullName.toUpperCase());
    final contactParts = [
      if (resume.phoneNumber.isNotEmpty) resume.phoneNumber,
      if (resume.email.isNotEmpty) resume.email,
      if (resume.cityCountry.isNotEmpty) resume.cityCountry,
      if (resume.linkedinUrl != null && resume.linkedinUrl!.isNotEmpty) resume.linkedinUrl!,
      if (resume.portfolioUrl != null && resume.portfolioUrl!.isNotEmpty) resume.portfolioUrl!,
    ];
    if (contactParts.isNotEmpty) sb.writeln(contactParts.join(' | '));
    sb.writeln();

    if (resume.summary != null && resume.summary!.trim().isNotEmpty) {
      sb.writeln(isEnglish ? 'PROFESSIONAL SUMMARY' : 'RINGKASAN PROFESIONAL');
      sb.writeln(resume.summary!.trim());
      sb.writeln();
    }

    if (resume.experiences.isNotEmpty) {
      sb.writeln(isEnglish ? 'WORK EXPERIENCE' : 'PENGALAMAN KERJA');
      for (var exp in resume.experiences) {
        sb.writeln(exp.position);
        final loc = exp.cityCountry.isNotEmpty ? ', ${exp.cityCountry}' : '';
        sb.writeln('${exp.companyOrProject}$loc\t${exp.period}');
        final lines = exp.bulletPoints.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        for (var b in lines) {
          final isBullet = b.startsWith(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'));
          final isNumberList = b.startsWith(RegExp(r'^(\d+|[a-zA-Z])[\.\)]\s+'));
          if (isBullet) {
            final clean = b.replaceFirst(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'), '').trim();
            sb.writeln('• $clean');
          } else if (isNumberList) {
            sb.writeln('  $b');
          } else {
            sb.writeln('• $b');
          }
        }
        sb.writeln();
      }
    }

    if (resume.educations.isNotEmpty) {
      sb.writeln(isEnglish ? 'EDUCATION' : 'PENDIDIKAN');
      for (var edu in resume.educations) {
        sb.writeln(edu.institution);
        final loc = edu.cityCountry.isNotEmpty ? ', ${edu.cityCountry}' : '';
        sb.writeln('${edu.degreeAndMajor}$loc\t${edu.period}');
        if (edu.gpa != null && edu.gpa!.trim().isNotEmpty) {
          sb.writeln('${isEnglish ? "GPA" : "IPK"}: ${edu.gpa!.trim()}');
        }
        for (var b in edu.bulletPoints) {
          final isBullet = b.startsWith(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'));
          final isNumberList = b.startsWith(RegExp(r'^(\d+|[a-zA-Z])[\.\)]\s+'));
          if (isBullet) {
            final clean = b.replaceFirst(RegExp(r'^[•\-\*\u2022\u2023\u25E6\u2043\u2219]\s*'), '').trim();
            sb.writeln('• $clean');
          } else if (isNumberList) {
            sb.writeln('  $b');
          } else {
            sb.writeln('• $b');
          }
        }
        sb.writeln();
      }
    }

    if (resume.technicalSkills.isNotEmpty || resume.softSkills.isNotEmpty) {
      sb.writeln(isEnglish ? 'SKILLS' : 'KEAHLIAN');
      if (resume.technicalSkills.isNotEmpty) {
        sb.writeln('${isEnglish ? "Technical Skills: " : "Keahlian Teknis: "}${resume.technicalSkills.join(", ")}');
      }
      if (resume.softSkills.isNotEmpty) {
        sb.writeln('${isEnglish ? "Soft Skills: " : "Soft Skills: "}${resume.softSkills.join(", ")}');
      }
      sb.writeln();
    }

    return sb.toString().trim();
  }
}
