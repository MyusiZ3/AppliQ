import '../../core/constants/app_enums.dart';

class JobApplication {
  final String id;
  final String userId;
  final String companyName;
  final String positionTitle;
  final String? location;
  final EmploymentType employmentType;
  final WorkSystem workSystem;
  final JobPortal jobPortal;
  final String? jobPortalCustom;
  final String? jobUrl;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final double? salaryExpectation;
  final double? salaryOffered;
  final String? notes;
  final String? cvFileUrl;
  final String? cvFileName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobApplication({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.positionTitle,
    this.location,
    this.employmentType = EmploymentType.fullTime,
    required this.workSystem,
    required this.jobPortal,
    this.jobPortalCustom,
    this.jobUrl,
    required this.status,
    required this.appliedDate,
    this.salaryExpectation,
    this.salaryOffered,
    this.notes,
    this.cvFileUrl,
    this.cvFileName,
    this.isFavorite = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      positionTitle: json['position_title'] as String? ?? '',
      location: json['location'] as String?,
      employmentType: EmploymentType.fromString(json['employment_type'] as String? ?? 'Full Time'),
      workSystem: WorkSystem.fromString(json['work_system'] as String? ?? 'On-site'),
      jobPortal: JobPortal.fromString(json['job_portal'] as String? ?? 'Linked In'),
      jobPortalCustom: json['job_portal_custom'] as String?,
      jobUrl: json['job_url'] as String?,
      status: ApplicationStatus.fromString(json['status'] as String? ?? 'Applied'),
      appliedDate: json['applied_date'] != null
          ? (DateTime.tryParse(json['applied_date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      salaryExpectation: json['salary_expectation'] != null
          ? double.tryParse(json['salary_expectation'].toString())
          : null,
      salaryOffered: json['salary_offered'] != null
          ? double.tryParse(json['salary_offered'].toString())
          : null,
      notes: json['notes'] as String?,
      cvFileUrl: json['cv_file_url'] as String?,
      cvFileName: json['cv_file_name'] as String?,
      isFavorite: json['is_favorite'] == true ||
          json['is_favorite'] == 'true' ||
          json['is_favorite'] == 1,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'position_title': positionTitle,
      'location': location,
      'employment_type': employmentType.label,
      'work_system': workSystem.label,
      'job_portal': jobPortal.label,
      'job_portal_custom': jobPortalCustom,
      'job_url': jobUrl,
      'status': status.label,
      'applied_date': appliedDate.toIso8601String().split('T')[0],
      'salary_expectation': salaryExpectation,
      'salary_offered': salaryOffered,
      'notes': notes,
      'cv_file_url': cvFileUrl,
      'cv_file_name': cvFileName,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  JobApplication copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? positionTitle,
    String? location,
    EmploymentType? employmentType,
    WorkSystem? workSystem,
    JobPortal? jobPortal,
    String? jobPortalCustom,
    String? jobUrl,
    ApplicationStatus? status,
    DateTime? appliedDate,
    double? salaryExpectation,
    double? salaryOffered,
    String? notes,
    String? cvFileUrl,
    String? cvFileName,
    bool clearCvFile = false,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      positionTitle: positionTitle ?? this.positionTitle,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      workSystem: workSystem ?? this.workSystem,
      jobPortal: jobPortal ?? this.jobPortal,
      jobPortalCustom: jobPortalCustom ?? this.jobPortalCustom,
      jobUrl: jobUrl ?? this.jobUrl,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      salaryExpectation: salaryExpectation ?? this.salaryExpectation,
      salaryOffered: salaryOffered ?? this.salaryOffered,
      notes: notes ?? this.notes,
      cvFileUrl: clearCvFile ? null : (cvFileUrl ?? this.cvFileUrl),
      cvFileName: clearCvFile ? null : (cvFileName ?? this.cvFileName),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
