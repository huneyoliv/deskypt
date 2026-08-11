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
    final title = (json['i1'] ?? json['title'] ?? json['t'] ?? 'Notificação YPT').toString();
    final msg = (json['i2'] ?? json['i3'] ?? json['content'] ?? json['message'] ?? json['m'] ?? '').toString();
    final type = (json['nt'] ?? json['type'] ?? json['tp'] ?? 'info').toString();
    final dateStr = json['c'] ?? json['created_at'];
    final createdAt = dateStr != null ? DateTime.tryParse(dateStr.toString()) ?? DateTime.now() : DateTime.now();
    final isRead = json['ir'] as bool? ?? json['is_read'] as bool? ?? json['read'] as bool? ?? false;

    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: title.isNotEmpty ? title : 'Notificação YPT',
      message: msg,
      type: type,
      createdAt: createdAt,
      isRead: isRead,
    );
  }
}
