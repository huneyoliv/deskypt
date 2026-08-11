import '../../core/cdn/cdn_resolver.dart';
import '../../core/utils/json_utils.dart';

class RankEntryModel {
  final int rank;
  final int userId;
  final String userName;
  final int studiconId;
  final int studyMs;
  final String categoryName;
  final bool hasCustomAvatar;

  const RankEntryModel({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.studiconId,
    required this.studyMs,
    required this.categoryName,
    this.hasCustomAvatar = false,
  });

  String get avatarUrl => CdnResolver.userAvatarUrl(
        userId: userId,
        hasCustomAvatar: hasCustomAvatar,
        studiconId: studiconId,
        isStudying: false,
        studyMs: studyMs,
      );

  factory RankEntryModel.fromJson(Map<String, dynamic> json, int rankIndex) {
    final dl = json['dl'] is Map<String, dynamic> ? json['dl'] as Map<String, dynamic> : null;
    final studyMs = safeInt(dl?['sm'] ?? json['sm']);
    final studiconId = safeInt(json['sd'] ?? json['st'] ?? json['pv'] ?? json['si'], -1);
    final category = safeString(json['ct'] ?? json['c'], 'Geral');

    return RankEntryModel(
      rank: safeInt(json['rank'], rankIndex),
      userId: safeInt(json['ud'] ?? json['userId']),
      userName: safeString(json['n'] ?? json['userName'], 'Usuário'),
      studiconId: studiconId,
      studyMs: studyMs,
      categoryName: category,
      hasCustomAvatar: safeBool(json['hasCustomAvatar']),
    );
  }
}
