import '../constants/app_enums.dart';

class ParsedJobDescription {
  final String? companyName;
  final String? positionTitle;
  final String? location;
  final WorkSystem? workSystem;
  final EmploymentType? employmentType;
  final JobPortal? jobPortal;
  final String? jobPortalCustom;
  final String? jobUrl;
  final double? salaryExpectation;
  final String? notes;

  const ParsedJobDescription({
    this.companyName,
    this.positionTitle,
    this.location,
    this.workSystem,
    this.employmentType,
    this.jobPortal,
    this.jobPortalCustom,
    this.jobUrl,
    this.salaryExpectation,
    this.notes,
  });

  int get detectedFieldCount {
    int count = 0;
    if (companyName != null && companyName!.isNotEmpty) count++;
    if (positionTitle != null && positionTitle!.isNotEmpty) count++;
    if (location != null && location!.isNotEmpty) count++;
    if (workSystem != null) count++;
    if (employmentType != null) count++;
    if (jobPortal != null) count++;
    if (jobUrl != null && jobUrl!.isNotEmpty) count++;
    if (salaryExpectation != null) count++;
    if (notes != null && notes!.isNotEmpty) count++;
    return count;
  }
}

class JobDescriptionParser {
  /// Known cities & regions for location extraction
  static const List<String> _knownLocations = [
    'Jakarta Selatan', 'Jakarta Pusat', 'Jakarta Barat', 'Jakarta Timur', 'Jakarta Utara',
    'DKI Jakarta', 'Jakarta', 'Tangerang Selatan', 'Tangerang', 'Bekasi', 'Depok', 'Bogor',
    'Bandung', 'Surabaya', 'Yogyakarta', 'Jogja', 'Semarang', 'Malang', 'Solo', 'Surakarta',
    'Denpasar', 'Bali', 'Medan', 'Palembang', 'Makassar', 'Batam', 'Pekanbaru', 'Balikpapan',
    'Samarinda', 'Banjarmasin', 'Pontianak', 'Manado', 'Lampung', 'Cikarang', 'Karawang',
    'Singapore', 'Kuala Lumpur', 'Tokyo', 'Sydney', 'London', 'Remote',
  ];

  /// Common job position titles
  static const List<String> _commonPositions = [
    'Software Engineer', 'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
    'Mobile Developer', 'Flutter Developer', 'React Native Developer', 'Android Developer', 'iOS Developer',
    'Web Developer', 'DevOps Engineer', 'Cloud Engineer', 'Site Reliability Engineer (SRE)',
    'QA Engineer', 'Quality Assurance', 'Software Tester', 'Automation Engineer',
    'UI/UX Designer', 'Product Designer', 'UX Researcher', 'Visual Designer', 'Graphic Designer',
    'Product Manager', 'Project Manager', 'Scrum Master', 'Product Owner',
    'Data Scientist', 'Data Analyst', 'Data Engineer', 'Machine Learning Engineer', 'AI Engineer',
    'Cyber Security', 'Security Engineer', 'System Administrator', 'Network Engineer',
    'Digital Marketing', 'SEO Specialist', 'Content Creator', 'Social Media Specialist', 'Copywriter',
    'Human Resources', 'HR Specialist', 'Talent Acquisition', 'Recruiter', 'HR Generalist',
    'Account Executive', 'Business Development', 'Sales Executive', 'Sales Specialist',
    'Customer Support', 'Customer Service', 'Operations Specialist', 'Finance & Accounting',
  ];

