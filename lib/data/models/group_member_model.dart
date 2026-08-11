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
    final dl = json['dl'] as Map<String, dynamic>?;
    final isStudying = dl?['is'] as bool? ?? json['is'] as bool? ?? false;
    final studyMs = dl?['sm'] as int? ?? json['sm'] as int? ?? 0;
    final sd = json['sd'] as int? ?? json['st'] as int? ?? json['pv'] as int? ?? 0;

    return GroupMemberModel(
      userId: json['ud'] as int? ?? json['id'] as int? ?? 0,
      name: json['n'] as String? ?? json['nickname'] as String? ?? 'Membro',
      studiconId: sd,
      isStudying: isStudying,
      studyMs: studyMs,
      hasCustomAvatar: json['hasCustomAvatar'] as bool? ?? false,
    );
  }
}
