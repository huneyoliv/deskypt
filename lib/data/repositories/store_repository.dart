import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/studicon_item_model.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<StudiconItemModel>> fetchCatalog() async {
    final List<StudiconItemModel> catalog = [];
    final Set<int> ownedIds = {};

    // 1. Fetch user owned studicon IDs
    try {
      final myResp = await _apiClient.get('/studicon/my/list?lang=pt');
      if (myResp.data is Map<String, dynamic> && myResp.data['s'] == true) {
        final myRaw = myResp.data['my'];
        if (myRaw is List) {
          for (final item in myRaw) {
            if (item is Map<String, dynamic>) {
              final id = item['id'] as int? ?? 0;
              if (id > 0) ownedIds.add(id);
            } else if (item is int) {
              ownedIds.add(item);
            }
          }
        }
      }
    } catch (_) {}

    // 2. Fetch famous/new public studicons from CDN
    try {
      final publicResp = await _apiClient.get(
        '${ApiConstants.metadataCdnUrl}/studicon/list/famous?p=1&lang=pt',
      );
      if (publicResp.data is Map<String, dynamic> && publicResp.data['s'] == true) {
        final scs = publicResp.data['scs'];
        if (scs is List) {
          for (final item in scs) {
            if (item is Map<String, dynamic>) {
              final model = StudiconItemModel.fromJson(item);
              final isOwned = ownedIds.contains(model.id);
              catalog.add(model.copyWith(isOwned: isOwned));
            }
          }
        }
      }
    } catch (_) {}

    // 3. If public catalog returned items, return catalog
    if (catalog.isNotEmpty) {
      return catalog;
    }

    // Fallback: If public catalog endpoint fails or returns empty, show user owned IDs
    if (ownedIds.isNotEmpty) {
      return ownedIds.map((id) {
        return StudiconItemModel(
          id: id,
          name: 'Studicon #$id',
          category: 'Meus Studicons',
          priceFlames: 0,
          isOwned: true,
        );
      }).toList();
    }

    // Default basic catalog items if completely offline
    return [
      const StudiconItemModel(
        id: 377,
        name: 'Estrategista do Deserto',
        category: 'Mascotes',
        priceFlames: 100,
        isOwned: true,
        isEquipped: true,
      ),
      const StudiconItemModel(
        id: 120,
        name: 'Panda de Foco',
        category: 'Mascotes',
        priceFlames: 150,
        isOwned: false,
      ),
      const StudiconItemModel(
        id: 50,
        name: 'Gato Estudioso',
        category: 'Mascotes',
        priceFlames: 200,
        isOwned: false,
      ),
    ];
  }

  Future<bool> equipStudicon(int studiconId) async {
    try {
      final response = await _apiClient.post(
        '/studicon/equip',
        data: {'id': studiconId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }
}
