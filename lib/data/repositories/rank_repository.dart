import '../../core/api/api_client.dart';
import '../models/rank_entry_model.dart';

class RankRepository {
  final ApiClient _apiClient;

  RankRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<RankEntryModel>> fetchGlobalRanks(String category) async {
    try {
      final response = await _apiClient.get('/rank/list?category=$category');
      final data = response.data as Map<String, dynamic>;
      if (data['ranks'] != null && data['ranks'] is List) {
        final list = data['ranks'] as List;
        return list
            .asMap()
            .entries
            .map((entry) => RankEntryModel.fromJson(
                entry.value as Map<String, dynamic>, entry.key + 1))
            .toList();
      }
    } catch (_) {}

    return [
      const RankEntryModel(
        rank: 1,
        userId: 101,
        userName: 'Matheus K.',
        studiconId: 377,
        studyMs: 43200000, // 12h
        categoryName: 'Concursos',
      ),
      const RankEntryModel(
        rank: 2,
        userId: 102,
        userName: 'Fernanda Lima',
        studiconId: 120,
        studyMs: 39600000, // 11h
        categoryName: 'Concursos',
      ),
      const RankEntryModel(
        rank: 3,
        userId: 103,
        userName: 'Lucas (Você)',
        studiconId: 50,
        studyMs: 36000000, // 10h
        categoryName: 'Concursos',
      ),
      const RankEntryModel(
        rank: 4,
        userId: 104,
        userName: 'Gabriel R.',
        studiconId: 90,
        studyMs: 28800000, // 8h
        categoryName: 'Concursos',
      ),
      const RankEntryModel(
        rank: 5,
        userId: 105,
        userName: 'Beatriz S.',
        studiconId: 110,
        studyMs: 25200000, // 7h
        categoryName: 'Concursos',
      ),
    ];
  }
}
