class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final String? targetRole;
  final String? username;
  final String? phoneNumber;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    this.targetRole,
    this.username,
    this.phoneNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      targetRole: json['target_role'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'target_role': targetRole,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? targetRole,
    String? username,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetRole: targetRole ?? this.targetRole,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
