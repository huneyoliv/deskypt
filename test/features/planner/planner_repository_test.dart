import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/models/dday_model.dart';
import 'package:deskypt/data/repositories/planner_repository.dart';

void main() {
  group('PlannerRepository & DDayModel Tests', () {
    test('DDayModel calculates daysRemaining and label correctly', () {
      final targetFuture = DateTime.now().add(const Duration(days: 10));
      final dday = DDayModel(
        id: 1,
        title: 'Prova',
        targetDate: targetFuture,
        colorInt: 4294948685,
      );

      expect(dday.daysRemaining, equals(10));
      expect(dday.label, equals('D-10'));
    });

    test('PlannerRepository returns ddays and fallback list', () async {
      final repo = PlannerRepository();
      final ddays = await repo.fetchDDays();

      expect(ddays.isNotEmpty, isTrue);
      expect(ddays.first.title, contains('Exame'));
    });
  });
}
