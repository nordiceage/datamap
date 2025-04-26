class UserModel {
  String fullName;
  final String email;
  final String accessToken;
  final String refreshToken;
  String? profileImage;

  UserModel({
    required this.fullName,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    this.profileImage,
  });

  // Converts the UserModel instance to a Map (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'username': fullName,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'profileImage': profileImage,
    };
  }

  // Factory constructor to create an instance from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['username'],
      email: json['email'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      profileImage: json['profileImage'],
    );
  }
}