  /// Parses raw job post text into a structured [ParsedJobDescription].
  static ParsedJobDescription parse(
    String rawText, {
    Iterable<String>? extraCompanies,
    Iterable<String>? extraPositions,
    Iterable<String>? extraLocations,
  }) {
    if (rawText.trim().isEmpty) {
      return const ParsedJobDescription();
    }

    final text = rawText.trim();
    final lines = text.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();

    // 1. Extract URL & Job Portal
    final jobUrl = _extractUrl(text);
    final jobPortal = _detectJobPortal(text, jobUrl);

    // 2. Extract Work System
    final workSystem = _detectWorkSystem(text);

    // 3. Extract Employment Type
    final employmentType = _detectEmploymentType(text);

    // 4. Extract Salary
    final salary = _extractSalary(text);

    // 5. Extract Company Name
    final companyName = _extractCompany(text, lines, extraCompanies);

    // 6. Extract Position Title
    final positionTitle = _extractPosition(text, lines, extraPositions);

    // 7. Extract Location
    final location = _extractLocation(text, lines, extraLocations);

    // 8. Extract Requirements / Notes
    final notes = _extractNotes(lines);

    return ParsedJobDescription(
      companyName: companyName,
      positionTitle: positionTitle,
      location: location,
      workSystem: workSystem,
      employmentType: employmentType,
      jobPortal: jobPortal,
      jobUrl: jobUrl,
      salaryExpectation: salary,
      notes: notes,
    );
  }

  static String? _extractUrl(String text) {
    final urlRegex = RegExp(r'https?://[^\s)\]>"<>]+', caseSensitive: false);
    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  static JobPortal? _detectJobPortal(String text, String? url) {
    final lower = '${text.toLowerCase()} ${url?.toLowerCase() ?? ''}';

    if (lower.contains('linkedin.com') || lower.contains('linkedin')) {
      return JobPortal.linkedIn;
    }
    if (lower.contains('jobstreet.co') || lower.contains('jobstreet')) {
      return JobPortal.jobStreet;
    }
    if (lower.contains('glints.com') || lower.contains('glints')) {
      return JobPortal.glints;
    }
    if (lower.contains('kalibrr.com') || lower.contains('kalibrr')) {
      return JobPortal.kalibrr;
    }
    if (lower.contains('dealls.com') || lower.contains('dealls')) {
      return JobPortal.dealls;
    }
    if (lower.contains('techinasia.com') || lower.contains('tech in asia')) {
      return JobPortal.techInAsia;
    }
    if (lower.contains('kitalulus.com') || lower.contains('kitalulus')) {
      return JobPortal.kitaLulus;
    }
    if (lower.contains('instagram.com') || lower.contains('instagram')) {
      return JobPortal.instagram;
    }
    if (lower.contains('job fair') || lower.contains('jobfair') || lower.contains('campus hiring')) {
      return JobPortal.jobFair;
    }
    if (lower.contains('kirim cv ke') || lower.contains('send your cv to') || lower.contains('email:')) {
      return JobPortal.directEmail;
    }
    return null;
  }

  static WorkSystem? _detectWorkSystem(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('remote global') || lower.contains('remote worldwide') || lower.contains('overseas remote')) {
      return WorkSystem.remoteOverseas;
    }
    if (lower.contains('wfh') || lower.contains('work from home') || lower.contains('100% remote') || lower.contains('remote')) {
      return WorkSystem.wfh;
    }
    if (lower.contains('hybrid') || lower.contains('flexible office')) {
      return WorkSystem.hybrid;
    }
    if (lower.contains('fleksibel') || lower.contains('flexible')) {
      return WorkSystem.flexible;
    }
    if (lower.contains('wfo') || lower.contains('work from office') || lower.contains('on-site') || lower.contains('onsite')) {
      return WorkSystem.onSite;
    }
    return null;
  }

