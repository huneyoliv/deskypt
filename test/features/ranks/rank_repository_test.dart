import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/repositories/rank_repository.dart';

void main() {
  group('RankRepository Tests', () {
    test('fetchGlobalRanks returns top ranked users', () async {
      final repo = RankRepository();
      final ranks = await repo.fetchGlobalRanks('Concursos');

      expect(ranks.length, greaterThanOrEqualTo(3));
      expect(ranks[0].rank, equals(1));
      expect(ranks[0].userName, equals('Matheus K.'));
      expect(ranks[0].studyMs, equals(43200000));
    });
  });
}
