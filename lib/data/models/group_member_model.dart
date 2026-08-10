import '../../core/cdn/cdn_resolver.dart';

class GroupMemberModel {
  final int userId;
  final String name;
  final int studiconId;
  final bool isStudying;
  final int studyMs;
  final bool hasCustomAvatar;

  const GroupMemberModel({
    required this.userId,
    required this.name,
    required this.studiconId,
    required this.isStudying,
    required this.studyMs,
    required this.hasCustomAvatar,
  });

  String get avatarUrl => CdnResolver.userAvatarUrl(
        userId: userId,
        hasCustomAvatar: hasCustomAvatar,
        studiconId: studiconId,
        isStudying: isStudying,
        studyMs: studyMs,
      );

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['ud'] as int? ?? json['id'] as int? ?? 0,
      name: json['n'] as String? ?? json['nickname'] as String? ?? 'Membro',
      studiconId: json['st'] as int? ?? json['pv'] as int? ?? 377,
      isStudying: json['is'] as bool? ?? json['dlIsStudying'] as bool? ?? false,
      studyMs: json['sm'] as int? ?? 0,
      hasCustomAvatar: json['hasCustomAvatar'] as bool? ?? false,
    );
  }
}
