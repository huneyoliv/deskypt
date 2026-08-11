import '../../core/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationModel>> fetchNotifications({int page = 1, bool isNew = false}) async {
    try {
      final response = await _apiClient.get(
        '/user/notifications?page=$page&is_new=$isNew',
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['ns'] ?? data['notices'] ?? data['list'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        }
      }
    } catch (_) {}

    try {
      final response = await _apiClient.get('/notice/list');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['ns'] ?? data['notices'] ?? data['list'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.post(
        '/notice/read',
        data: {'noticeID': notificationId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get('/notice/unread_count');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['unread_count'] ?? data['cnt'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}
