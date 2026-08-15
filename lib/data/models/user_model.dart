import '../../core/utils/json_utils.dart';
import 'group_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String statusMessage;
  final String categoryName;
  final int categoryId;
  final int studiconId;
  final String? profilePhotoUrl;
  final String jwtToken;
  final List<GroupModel> userGroups;
  final int flamesBalance;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.statusMessage = '',
    this.categoryName = 'Geral',
    this.categoryId = 0,
    required this.studiconId,
    this.profilePhotoUrl,
    required this.jwtToken,
    this.userGroups = const [],
    this.flamesBalance = 100,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    final userId = safeInt(json['id'] ?? json['ud'] ?? json['userId']);
    final studiconId = safeInt(json['pv'] ?? json['st'] ?? json['studiconId'], 0);
    final hasCustomAvatar = safeBool(json['hasCustomAvatar']);

    final groupsRaw = json['gs'];
    final List<GroupModel> groups = (groupsRaw is List)
        ? groupsRaw
            .whereType<Map<String, dynamic>>()
            .map((g) => GroupModel.fromJson(g))
            .toList()
        : const [];

    return UserModel(
      id: userId,
      name: safeString(json['n'] ?? json['name']),
      email: safeString(json['e'] ?? json['email']),
      statusMessage: safeString(json['stm'] ?? json['statusMsg'] ?? json['p']?['stm']),
      categoryName: safeString(json['ct'] ?? json['categoryName']),
      categoryId: safeInt(json['ci'] ?? json['categoryId']),
      studiconId: studiconId,
      profilePhotoUrl: hasCustomAvatar
          ? 'https://alicdn.tgclab.com/user/profile/$userId.jpg'
          : null,
      jwtToken: token,
      userGroups: groups,
      flamesBalance: safeInt(json['fl'] ?? json['flames'] ?? json['flameBalance'], 100),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'n': name,
      'e': email,
      'stm': statusMessage,
      'ct': categoryName,
      'ci': categoryId,
      'pv': studiconId,
      'jwtToken': jwtToken,
      'fl': flamesBalance,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? statusMessage,
    String? categoryName,
    int? categoryId,
    int? studiconId,
    String? profilePhotoUrl,
    String? jwtToken,
    List<GroupModel>? userGroups,
    int? flamesBalance,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      statusMessage: statusMessage ?? this.statusMessage,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      studiconId: studiconId ?? this.studiconId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      jwtToken: jwtToken ?? this.jwtToken,
      userGroups: userGroups ?? this.userGroups,
      flamesBalance: flamesBalance ?? this.flamesBalance,
    );
  }
}
