
class RoleModel {
  final String id;
  final String role;
  final DateTime createdAt;

  RoleModel({
    required this.id,
    required this.role,
    required this.createdAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
