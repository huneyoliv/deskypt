class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['t'] ?? 'Notificação').toString(),
      message: (json['content'] ?? json['message'] ?? json['m'] ?? '').toString(),
      type: (json['type'] ?? json['tp'] ?? 'info').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
    );
  }
}
