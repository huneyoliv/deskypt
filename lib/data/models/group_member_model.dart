import '../../core/cdn/cdn_resolver.dart';
import '../../core/utils/json_utils.dart';

class GroupMemberModel {
  final int userId;
  final String name;
  final int studiconId;
  final bool isStudying;
  final bool isPaused;
  final int studyMs;
  final int? sessionStartMs;
  final bool hasCustomAvatar;
  final String? currentSubject;
  final int? subjectColor;

  const GroupMemberModel({
    required this.userId,
    required this.name,
    required this.studiconId,
    required this.isStudying,
    this.isPaused = false,
    required this.studyMs,
    this.sessionStartMs,
    required this.hasCustomAvatar,
    this.currentSubject,
    this.subjectColor,
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
    final dl = json['dl'] is Map ? json['dl'] as Map<String, dynamic> : null;
    final isStudying = safeBool(dl?['is'] ?? json['isStudying'] ?? json['is']);
    final isPaused = safeBool(dl?['ia'] ?? dl?['ip'] ?? json['isPaused'] ?? json['ia'] ?? json['ip']);
    final studyMs = safeInt(dl?['sm'] ?? dl?['tp'] ?? json['studyMs'] ?? json['sm'], 0);
    final sessionStart = dl?['ss'] != null ? safeInt(dl?['ss']) : null;
    final sd = safeInt(json['sd'] ?? json['st'] ?? json['pv'] ?? json['gd'] ?? json['studiconId'], -1);

    return GroupMemberModel(
      userId: safeInt(json['ud'] ?? json['userId'] ?? json['id']),
      name: safeString(json['n'] ?? json['name'] ?? json['nickname'], 'Membro').trim(),
      studiconId: sd,
      isStudying: isStudying,
      isPaused: isPaused,
      studyMs: studyMs,
      sessionStartMs: sessionStart,
      hasCustomAvatar: safeBool(json['hasCustomAvatar']),
      currentSubject: dl?['sn'] != null || dl?['sb'] != null
          ? safeString(dl?['sn'] ?? dl?['sb'])
          : null,
      subjectColor: dl?['co'] != null ? safeInt(dl?['co']) : null,
    );
  }
}
