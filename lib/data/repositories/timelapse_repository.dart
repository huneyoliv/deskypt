import '../../core/api/api_client.dart';
import '../models/timelapse_model.dart';

class TimelapseRepository {
  final ApiClient _apiClient;

  TimelapseRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<TimelapseModel>> fetchPublicTimelapses({int page = 1, String? dateStr}) async {
    try {
      final now = DateTime.now();
      final dateParam = dateStr ?? '${now.year}-${now.month}-${now.day}';
      final response = await _apiClient.get(
        '/timelapses?country_id=23&category_id=0&date=$dateParam&page=$page&visibility=public',
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['rs'] ?? data['timelapses'] ?? data['list'];
      if (list != null && list is List) {
        return list
            .map((t) => TimelapseModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<List<TimelapseModel>> fetchUserTimelapses(int userId, {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/timelapses?page=$page&user_id=$userId',
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['rs'] ?? data['timelapses'] ?? data['list'];
      if (list != null && list is List) {
        return list
            .map((t) => TimelapseModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<bool> likeTimelapse(int timelapseId) async {
    try {
      final response = await _apiClient.post(
        '/timelapse/like',
        data: {'timelapse_id': timelapseId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }
}
