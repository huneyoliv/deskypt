class TimelapseModel {
  final int id;
  final int userId;
  final String userName;
  final int studiconId;
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final String category;

  const TimelapseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.studiconId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.category,
  });

  factory TimelapseModel.fromJson(Map<String, dynamic> json) {
    return TimelapseModel(
      id: json['id'] as int? ?? json['timelapse_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['ud'] as int? ?? 0,
      userName: json['user_name'] as String? ?? json['n'] as String? ?? 'Estudante',
      studiconId: json['studicon_id'] as int? ?? json['st'] as int? ?? 0,
      videoUrl: json['video_url'] as String? ?? json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumb'] as String? ?? '',
      durationSeconds: json['duration'] as int? ?? 30,
      likesCount: json['likes'] as int? ?? json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'] as String? ?? 'Geral',
    );
  }
}
