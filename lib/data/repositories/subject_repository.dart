import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/subject_model.dart';

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

  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await _apiClient.post(ApiConstants.reloadInfo);
    final data = response.data as Map<String, dynamic>;
    if (data['ss'] != null && data['ss'] is List) {
      final list = data['ss'] as List;
      return list
          .map((item) => SubjectModel.fromJson(item as Map<String, dynamic>))
          .where((s) => !s.isDeleted)
          .toList();
    }
    return [];
  }
}
