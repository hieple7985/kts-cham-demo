
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin', 'sales', 'team_leader'
  final String? teamId;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.teamId,
    this.avatarUrl,
  });

  // Factory constructor: Tạo object từ Map (JSON)
  // Đây là nơi duy nhất chúng ta chấp nhận sự "bừa bãi" của JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] ?? json['name'] ?? 'Unknown', // Fallback an toàn
      role: json['role'] as String? ?? 'sales',
      teamId: json['team_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  // Method: Chuyển ngược lại thành Map (để lưu xuống đĩa hoặc gửi đi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'team_id': teamId,
      'avatar_url': avatarUrl,
    };
  }

  // CopyWith: Tạo bản sao sửa đổi (Immutable pattern)
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? teamId,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
