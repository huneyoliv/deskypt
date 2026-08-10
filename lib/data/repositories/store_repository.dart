import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/studicon_item_model.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<StudiconItemModel>> fetchCatalog() async {
    try {
      final response = await _apiClient.get('${ApiConstants.metadataCdnUrl}/catalog.json');
      final data = response.data as Map<String, dynamic>;
      if (data['items'] != null && data['items'] is List) {
        final list = data['items'] as List;
        return list
            .map((item) => StudiconItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [
      const StudiconItemModel(
        id: 377,
        name: 'Flame Mascot Original',
        category: 'Mascotes',
        priceFlames: 0,
        isOwned: true,
        isEquipped: true,
      ),
      const StudiconItemModel(
        id: 120,
        name: 'Panda de Foco',
        category: 'Mascotes',
        priceFlames: 150,
        isOwned: true,
        isEquipped: false,
      ),
      const StudiconItemModel(
        id: 50,
        name: 'Gato Estudioso',
        category: 'Mascotes',
        priceFlames: 200,
        isOwned: false,
        isEquipped: false,
      ),
      const StudiconItemModel(
        id: 90,
        name: 'Cacto Disciplinado',
        category: 'Especiais',
        priceFlames: 250,
        isOwned: false,
        isEquipped: false,
      ),
      const StudiconItemModel(
        id: 110,
        name: 'Dragão Flamejante',
        category: 'Animações',
        priceFlames: 500,
        isOwned: false,
        isEquipped: false,
      ),
    ];
  }
}
