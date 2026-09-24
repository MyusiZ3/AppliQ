import 'dart:convert';

class EducationItem {
  final String id;
  final String institution;
  final String degreeAndMajor;
  final String cityCountry;
  final String period; // e.g. "2022 - Sekarang"
  final String? gpa; // e.g. "3.79"
  final List<String> bulletPoints;

  EducationItem({
    required this.id,
    required this.institution,
    required this.degreeAndMajor,
    required this.cityCountry,
    required this.period,
    this.gpa,
    List<String>? bulletPoints,
  }) : bulletPoints = bulletPoints ?? [];

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      institution: json['institution'] as String? ?? '',
      degreeAndMajor: json['degree_and_major'] as String? ?? '',
      cityCountry: json['city_country'] as String? ?? '',
      period: json['period'] as String? ?? '',
      gpa: json['gpa'] as String?,
      bulletPoints: (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree_and_major': degreeAndMajor,
      'city_country': cityCountry,
      'period': period,
      'gpa': gpa,
      'bullet_points': bulletPoints,
    };
  }

  EducationItem copyWith({
    String? id,
    String? institution,
    String? degreeAndMajor,
    String? cityCountry,
    String? period,
    String? gpa,
    List<String>? bulletPoints,
  }) {
    return EducationItem(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degreeAndMajor: degreeAndMajor ?? this.degreeAndMajor,
      cityCountry: cityCountry ?? this.cityCountry,
      period: period ?? this.period,
      gpa: gpa ?? this.gpa,
      bulletPoints: bulletPoints ?? List.from(this.bulletPoints),
    );
  }
}

class ExperienceItem {
  final String id;
  final String position;
  final String companyOrProject;
  final String cityCountry;
  final String period; // e.g. "Sep 2023 - Jul 2025" or custom
  final List<String> bulletPoints;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrentlyWorking;
  final String? employmentType; // Full-time, Contract, Internship, Freelance, Part-time
  final double? monthlySalary;
  final String? notes;

  ExperienceItem({
    required this.id,
    required this.position,
    required this.companyOrProject,
    required this.cityCountry,
    required this.period,
    List<String>? bulletPoints,
    this.startDate,
    this.endDate,
    this.isCurrentlyWorking = false,
    this.employmentType,
    this.monthlySalary,
    this.notes,
  }) : bulletPoints = bulletPoints ?? [];

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final start = parseDate(json['start_date']);
    final end = parseDate(json['end_date']);
    final isCurrent = json['is_currently_working'] as bool? ?? (json['period']?.toString().toLowerCase().contains('sekarang') == true || json['period']?.toString().toLowerCase().contains('present') == true);

    return ExperienceItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      position: json['position'] as String? ?? '',
      companyOrProject: json['company_or_project'] as String? ?? '',
      cityCountry: json['city_country'] as String? ?? '',
      period: json['period'] as String? ?? '',
      bulletPoints: (json['bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startDate: start,
      endDate: end,
      isCurrentlyWorking: isCurrent,
      employmentType: json['employment_type'] as String?,
      monthlySalary: (json['monthly_salary'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'company_or_project': companyOrProject,
      'city_country': cityCountry,
      'period': period,
      'bullet_points': bulletPoints,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'is_currently_working': isCurrentlyWorking,
      if (employmentType != null) 'employment_type': employmentType,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (notes != null) 'notes': notes,
    };
  }

  ExperienceItem copyWith({
    String? id,
    String? position,
    String? companyOrProject,
    String? cityCountry,
    String? period,
    List<String>? bulletPoints,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentlyWorking,
    String? employmentType,
    double? monthlySalary,
    String? notes,
  }) {
    return ExperienceItem(
      id: id ?? this.id,
      position: position ?? this.position,
      companyOrProject: companyOrProject ?? this.companyOrProject,
      cityCountry: cityCountry ?? this.cityCountry,
      period: period ?? this.period,
      bulletPoints: bulletPoints ?? List.from(this.bulletPoints),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentlyWorking: isCurrentlyWorking ?? this.isCurrentlyWorking,
      employmentType: employmentType ?? this.employmentType,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      notes: notes ?? this.notes,
    );
  }
}

class CertificationItem {
  final String id;
  final String title;
  final String? organization;
  final String? year;

  CertificationItem({
    required this.id,
    required this.title,
    this.organization,
    this.year,
  });

  factory CertificationItem.fromJson(Map<String, dynamic> json) {
    return CertificationItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String?,
      year: json['year'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'year': year,
    };
  }

  CertificationItem copyWith({
    String? id,
    String? title,
    String? organization,
    String? year,
  }) {
    return CertificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      year: year ?? this.year,
    );
  }
}

class UserResume {
  final String id;
  final String userId;

  // Header & Contact Information
  final String fullName;
  final String cityCountry;
  final String phoneNumber;
  final String email;
  final String? linkedinUrl;
  final String? portfolioUrl;

  // Summary
  final String? summary;

  // Structured Lists
  final List<EducationItem> educations;
  final List<ExperienceItem> experiences;
  final List<CertificationItem> certifications;
  final List<String> technicalSkills;
  final List<String> softSkills;

