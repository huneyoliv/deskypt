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
    return RankEntryModel(
      rank: safeInt(json['rank'], rankIndex),
      userId: safeInt(json['ud'] ?? json['userId']),
      userName: safeString(json['n'] ?? json['userName'], 'Usuário'),
      studiconId: safeInt(json['st'] ?? json['pv'], 377),
      studyMs: safeInt(json['sm']),
      categoryName: safeString(json['c'], 'Geral'),
      hasCustomAvatar: safeBool(json['hasCustomAvatar']),
    );
  }
}
