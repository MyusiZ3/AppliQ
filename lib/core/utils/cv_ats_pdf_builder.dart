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
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: edu.institution,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    children: [
                      if (edu.degreeAndMajor.isNotEmpty)
                        pw.TextSpan(
                          text: '  -  ${edu.degreeAndMajor}',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.normal,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (edu.period.isNotEmpty)
                pw.Text(
                  edu.period,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              '${isEnglish ? "GPA" : "IPK"}: ${edu.gpa}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
            ),
          ],
          if (edu.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            ...edu.bulletPoints.map((point) => _buildBulletPoint(point)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildExperienceItem(ExperienceItem exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: exp.position,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    children: [
                      if (exp.companyOrProject.isNotEmpty)
                        pw.TextSpan(
                          text: '  |  ${exp.companyOrProject}',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                      if (exp.cityCountry.isNotEmpty)
                        pw.TextSpan(
                          text: ' (${exp.cityCountry})',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (exp.period.isNotEmpty)
                pw.Text(
                  exp.period,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (exp.bulletPoints.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            ...exp.bulletPoints.map((point) => _buildBulletPoint(point)),
          ],
        ],
      ),
    );
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
    return pw.Text(
      skills.join('  •  '),
      style: pw.TextStyle(fontSize: 9.5, lineSpacing: 1.3),
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
              textAlign: pw.TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
