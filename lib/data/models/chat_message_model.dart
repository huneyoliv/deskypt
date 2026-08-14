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
  final String? thumbUrl;
  final String type;
  final DateTime sentAt;
  final bool isNotice;
  final Map<String, List<int>> reactions;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.studiconId,
    required this.message,
    this.photoUrl,
    this.stickerUrl,
    this.imageUrl,
    this.thumbUrl,
    this.type = 'text',
    required this.sentAt,
    this.isNotice = false,
    this.reactions = const {},
  });

  String get avatarUrl => CdnResolver.studiconUrl(studiconId, StudiconPose.mini);

  ChatMessageModel copyWith({
    int? id,
    int? senderId,
    String? senderName,
    int? studiconId,
    String? message,
    String? photoUrl,
    String? stickerUrl,
    String? imageUrl,
    String? thumbUrl,
    String? type,
    DateTime? sentAt,
    bool? isNotice,
    Map<String, List<int>>? reactions,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      studiconId: studiconId ?? this.studiconId,
      message: message ?? this.message,
      photoUrl: photoUrl ?? this.photoUrl,
      stickerUrl: stickerUrl ?? this.stickerUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      isNotice: isNotice ?? this.isNotice,
      reactions: reactions ?? this.reactions,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String? photo;
    if (json['photo'] != null && (json['photo'] as String).isNotEmpty) {
      photo = CdnResolver.chatPhotoUrl(json['photo'] as String);
    }

    final rawImg = json['img'] as String? ?? json['imageUrl'] as String? ?? photo;
    final rawThumb = json['th'] as String? ?? json['thumbUrl'] as String?;
    final sticker = json['stickerUrl'] as String? ?? json['sticker'] as String?;
    final image = rawImg;
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

    final reactionsMap = <String, List<int>>{};
    if (json['reactions'] is Map) {
      (json['reactions'] as Map).forEach((k, v) {
        if (v is List) {
          reactionsMap[k.toString()] = v.map((e) => (e as num).toInt()).toList();
        }
      });
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
      thumbUrl: rawThumb,
      type: msgType,
      sentAt: sentTime,
      isNotice: json['isNotice'] as bool? ?? false,
      reactions: reactionsMap,
    );
  }
}
