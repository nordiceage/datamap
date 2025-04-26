class AddPlantSiteModel {
  String id;
  UserModel user;
  String siteName;
  String siteType;
  String? siteImage;
  bool isDefaultSite;
  DateTime createdAt;
  DateTime? updatedAt;

  AddPlantSiteModel({
    required this.id,
    required this.user,
    required this.siteName,
    required this.siteType,
    this.siteImage,
    required this.isDefaultSite,
    required this.createdAt,
    this.updatedAt,
  });

  factory AddPlantSiteModel.fromJson(Map<String, dynamic> json) {
    return AddPlantSiteModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      siteName: json['siteName'],
      siteType: json['siteType'],
      siteImage: json['siteImage'],
      isDefaultSite: json['isDefaultSite'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class UserModel {
  String id;
  String username;
  String login;
  String? phone;
  List<RoleModel> roles;
  String status;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      login: json['login'],
      phone: json['phone'],
      roles: (json['roles'] as List)
          .map((roleJson) => RoleModel.fromJson(roleJson))
          .toList(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }
}

class RoleModel {
  String id;
  String role;
  DateTime createdAt;
  RoleModel({
    required this.id,
    required this.role,
    required this.createdAt,
  });
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}