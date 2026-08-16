import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/study_date_helper.dart';
import '../models/rank_entry_model.dart';

class RankRepository {
  final ApiClient _apiClient;

  RankRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<RankEntryModel>> fetchGlobalRanks({
    String period = 'day',
    int categoryId = 0,
    int countryId = ApiConstants.defaultCountryId,
    int page = 1,
  }) async {
    try {
      final dateStr = StudyDateHelper.getStudyDateString();

      final response = await _apiClient.get(
        '${ApiConstants.metadataCdnUrl}/logs/category/member/ranks?date=$dateStr&categoryID=$categoryId&countryID=$countryId&page=$page&type=$period',
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['ms'] ?? data['ranks'];
        if (list is List) {
          final startRank = (page - 1) * 20 + 1;
          return list
              .asMap()
              .entries
              .map((entry) => RankEntryModel.fromJson(
                  entry.value as Map<String, dynamic>, startRank + entry.key))
              .toList();
        }
      }
    } catch (_) {}

    return [];
  }

  Future<int?> fetchMyCategoryRank({
    int categoryId = 0,
    int countryId = ApiConstants.defaultCountryId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/logs/my-category-rank?category_id=$categoryId&country_id=$countryId',
      );
      final data = response.data as Map<String, dynamic>;
      if (data['s'] == true) {
        return data['mr'] as int?;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>> fetchUserStats({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/logs/range/days',
        data: {
          'id': userId,
          'isMember': true,
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        return data;
      }
    } catch (_) {}

    return {'ls': [], 'ss': []};
  }
}
