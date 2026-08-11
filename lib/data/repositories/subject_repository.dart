import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/subject_model.dart';

class SubjectFetchResult {
  final List<SubjectModel> subjects;
  final int todayTotalMs;

  const SubjectFetchResult({
    required this.subjects,
    required this.todayTotalMs,
  });
}

class SubjectRepository {
  final ApiClient _apiClient;

  SubjectRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<SubjectModel> createSubject({
    required String title,
    required int colorInt,
    int order = 100,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.subjectCreate,
      data: {
        'title': title,
        'color': colorInt,
        'order': order,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['s'] != true) {
      throw Exception(data['m'] ?? 'Falha ao criar matéria');
    }

    return SubjectModel.fromJson(data['subject'] ?? data);
  }

  Future<SubjectFetchResult> fetchSubjectsData() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.splashLogin,
        data: {
          'version': 810041,
          'pushToken': '',
          'timezone': 'America/Sao_Paulo',
          'deviceType': 'WIN',
          'osVersion': 10,
          'deviceModel': 'Desktop',
          'pv': 24,
          'language': 'pt',
        },
      );
      final data = response.data as Map<String, dynamic>;
      return _parseSplashData(data);
    } catch (_) {}

    try {
      final response = await _apiClient.post(ApiConstants.reloadInfo);
      final data = response.data as Map<String, dynamic>;
      return _parseSplashData(data);
    } catch (_) {}

    return const SubjectFetchResult(subjects: [], todayTotalMs: 0);
  }

  Future<List<SubjectModel>> fetchSubjects() async {
    final result = await fetchSubjectsData();
    return result.subjects;
  }

  SubjectFetchResult _parseSplashData(Map<String, dynamic> data) {
    final rawList = data['ss'] ?? data['p']?['ss'];
    final dl = data['dl'] as Map<String, dynamic>?;

    int todayTotalMs = 0;
    if (dl != null) {
      final sm = dl['sm'] ?? dl['tp'];
      if (sm is int) todayTotalMs = sm;
    }

    final Map<String, int> subjectTimes = {};
    if (dl != null && dl['ls'] is List) {
      for (final item in dl['ls']) {
        if (item is Map<String, dynamic>) {
          final name = item['sb'] as String? ?? '';
          final ms = item['sm'] as int? ?? 0;
          if (name.isNotEmpty) {
            subjectTimes[name] = (subjectTimes[name] ?? 0) + ms;
          }
        }
      }
    }

    List<SubjectModel> subjects = [];
    if (rawList != null && rawList is List) {
      subjects = rawList
          .map((item) {
            final model = SubjectModel.fromJson(item as Map<String, dynamic>);
            final ms = subjectTimes[model.title] ?? model.studyMs;
            return model.copyWith(studyMs: ms);
          })
          .where((s) => !s.isDeleted)
          .toList();
    }

    if (todayTotalMs == 0 && subjects.isNotEmpty) {
      todayTotalMs = subjects.fold<int>(0, (sum, s) => sum + s.studyMs);
    }

    return SubjectFetchResult(
      subjects: subjects,
      todayTotalMs: todayTotalMs,
    );
  }

  Future<bool> deleteSubject(int subjectId) async {
    try {
      final response = await _apiClient.post(
        '/user/subject/hard-delete',
        data: {'id': subjectId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> updateSubject(SubjectModel subject) async {
    try {
      final response = await _apiClient.post(
        '/user/subject/edit',
        data: {
          'id': subject.id,
          'title': subject.title,
          'color': subject.colorInt,
          'is_archived': false,
        },
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> archiveSubject(int subjectId, bool isArchived) async {
    try {
      final response = await _apiClient.post(
        '/user/subject/archive/change',
        data: {
          'id': subjectId,
          'is_archived': isArchived,
          'new': true,
        },
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }
}
