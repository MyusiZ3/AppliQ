import '../../core/constants/app_enums.dart';

class JobApplication {
  final String id;
  final String userId;
  final String companyName;
  final String positionTitle;
  final String? location;
  final WorkSystem workSystem;
  final JobPortal jobPortal;
  final String? jobPortalCustom;
  final String? jobUrl;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final double? salaryExpectation;
  final double? salaryOffered;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobApplication({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.positionTitle,
    this.location,
    required this.workSystem,
    required this.jobPortal,
    this.jobPortalCustom,
    this.jobUrl,
    required this.status,
    required this.appliedDate,
    this.salaryExpectation,
    this.salaryOffered,
    this.notes,
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
      workSystem: WorkSystem.fromString(json['work_system'] as String? ?? 'On-site'),
      jobPortal: JobPortal.fromString(json['job_portal'] as String? ?? 'Linked In'),
      jobPortalCustom: json['job_portal_custom'] as String?,
      jobUrl: json['job_url'] as String?,
      status: ApplicationStatus.fromString(json['status'] as String? ?? 'Applied'),
      appliedDate: json['applied_date'] != null
          ? DateTime.parse(json['applied_date'] as String)
          : DateTime.now(),
      salaryExpectation: json['salary_expectation'] != null
          ? double.tryParse(json['salary_expectation'].toString())
          : null,
      salaryOffered: json['salary_offered'] != null
          ? double.tryParse(json['salary_offered'].toString())
          : null,
      notes: json['notes'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
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
      'work_system': workSystem.label,
      'job_portal': jobPortal.label,
      'job_portal_custom': jobPortalCustom,
      'job_url': jobUrl,
      'status': status.label,
      'applied_date': appliedDate.toIso8601String().split('T')[0],
      'salary_expectation': salaryExpectation,
      'salary_offered': salaryOffered,
      'notes': notes,
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
    WorkSystem? workSystem,
    JobPortal? jobPortal,
    String? jobPortalCustom,
    String? jobUrl,
    ApplicationStatus? status,
    DateTime? appliedDate,
    double? salaryExpectation,
    double? salaryOffered,
    String? notes,
    bool? isFavorite,
    DateTime? updatedAt,
  }) {
    return JobApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      positionTitle: positionTitle ?? this.positionTitle,
      location: location ?? this.location,
      workSystem: workSystem ?? this.workSystem,
      jobPortal: jobPortal ?? this.jobPortal,
      jobPortalCustom: jobPortalCustom ?? this.jobPortalCustom,
      jobUrl: jobUrl ?? this.jobUrl,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      salaryExpectation: salaryExpectation ?? this.salaryExpectation,
      salaryOffered: salaryOffered ?? this.salaryOffered,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
