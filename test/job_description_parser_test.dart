import 'package:flutter_test/flutter_test.dart';
import 'package:appliq/core/constants/app_enums.dart';
import 'package:appliq/core/utils/job_description_parser.dart';

void main() {
  group('JobDescriptionParser Unit Tests', () {
    test('Parses Indonesian vacancy format accurately', () {
      const sampleText = '''
LOWONGAN KERJA TERBARU 2026
PT Teknologi Maju Bangsa sedang membuka lowongan:
Posisi: Mobile Developer (Flutter)
Penempatan: Jakarta Selatan
Sistem Kerja: Hybrid
Tipe: Full Time
Gaji: Rp 12.000.000 - Rp 18.000.000
Kualifikasi:
- Pengalaman minimal 2 tahun dengan Flutter & Dart
- Memahami State Management (Bloc / Provider)
- Terbiasa integrasi REST API & Supabase

Kirim CV ke email: recruitment@teknologimaju.co.id
''';

      final parsed = JobDescriptionParser.parse(sampleText);

      expect(parsed.companyName, contains('PT Teknologi Maju Bangsa'));
      expect(parsed.positionTitle, contains('Mobile Developer'));
      expect(parsed.location, contains('Jakarta Selatan'));
      expect(parsed.workSystem, equals(WorkSystem.hybrid));
      expect(parsed.employmentType, equals(EmploymentType.fullTime));
      expect(parsed.jobPortal, equals(JobPortal.directEmail));
      expect(parsed.salaryExpectation, equals(12000000.0));
      expect(parsed.notes, isNotNull);
      expect(parsed.notes, contains('Flutter & Dart'));
    });

    test('Parses English LinkedIn format with URL accurately', () {
      const sampleText = '''
We are hiring!
Role: Senior Frontend Developer
Company: Traveloka
Location: Tangerang
Work style: Remote
Salary: IDR 20.000.000 - 30.000.000
Apply directly on LinkedIn: https://www.linkedin.com/jobs/view/123456789/

Requirements:
• 4+ years of React / Next.js
• Excellent English communication
''';

      final parsed = JobDescriptionParser.parse(sampleText);

      expect(parsed.positionTitle, contains('Frontend Developer'));
      expect(parsed.companyName, equals('Traveloka'));
      expect(parsed.location, contains('Tangerang'));
      expect(parsed.workSystem, equals(WorkSystem.wfh));
      expect(parsed.jobPortal, equals(JobPortal.linkedIn));
      expect(parsed.jobUrl, equals('https://www.linkedin.com/jobs/view/123456789/'));
      expect(parsed.salaryExpectation, equals(20000000.0));
    });

    test('Parses informal format with jt suffix', () {
      const sampleText = '''
Dibutuhkan segera:
UI/UX Designer
PT Kopi Nusantara
Gaji 8 - 10 jt
Lokasi: Bandung (WFO)
''';

      final parsed = JobDescriptionParser.parse(sampleText);

      expect(parsed.positionTitle, contains('UI/UX Designer'));
      expect(parsed.companyName, contains('PT Kopi Nusantara'));
      expect(parsed.salaryExpectation, equals(8000000.0));
      expect(parsed.location, contains('Bandung'));
      expect(parsed.workSystem, equals(WorkSystem.onSite));
    });
  });
}
