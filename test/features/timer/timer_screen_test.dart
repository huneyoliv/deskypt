import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/localization/app_translation.dart';
import 'package:deskypt/data/models/subject_model.dart';
import 'package:deskypt/data/repositories/subject_repository.dart';
import 'package:deskypt/data/repositories/timer_repository.dart';
import 'package:deskypt/features/timer/timer_notifier.dart';
import 'package:deskypt/features/timer/timer_screen.dart';

class FakeTimerRepository extends TimerRepository {
  @override
  Future<bool> startStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime startAt,
  }) async => true;

  @override
  Future<Map<String, dynamic>?> stopStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime stopAt,
    required int studyMs,
    required DateTime startAt,
  }) async => {'s': true};
}

class FakeSubjectRepository extends SubjectRepository {
  @override
  Future<SubjectFetchResult> fetchSubjectsData({
    String? language,
    String? timezone,
    int? version,
  }) async {
    return const SubjectFetchResult(
      subjects: [
        SubjectModel(id: 1, title: 'Biologia', colorInt: 4292557552),
      ],
      todayTotalMs: 3600000,
    );
  }
}

void main() {
  testWidgets('TimerScreen renders study and rest headers and progress ring', (tester) async {
    final timerRepo = FakeTimerRepository();
    final subjectRepo = FakeSubjectRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerRepositoryProvider.overrideWithValue(timerRepo),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          appTranslationProvider.overrideWith(
            (ref) => AppTranslationNotifier(ref)..state = const AppTranslation(languageCode: 'pt'),
          ),
        ],
        child: const MaterialApp(
          home: TimerScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tempo Total de Hoje'), findsOneWidget);
    expect(find.text('Tempo de Descanso'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
