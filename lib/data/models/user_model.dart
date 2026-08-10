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
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['n'] as String? ?? '',
      email: json['e'] as String? ?? '',
      studiconId: json['pv'] as int? ?? -1,
      profilePhotoUrl: json['hasCustomAvatar'] == true
          ? 'https://alicdn.tgclab.com/user/profile/${json['id']}.jpg'
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
