import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/models/subject_model.dart';
import 'package:deskypt/data/repositories/subject_repository.dart';
import 'package:deskypt/data/repositories/timer_repository.dart';
import 'package:deskypt/features/timer/timer_notifier.dart';

class FakeTimerRepository extends TimerRepository {
  bool recordRestCalled = false;
  int? lastRestMs;
  DateTime? lastRestStart;
  DateTime? lastRestStop;

  bool startStudyCalled = false;
  bool stopStudyCalled = false;

  @override
  Future<bool> startStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime startAt,
  }) async {
    startStudyCalled = true;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> stopStudy({
    required String subjectTitle,
    required int subjectId,
    required DateTime stopAt,
    required int studyMs,
    required DateTime startAt,
  }) async {
    stopStudyCalled = true;
    return {
      's': true,
      'dl': {'sm': 10000, 'tp': 10000}
    };
  }

  @override
  Future<bool> recordRest({
    required DateTime startAt,
    required DateTime stopAt,
    required int restMs,
    String deviceModel = 'Desktop',
  }) async {
    recordRestCalled = true;
    lastRestStart = startAt;
    lastRestStop = stopAt;
    lastRestMs = restMs;
    return true;
  }
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
        SubjectModel(id: 1, title: 'Matemática', colorInt: 4292557552, studyMs: 5000),
      ],
      todayTotalMs: 5000,
    );
  }
}

void main() {
  group('Timer Break Tracking & Rest Recording Tests', () {
    test('pauseStudy transitions to isPaused and initializes restStartAt', () async {
      final timerRepo = FakeTimerRepository();
      final subjectRepo = FakeSubjectRepository();

      final notifier = TimerNotifier(
        timerRepository: timerRepo,
        subjectRepository: subjectRepo,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await notifier.startStudy();
      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.isPaused, isFalse);

      notifier.pauseStudy();
      expect(notifier.state.isRunning, isFalse);
      expect(notifier.state.isPaused, isTrue);
      expect(notifier.state.restStartAt, isNotNull);
    });

    test('resuming after pause records accumulated rest time via recordRest', () async {
      final timerRepo = FakeTimerRepository();
      final subjectRepo = FakeSubjectRepository();

      final notifier = TimerNotifier(
        timerRepository: timerRepo,
        subjectRepository: subjectRepo,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await notifier.startStudy();
      notifier.pauseStudy();

      notifier.state = notifier.state.copyWith(sessionRestMs: 15000);

      await notifier.startStudy();

      expect(notifier.state.isRunning, isTrue);
      expect(notifier.state.isPaused, isFalse);
      expect(notifier.state.sessionRestMs, equals(0));
      expect(timerRepo.recordRestCalled, isTrue);
      expect(timerRepo.lastRestMs, equals(15000));
    });

    test('stopStudy while paused records rest before concluding session', () async {
      final timerRepo = FakeTimerRepository();
      final subjectRepo = FakeSubjectRepository();

      final notifier = TimerNotifier(
        timerRepository: timerRepo,
        subjectRepository: subjectRepo,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await notifier.startStudy();
      notifier.pauseStudy();

      notifier.state = notifier.state.copyWith(
        sessionElapsedMs: 20000,
        sessionRestMs: 8000,
      );

      await notifier.stopStudy();

      expect(notifier.state.isRunning, isFalse);
      expect(notifier.state.isPaused, isFalse);
      expect(timerRepo.recordRestCalled, isTrue);
      expect(timerRepo.lastRestMs, equals(8000));
      expect(timerRepo.stopStudyCalled, isTrue);
    });
  });
}
