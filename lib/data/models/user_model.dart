import '../../core/utils/json_utils.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final int studiconId;
  final String? profilePhotoUrl;
  final String jwtToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studiconId,
    this.profilePhotoUrl,
    required this.jwtToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    final userId = safeInt(json['id'] ?? json['ud'] ?? json['userId']);
    final studiconId = safeInt(json['pv'] ?? json['st'] ?? json['studiconId'], -1);
    final hasCustomAvatar = safeBool(json['hasCustomAvatar']);

    return UserModel(
      id: userId,
      name: safeString(json['n'] ?? json['name']),
      email: safeString(json['e'] ?? json['email']),
      studiconId: studiconId,
      profilePhotoUrl: hasCustomAvatar
          ? 'https://alicdn.tgclab.com/user/profile/$userId.jpg'
          : null,
      jwtToken: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n': name,
      'e': email,
      'pv': studiconId,
      'jwtToken': jwtToken,
    };
  }
}
