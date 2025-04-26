// site_user_model.dart

import 'role_model.dart';

class SiteUserModel {
  final String id;
  final String username;
  final String login;
  final String? phone;
  final List<RoleModel> roles;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  SiteUserModel({
    required this.id,
    required this.username,
    required this.login,
    this.phone,
    required this.roles,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory SiteUserModel.fromJson(Map<String, dynamic> json) {
    return SiteUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      login: json['login'] as String,
      phone: json['phone'] as String?,
      roles: (json['roles'] as List<dynamic>)
          .map((roleJson) => RoleModel.fromJson(roleJson as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'login': login,
      'phone': phone,
      'roles': roles.map((role) => role.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  static SiteUserModel defaultUser() {
    return SiteUserModel(
      id: 'default',
      username: 'Default User',
      login: 'default_login',
      phone: null,
      roles: [],
      status: 'inactive',
      createdAt: DateTime.now(),
      updatedAt: null,
      deletedAt: null,
    );
  }
}