  static EmploymentType? _detectEmploymentType(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('internship') || lower.contains('intern') || lower.contains('magang') || lower.contains('praktik kerja')) {
      return EmploymentType.internship;
    }
    if (lower.contains('contract') || lower.contains('kontrak') || lower.contains('pkwt') || lower.contains('temporary')) {
      return EmploymentType.contract;
    }
    if (lower.contains('freelance') || lower.contains('freelancer') || lower.contains('project-based') || lower.contains('lepas')) {
      return EmploymentType.freelance;
    }
    if (lower.contains('part-time') || lower.contains('part time') || lower.contains('paruh waktu')) {
      return EmploymentType.partTime;
    }
    if (lower.contains('full-time') || lower.contains('full time') || lower.contains('tetap') || lower.contains('pkwtt') || lower.contains('permanent')) {
      return EmploymentType.fullTime;
    }
    return null;
  }

  static double? _extractSalary(String text) {
    // 1. Match range like "Rp 8.000.000 - 15.000.000" or "IDR 10 - 15 jt"
    final rangeRegex = RegExp(
      r'(?:rp|idr|gaji|salary)\.?\s*([0-9\.,]+)\s*(?:jt|juta|million|mio)?\s*(?:-|–|sampai|to|s/d)\s*(?:rp|idr)?\.?\s*([0-9\.,]+)\s*(jt|juta|million|mio)?',
      caseSensitive: false,
    );
    final rangeMatch = rangeRegex.firstMatch(text);
    if (rangeMatch != null) {
      final rawNum = rangeMatch.group(1);
      final suffix = rangeMatch.group(3) ?? rangeMatch.group(0);
      return _parseNumberToRupiah(rawNum, suffix);
    }

    // 2. Match single salary like "Rp 12.000.000" or "15 jt"
    final singleRegex = RegExp(
      r'(?:rp|idr|gaji|salary)\.?\s*([0-9\.,]+)\s*(jt|juta|million|mio)?',
      caseSensitive: false,
    );
    final singleMatch = singleRegex.firstMatch(text);
    if (singleMatch != null) {
      final rawNum = singleMatch.group(1);
      final suffix = singleMatch.group(2);
      return _parseNumberToRupiah(rawNum, suffix);
    }

    return null;
  }

  static double? _parseNumberToRupiah(String? rawNum, String? suffix) {
    if (rawNum == null) return null;
    final clean = rawNum.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return null;

    double val = double.tryParse(clean) ?? 0;
    if (val <= 0) return null;

    final sLower = suffix?.toLowerCase() ?? '';
    if (sLower.contains('jt') || sLower.contains('juta') || sLower.contains('million') || sLower.contains('mio')) {
      if (val < 1000) {
        val = val * 1000000;
      }
    } else if (val < 100) {
      // e.g. "Gaji 12 - 15" -> likely 12jt
      val = val * 1000000;
    }
    return val;
  }

  static String? _extractCompany(
    String text,
    List<String> lines,
    Iterable<String>? extraCompanies,
  ) {
    // 1. Direct label pattern: "Company: PT ABC" or "Perusahaan : ABC"
    final labelRegex = RegExp(
      r'^(?:company|perusahaan|employer|kantor|at)\s*[:\-]\s*(.+)$',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = labelRegex.firstMatch(line);
      if (match != null && match.group(1) != null) {
        final val = match.group(1)!.trim();
        if (val.isNotEmpty && val.length < 60) return _cleanEntity(val);
      }
    }

    // 2. Check each line for "PT [Name]" or "CV [Name]"
    for (final line in lines) {
      final trimmed = line.trim();
      // If line is dedicated to the company name e.g. "PT Kopi Nusantara"
      if (RegExp(r'^(?:PT|CV)\.?\s+[A-Za-z0-9&.\s]{2,50}$', caseSensitive: false).hasMatch(trimmed)) {
        return _cleanEntity(trimmed);
      }

      // If line starts with PT followed by actions e.g. "PT Teknologi Maju Bangsa sedang membuka..."
      final ptLineMatch = RegExp(
        r'^(?:PT|CV)\.?\s+[A-Za-z0-9&.\s]{2,40}?(?=\s+(?:is|lagi|sedang|membuka|looking|hiring|open|we|berlokasi|\:|\-|\.|\,|$))',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (ptLineMatch != null) {
        return _cleanEntity(ptLineMatch.group(0)!);
      }
    }

    // 3. Check anywhere in text for "PT / CV [Name]"
    final ptRegex = RegExp(
      r'\b((?:PT|CV)\.?\s+[A-Za-z0-9&.\s]{3,40}?)(?=\s+(?:is|lagi|sedang|membuka|looking|hiring|open|we|berlokasi|\n|\.|\,|$))',
      caseSensitive: false,
    );
    final ptMatch = ptRegex.firstMatch(text);
    if (ptMatch != null) {
      final pt = ptMatch.group(1)!.trim();
      if (pt.length > 3 && pt.length < 50) return _cleanEntity(pt);
    }

    // 4. Match against known extra companies
    if (extraCompanies != null) {
      for (final comp in extraCompanies) {
        if (comp.trim().length >= 3 && text.toLowerCase().contains(comp.toLowerCase().trim())) {
          return comp.trim();
        }
      }
    }

    return null;
  }

  static String? _extractPosition(
    String text,
    List<String> lines,
    Iterable<String>? extraPositions,
  ) {
    // 1. Direct label pattern: "Position: Flutter Developer" or "Posisi : Software Engineer"
    final labelRegex = RegExp(
      r'^(?:position|posisi|role|job title|jabatan|lowongan|hiring for|we are hiring)\s*[:\-]\s*(.+)$',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = labelRegex.firstMatch(line);
      if (match != null && match.group(1) != null) {
        final val = match.group(1)!.trim();
        if (val.isNotEmpty && val.length < 60) return _cleanEntity(val);
      }
    }

    // 2. Pattern: "is hiring [Position]" or "we are looking for [Position]"
    final hiringRegex = RegExp(
      r'(?:hiring|looking for|mencari)\s+(?:a|an)?\s*([A-Za-z0-9\s/&+\-\(\)]+?)(?=\s+(?:in|at|to|for|with|\n|\.|\,|$))',
      caseSensitive: false,
    );
    final hiringMatch = hiringRegex.firstMatch(text);
    if (hiringMatch != null) {
      final pos = hiringMatch.group(1)!.trim();
      if (pos.length >= 3 && pos.length < 50) {
        return _cleanEntity(pos);
      }
    }

    // 3. Match against known common positions dictionary
    final allKnown = [
      ...?extraPositions,
      ..._commonPositions,
    ];
    for (final pos in allKnown) {
      if (pos.trim().length >= 4) {
        final pattern = RegExp('\\b${RegExp.escape(pos.trim())}\\b', caseSensitive: false);
        if (pattern.hasMatch(text)) {
          return pos.trim();
        }
      }
    }

    return null;
  }

  static String? _extractLocation(
    String text,
    List<String> lines,
    Iterable<String>? extraLocations,
  ) {
    // 1. Direct label pattern: "Location: Jakarta" or "Penempatan : Surabaya"
    final labelRegex = RegExp(
      r'^(?:location|lokasi|penempatan|placement|based in|kantor)\s*[:\-]\s*(.+)$',
      caseSensitive: false,
    );
    for (final line in lines) {
      final match = labelRegex.firstMatch(line);
      if (match != null && match.group(1) != null) {
        final val = match.group(1)!.trim();
        if (val.isNotEmpty && val.length < 50) return _cleanEntity(val);
      }
    }

    // 2. Match against known locations list
    final allLocations = [
      ...?extraLocations,
      ..._knownLocations,
    ];
    for (final loc in allLocations) {
      if (loc.trim().length >= 3) {
        final pattern = RegExp('\\b${RegExp.escape(loc.trim())}\\b', caseSensitive: false);
        if (pattern.hasMatch(text)) {
          return loc.trim();
        }
      }
    }

    return null;
  }

  static String? _extractNotes(List<String> lines) {
    final noteLines = <String>[];
    bool capturing = false;
    int count = 0;

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('requirement') ||
          lower.startsWith('kualifikasi') ||
          lower.startsWith('responsibilit') ||
          lower.startsWith('tanggung jawab') ||
          lower.startsWith('kriteria') ||
          lower.startsWith('syarat') ||
          lower.startsWith('job description') ||
          lower.startsWith('deskripsi pekerjaan')) {
        capturing = true;
        noteLines.add(line);
        continue;
      }

      if (capturing) {
        if (line.isNotEmpty && (line.startsWith('-') || line.startsWith('•') || line.startsWith('*') || RegExp(r'^\d+\.').hasMatch(line))) {
          noteLines.add(line);
          count++;
          if (count >= 8) break; // Limit notes preview
        } else if (line.isEmpty && count > 0) {
          // Empty line after list -> stop capturing
          break;
        }
      }
    }

    if (noteLines.isEmpty) return null;
    return noteLines.join('\n');
  }

  static String _cleanEntity(String val) {
    return val
        .replaceAll(RegExp(r'^[:\-\s]+'), '')
        .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
        .trim();
  }
}
