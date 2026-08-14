import '../../core/cdn/cdn_resolver.dart';

class GroupMemberModel {
  final int userId;
  final String name;
  final int studiconId;
  final bool isStudying;
  final bool isPaused;
  final int studyMs;
  final int? sessionStartMs;
  final bool hasCustomAvatar;

  const GroupMemberModel({
    required this.userId,
    required this.name,
    required this.studiconId,
    required this.isStudying,
    this.isPaused = false,
    required this.studyMs,
    this.sessionStartMs,
    required this.hasCustomAvatar,
  });

  String get avatarUrl => CdnResolver.userAvatarUrl(
        userId: userId,
        hasCustomAvatar: hasCustomAvatar,
        studiconId: studiconId,
        isStudying: isStudying,
        isPaused: isPaused,
        studyMs: studyMs,
      );

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final dl = json['dl'] as Map<String, dynamic>?;
    final isStudying = dl?['is'] as bool? ?? json['isStudying'] as bool? ?? json['is'] as bool? ?? false;
    final isPaused = dl?['ia'] as bool? ?? dl?['ip'] as bool? ?? json['isPaused'] as bool? ?? json['ia'] as bool? ?? json['ip'] as bool? ?? false;
    final studyMs = (dl?['sm'] ?? dl?['tp'] ?? json['studyMs'] ?? json['sm'] ?? 0) as int;
    final sessionStart = dl?['ss'] as int? ?? json['ss'] as int? ?? json['session_start'] as int?;
    final sd = json['gd'] as int? ?? json['sd'] as int? ?? json['st'] as int? ?? json['pv'] as int? ?? json['studiconId'] as int? ?? -1;

    return GroupMemberModel(
      userId: json['ud'] as int? ?? json['userId'] as int? ?? json['id'] as int? ?? 0,
      name: (json['n'] ?? json['name'] ?? json['nickname'] ?? 'Membro').toString().trim(),
      studiconId: sd,
      isStudying: isStudying,
      isPaused: isPaused,
      studyMs: studyMs,
      sessionStartMs: sessionStart,
      hasCustomAvatar: json['hasCustomAvatar'] as bool? ?? false,
    );
  }
}
