class ApplicationLog {
  final String id;
  final String applicationId;
  final String userId;
  final String stageName;
  final DateTime? scheduledAt;
  final String? interviewerName;
  final String? meetingLink;
  final String? notes;
  final String result;
  final DateTime createdAt;

  ApplicationLog({
    required this.id,
    required this.applicationId,
    required this.userId,
    required this.stageName,
    this.scheduledAt,
    this.interviewerName,
    this.meetingLink,
    this.notes,
    this.result = 'Waiting',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ApplicationLog.fromJson(Map<String, dynamic> json) {
    return ApplicationLog(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      userId: json['user_id'] as String,
      stageName: json['stage_name'] as String? ?? '',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      interviewerName: json['interviewer_name'] as String?,
      meetingLink: json['meeting_link'] as String?,
      notes: json['notes'] as String?,
      result: json['result'] as String? ?? 'Waiting',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'user_id': userId,
      'stage_name': stageName,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'interviewer_name': interviewerName,
      'meeting_link': meetingLink,
      'notes': notes,
      'result': result,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
