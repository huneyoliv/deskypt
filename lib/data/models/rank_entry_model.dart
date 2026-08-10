import '../../core/cdn/cdn_resolver.dart';

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
      rank: json['rank'] as int? ?? rankIndex,
      userId: json['ud'] as int? ?? json['userId'] as int? ?? 0,
      userName: json['n'] as String? ?? json['userName'] as String? ?? 'Usuário',
      studiconId: json['st'] as int? ?? json['pv'] as int? ?? 377,
      studyMs: json['sm'] as int? ?? 0,
      categoryName: json['c'] as String? ?? 'Geral',
      hasCustomAvatar: json['hasCustomAvatar'] as bool? ?? false,
    );
  }
}
