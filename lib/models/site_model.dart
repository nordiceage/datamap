import 'base_site_model.dart';
import 'site_user_model.dart';

class SiteModel implements BaseSiteModel {
  final String id;
  final SiteUserModel user;
  @override
  final String siteName;
  final String siteType;
  final String siteImage;
  final bool isDefaultSite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SiteModel({
    required this.id,
    required this.user,
    required this.siteName,
    required this.siteType,
    required this.siteImage,
    required this.isDefaultSite,
    required this.createdAt,
    this.updatedAt,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] as String,
      user: json['user'] != null ? SiteUserModel.fromJson(json['user'] as Map<String, dynamic>) : SiteUserModel.defaultUser(),
      siteName: json['siteName'] as String,
      siteType: json['siteType'] as String,
      siteImage: json['siteImage'] as String,
      isDefaultSite: json['isDefaultSite'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'siteName': siteName,
      'siteType': siteType,
      'siteImage': siteImage,
      'isDefaultSite': isDefaultSite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
