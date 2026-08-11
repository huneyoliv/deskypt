import '../../core/cdn/cdn_resolver.dart';

class ChatMessageModel {
  final int id;
  final int senderId;
  final String senderName;
  final int studiconId;
  final String message;
  final String? photoUrl;
  final String? stickerUrl;
  final String? imageUrl;
  final String type; // 'text' | 'sticker' | 'image'
  final DateTime sentAt;
  final bool isNotice;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.studiconId,
    required this.message,
    this.photoUrl,
    this.stickerUrl,
    this.imageUrl,
    this.type = 'text',
    required this.sentAt,
    this.isNotice = false,
  });

  String get avatarUrl => CdnResolver.studiconUrl(studiconId, StudiconPose.mini);

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String? photo;
    if (json['photo'] != null && (json['photo'] as String).isNotEmpty) {
      photo = CdnResolver.chatPhotoUrl(json['photo'] as String);
    }

    final sticker = json['stickerUrl'] as String? ?? json['sticker'] as String?;
    final image = json['imageUrl'] as String? ?? photo;
    final msgType = json['type'] as String? ??
        (sticker != null ? 'sticker' : (image != null ? 'image' : 'text'));

    DateTime sentTime = DateTime.now();
    if (json['ts'] != null) {
      final tsNum = json['ts'];
      if (tsNum is num) {
        sentTime = DateTime.fromMillisecondsSinceEpoch((tsNum * 1000).toInt());
      }
    } else if (json['ca'] != null && json['ca'] is int) {
      sentTime = DateTime.fromMillisecondsSinceEpoch(json['ca'] as int);
    }

    return ChatMessageModel(
      id: json['idx'] as int? ?? json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      senderId: json['uid'] as int? ?? json['ud'] as int? ?? 0,
      senderName: json['nn'] as String? ?? json['n'] as String? ?? 'Usuário',
      studiconId: json['st'] as int? ?? 377,
      message: json['msg'] as String? ?? json['m'] as String? ?? json['text'] as String? ?? '',
      photoUrl: photo,
      stickerUrl: sticker,
      imageUrl: image,
      type: msgType,
      sentAt: sentTime,
      isNotice: json['isNotice'] as bool? ?? false,
    );
  }
}
