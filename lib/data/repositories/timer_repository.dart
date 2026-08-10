import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';

class TimerRepository {
  final ApiClient _apiClient;

  TimerRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<bool> startStudy({
    required int subjectId,
    required DateTime startAt,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.studyStart,
      data: {
        'subject_id': subjectId,
        'start_at': startAt.toUtc().toIso8601String(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['s'] == true;
  }

  Future<bool> stopStudy({
    required int subjectId,
    required DateTime stopAt,
    required int studyMs,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.studyStop,
      data: {
        'subject_id': subjectId,
        'stop_at': stopAt.toUtc().toIso8601String(),
        'study_ms': studyMs,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['s'] == true;
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
