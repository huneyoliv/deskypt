import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/repositories/store_repository.dart';

void main() {
  group('StoreRepository Tests', () {
    test('fetchCatalog returns catalog items with URLs', () async {
      final repo = StoreRepository();
      final items = await repo.fetchCatalog();

      expect(items.length, greaterThanOrEqualTo(3));
      expect(items[0].name, contains('Mascot'));
      expect(items[0].previewUrl, equals('https://alicdn.tgclab.com/sc.v2/377/normal1.png'));
    });
  });
}
