import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/rank_entry_model.dart';

class RankRepository {
  final ApiClient _apiClient;

  RankRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<RankEntryModel>> fetchGlobalRanks(String category) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      
      final response = await _apiClient.get(
        '${ApiConstants.metadataCdnUrl}/logs/category/member/ranks?date=$dateStr&categoryID=0&countryID=23&page=1&type=day',
      );
      
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['ms'] ?? data['ranks'];
        if (list is List) {
          return list
              .asMap()
              .entries
              .map((entry) => RankEntryModel.fromJson(
                  entry.value as Map<String, dynamic>, entry.key + 1))
              .toList();
        }
      }
    } catch (_) {}

    return [];
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
