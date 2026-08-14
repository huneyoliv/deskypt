import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/studicon_item_model.dart';

class StoreRepository {
  final ApiClient _apiClient;

  StoreRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<StudiconItemModel>> fetchCatalog({String language = 'pt'}) async {
    final Map<int, StudiconItemModel> catalogMap = {};
    final Set<int> ownedIds = {};

    try {
      final myResp = await _apiClient.get(
        '/studicon/my/list',
        queryParameters: {'lang': language},
      );
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

    try {
      final famousResp = await _apiClient.get(
        '/studicon/list/famous',
        baseUrl: ApiConstants.metadataCdnUrl,
        queryParameters: {'p': 1, 'lang': language},
      );
      if (famousResp.data is Map<String, dynamic> && famousResp.data['s'] == true) {
        final scs = famousResp.data['scs'];
        if (scs is List) {
          for (final item in scs) {
            if (item is Map<String, dynamic>) {
              final model = StudiconItemModel.fromJson(item);
              final isOwned = ownedIds.contains(model.id);
              catalogMap[model.id] = model.copyWith(isOwned: isOwned);
            }
          }
        }
      }
    } catch (_) {}

    try {
      final newResp = await _apiClient.get(
        '/studicon/list/new',
        baseUrl: ApiConstants.metadataCdnUrl,
        queryParameters: {'p': 1, 'lang': language},
      );
      if (newResp.data is Map<String, dynamic> && newResp.data['s'] == true) {
        final scs = newResp.data['scs'];
        if (scs is List) {
          for (final item in scs) {
            if (item is Map<String, dynamic>) {
              final model = StudiconItemModel.fromJson(item);
              if (!catalogMap.containsKey(model.id)) {
                final isOwned = ownedIds.contains(model.id);
                catalogMap[model.id] = model.copyWith(isOwned: isOwned);
              }
            }
          }
        }
      }
    } catch (_) {}

    for (final id in ownedIds) {
      if (!catalogMap.containsKey(id)) {
        catalogMap[id] = StudiconItemModel(
          id: id,
          name: 'Studicon #$id',
          category: 'Meus Studicons',
          priceFlames: 0,
          isOwned: true,
        );
      }
    }

    return catalogMap.values.toList();
  }

  Future<List<StudiconItemModel>> fetchMyStudicons(
    int currentEquippedId, {
    String language = 'pt',
  }) async {
    final catalog = await fetchCatalog(language: language);
    return catalog
        .where((item) => item.isOwned || item.id == currentEquippedId)
        .map((item) => item.copyWith(isEquipped: item.id == currentEquippedId))
        .toList();
  }

  Future<bool> equipStudicon(int studiconId) async {
    try {
      final response = await _apiClient.post(
        '/user/v2/reload/info',
        data: {'pv': studiconId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }
}