  // Cover Letter Specific Data
  final String? birthPlaceDate; // e.g. "Bandung, 12 Januari 2002"
  final String? fullAddress;
  final String maritalStatus; // "Belum Menikah" / "Menikah"
  final String citizenship; // "Indonesia"
  final String? lastEducation; // e.g. "D4 Teknologi Rekayasa Multimedia"
  final String? targetJobPosition;
  final List<String> selectedAttachments;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserResume({
    required this.id,
    required this.userId,
    required this.fullName,
    this.cityCountry = '',
    this.phoneNumber = '',
    this.email = '',
    this.linkedinUrl,
    this.portfolioUrl,
    this.summary,
    List<EducationItem>? educations,
    List<ExperienceItem>? experiences,
    List<CertificationItem>? certifications,
    List<String>? technicalSkills,
    List<String>? softSkills,
    this.birthPlaceDate,
    this.fullAddress,
    this.maritalStatus = 'Belum Menikah',
    this.citizenship = 'Indonesia',
    this.lastEducation,
    this.targetJobPosition,
    List<String>? selectedAttachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : educations = educations ?? [],
        experiences = experiences ?? [],
        certifications = certifications ?? [],
        technicalSkills = technicalSkills ?? [],
        softSkills = softSkills ?? [],
        selectedAttachments = selectedAttachments ??
            [
              'Curriculum Vitae (CV)',
              'Fotokopi Ijazah & Transkrip Nilai',
              'Fotokopi KTP',
              'Fotokopi SKCK',
              'Pas Foto Terbaru (3x4)',
              'Portofolio',
            ],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserResume.empty(String userId, {String fullName = '', String email = '', String phone = ''}) {
    return UserResume(
      id: '',
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phone,
    );
  }

  factory UserResume.fromJson(Map<String, dynamic> json) {
    List<dynamic> parseJsonList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val;
      if (val is String) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return decoded;
        } catch (_) {}
      }
      return [];
    }

    final eduList = parseJsonList(json['educations'])
        .whereType<Map>()
        .map((e) => EducationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final expList = parseJsonList(json['experiences'])
        .whereType<Map>()
        .map((e) => ExperienceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final certList = parseJsonList(json['certifications'])
        .whereType<Map>()
        .map((e) => CertificationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final techList = parseJsonList(json['technical_skills'])
        .map((e) => e.toString())
        .toList();

    final softList = parseJsonList(json['soft_skills'])
        .map((e) => e.toString())
        .toList();

    final attachList = parseJsonList(json['selected_attachments'])
        .map((e) => e.toString())
        .toList();

    return UserResume(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      cityCountry: json['city_country'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      linkedinUrl: json['linkedin_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      summary: json['summary'] as String?,
      educations: eduList,
      experiences: expList,
      certifications: certList,
      technicalSkills: techList,
      softSkills: softList,
      birthPlaceDate: json['birth_place_date'] as String?,
      fullAddress: json['full_address'] as String?,
      maritalStatus: json['marital_status'] as String? ?? 'Belum Menikah',
      citizenship: json['citizenship'] as String? ?? 'Indonesia',
      lastEducation: json['last_education'] as String?,
      targetJobPosition: json['target_job_position'] as String?,
      selectedAttachments: attachList.isNotEmpty
          ? attachList
          : [
              'Curriculum Vitae (CV)',
              'Fotokopi Ijazah & Transkrip Nilai',
              'Fotokopi KTP',
              'Fotokopi SKCK',
              'Pas Foto Terbaru (3x4)',
              'Portofolio',
            ],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'full_name': fullName,
      'city_country': cityCountry,
      'phone_number': phoneNumber,
      'email': email,
      'linkedin_url': linkedinUrl,
      'portfolio_url': portfolioUrl,
      'summary': summary,
      'educations': educations.map((e) => e.toJson()).toList(),
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'technical_skills': technicalSkills,
      'soft_skills': softSkills,
      'birth_place_date': birthPlaceDate,
      'full_address': fullAddress,
      'marital_status': maritalStatus,
      'citizenship': citizenship,
      'last_education': lastEducation,
      'target_job_position': targetJobPosition,
      'selected_attachments': selectedAttachments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserResume copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? cityCountry,
    String? phoneNumber,
    String? email,
    String? linkedinUrl,
    String? portfolioUrl,
    String? summary,
    List<EducationItem>? educations,
    List<ExperienceItem>? experiences,
    List<CertificationItem>? certifications,
    List<String>? technicalSkills,
    List<String>? softSkills,
    String? birthPlaceDate,
    String? fullAddress,
    String? maritalStatus,
    String? citizenship,
    String? lastEducation,
    String? targetJobPosition,
    List<String>? selectedAttachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserResume(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      cityCountry: cityCountry ?? this.cityCountry,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      summary: summary ?? this.summary,
      educations: educations ?? List.from(this.educations),
      experiences: experiences ?? List.from(this.experiences),
      certifications: certifications ?? List.from(this.certifications),
      technicalSkills: technicalSkills ?? List.from(this.technicalSkills),
      softSkills: softSkills ?? List.from(this.softSkills),
      birthPlaceDate: birthPlaceDate ?? this.birthPlaceDate,
      fullAddress: fullAddress ?? this.fullAddress,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      citizenship: citizenship ?? this.citizenship,
      lastEducation: lastEducation ?? this.lastEducation,
      targetJobPosition: targetJobPosition ?? this.targetJobPosition,
      selectedAttachments: selectedAttachments ?? List.from(this.selectedAttachments),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
