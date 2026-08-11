import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';

class TimerRepository {
  final ApiClient _apiClient;

  TimerRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<bool> startStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime startAt,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.studyStart,
      data: {
        'subject': subjectTitle,
        'subject_id': subjectId,
        'deviceModel': 'Desktop',
        'taskId': null,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['s'] == true;
  }

  Future<Map<String, dynamic>?> stopStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime stopAt,
    required int studyMs,
    required DateTime startAt,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.studyStop,
      data: {
        'subject': subjectTitle,
        'subject_id': subjectId,
        'startedAt': startAt.millisecondsSinceEpoch,
        'study_ms': studyMs,
        'deviceModel': 'Desktop',
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == true) {
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchDailyLog(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month}-${date.day}';
      final response = await _apiClient.get('/logs/day?date=$dateStr');
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        return data;
      }
    } catch (_) {}
    return null;
  }

  Future<DateTime> syncTime() async {
    final response = await _apiClient.get(ApiConstants.timeSync);
    final data = response.data as Map<String, dynamic>;
    if (data['timestamp'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
    }
    return DateTime.now();
  }
}
