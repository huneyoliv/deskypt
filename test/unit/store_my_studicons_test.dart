import 'package:deskypt/core/cdn/cdn_resolver.dart';
import 'package:deskypt/data/repositories/store_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Store and My Studicons Tests', () {
    test('CdnResolver.studiconUrl resolves -1 as default orange doll', () {
      final defaultUrl = CdnResolver.studiconUrl(-1, StudiconPose.normal1);
      final zeroUrl = CdnResolver.studiconUrl(0, StudiconPose.normal1);

      expect(defaultUrl, contains('/sc.v2/-1/normal1.png'));
      expect(zeroUrl, contains('/sc.v2/-1/normal1.png'));
    });

    test('StoreRepository.fetchMyStudicons includes default orange avatar -1', () async {
      final repo = StoreRepository();
      final myItems = await repo.fetchMyStudicons(-1);

      expect(myItems.any((item) => item.id == -1), true);
      final defaultItem = myItems.firstWhere((item) => item.id == -1);
      expect(defaultItem.isEquipped, true);
      expect(defaultItem.name, contains('Padrão'));
    });
  });
}
