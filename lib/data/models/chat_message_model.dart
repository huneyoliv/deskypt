import '../../core/cdn/cdn_resolver.dart';

class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final int studiconId;
  final String message;
  final String? photoUrl;
  final DateTime sentAt;
  final bool isNotice;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.studiconId,
    required this.message,
    this.photoUrl,
    required this.sentAt,
    this.isNotice = false,
  });

  String get avatarUrl => CdnResolver.studiconUrl(studiconId, StudiconPose.mini);

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String? photo;
    if (json['photo'] != null && (json['photo'] as String).isNotEmpty) {
      photo = CdnResolver.chatPhotoUrl(json['photo'] as String);
    }

    return ChatMessageModel(
      id: json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      senderId: json['ud'] as int? ?? 0,
      senderName: json['n'] as String? ?? 'Usuário',
      studiconId: json['st'] as int? ?? 377,
      message: json['m'] as String? ?? json['text'] as String? ?? '',
      photoUrl: photo,
      sentAt: json['ca'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ca'] as int)
          : DateTime.now(),
      isNotice: json['isNotice'] as bool? ?? false,
    );
  }
}
