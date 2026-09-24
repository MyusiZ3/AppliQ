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
          ? DateTime.tryParse(json['scheduled_at'].toString())
          : null,
      interviewerName: json['interviewer_name'] as String?,
      meetingLink: json['meeting_link'] as String?,
      notes: json['notes'] as String?,
      result: json['result'] as String? ?? 'Waiting',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
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

  ApplicationLog copyWith({
    String? id,
    String? applicationId,
    String? userId,
    String? stageName,
    DateTime? scheduledAt,
    String? interviewerName,
    String? meetingLink,
    String? notes,
    String? result,
    DateTime? createdAt,
  }) {
    return ApplicationLog(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      stageName: stageName ?? this.stageName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      interviewerName: interviewerName ?? this.interviewerName,
      meetingLink: meetingLink ?? this.meetingLink,
      notes: notes ?? this.notes,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
