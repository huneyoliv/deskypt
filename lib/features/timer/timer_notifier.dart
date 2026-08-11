import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/json_utils.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../auth/auth_notifier.dart';

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final int sessionElapsedMs;
  final int todayTotalMs;
  final SubjectModel? currentSubject;
  final List<SubjectModel> subjects;
  final DateTime? sessionStartAt;
  final int studiconId;

  const TimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.sessionElapsedMs = 0,
    this.todayTotalMs = 0,
    this.currentSubject,
    this.subjects = const [],
    this.sessionStartAt,
    this.studiconId = -1,
  });

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? sessionElapsedMs,
    int? todayTotalMs,
    SubjectModel? currentSubject,
    List<SubjectModel>? subjects,
    DateTime? sessionStartAt,
    int? studiconId,
  }) {
    return TimerState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      sessionElapsedMs: sessionElapsedMs ?? this.sessionElapsedMs,
      todayTotalMs: todayTotalMs ?? this.todayTotalMs,
      currentSubject: currentSubject ?? this.currentSubject,
      subjects: subjects ?? this.subjects,
      sessionStartAt: sessionStartAt ?? this.sessionStartAt,
      studiconId: studiconId ?? this.studiconId,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  final TimerRepository _timerRepository;
  final SubjectRepository _subjectRepository;
  Timer? _ticker;

  TimerNotifier({
    required TimerRepository timerRepository,
    required SubjectRepository subjectRepository,
    int userStudiconId = 377,
  })  : _timerRepository = timerRepository,
        _subjectRepository = subjectRepository,
        super(TimerState(studiconId: userStudiconId)) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      final result = await _subjectRepository.fetchSubjectsData();
      final subjects = result.subjects;
      final current = subjects.isNotEmpty ? subjects.first : null;

      state = state.copyWith(
        subjects: subjects,
        currentSubject: current,
        todayTotalMs: result.todayTotalMs,
      );
    } catch (_) {
      if (state.subjects.isEmpty) {
        final fallbackSubject = const SubjectModel(
          id: 1,
          title: 'Matéria Inicial',
          colorInt: 4292557552,
        );
        state = state.copyWith(
          subjects: [fallbackSubject],
          currentSubject: fallbackSubject,
        );
      }
    }
  }

  void selectSubject(SubjectModel subject) {
    if (state.isRunning) return; // Não troca de matéria estudando
    state = state.copyWith(currentSubject: subject);
  }

  Future<void> startStudy() async {
    if (state.currentSubject == null) return;
    final now = DateTime.now();

    try {
      await _timerRepository.startStudy(
        subjectTitle: state.currentSubject!.title,
        subjectId: state.currentSubject!.id,
        startAt: now,
      );
    } catch (_) {}

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      sessionStartAt: now,
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newSessionMs = state.sessionElapsedMs + 1000;
      final newTodayMs = state.todayTotalMs + 1000;
      state = state.copyWith(
        sessionElapsedMs: newSessionMs,
        todayTotalMs: newTodayMs,
      );
    });
  }

  void pauseStudy() {
    _ticker?.cancel();
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
    );
  }

  Future<void> stopStudy() async {
    _ticker?.cancel();
    final now = DateTime.now();
    final elapsed = state.sessionElapsedMs;
    final currentSub = state.currentSubject;

    if (currentSub != null && elapsed > 0) {
      try {
        final res = await _timerRepository.stopStudy(
          subjectTitle: currentSub.title,
          subjectId: currentSub.id,
          startAt: state.sessionStartAt ?? now,
          stopAt: now,
          studyMs: elapsed,
        );

        if (res != null) {
          final dl = res['dl'] as Map<String, dynamic>?;
          final serverTotalMs = safeInt(dl?['sm'] ?? dl?['tp']);
          final updatedSubjects = state.subjects.map((s) {
            if (s.id == currentSub.id) {
              return s.copyWith(studyMs: s.studyMs + elapsed);
            }
            return s;
          }).toList();

          state = state.copyWith(
            subjects: updatedSubjects,
            todayTotalMs: serverTotalMs > 0 ? serverTotalMs : state.todayTotalMs,
            currentSubject: currentSub.copyWith(studyMs: currentSub.studyMs + elapsed),
          );
        }
      } catch (_) {}
    }

    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionElapsedMs: 0,
      sessionStartAt: null,
    );
  }

  Future<void> createSubject(String title, int colorInt) async {
    try {
      final newSubject = await _subjectRepository.createSubject(
        title: title,
        colorInt: colorInt,
        order: (state.subjects.length + 1) * 100,
      );
      final updatedList = [...state.subjects, newSubject];
      state = state.copyWith(
        subjects: updatedList,
        currentSubject: newSubject,
      );
    } catch (_) {
      // Fallback local se a API der erro
      final newSubject = SubjectModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        colorInt: colorInt,
      );
      final updatedList = [...state.subjects, newSubject];
      state = state.copyWith(
        subjects: updatedList,
        currentSubject: newSubject,
      );
    }
  }

  Future<void> deleteSubject(int subjectId) async {
    final updatedList = state.subjects.where((s) => s.id != subjectId).toList();
    final newCurrent = updatedList.isNotEmpty ? updatedList.first : null;

    state = state.copyWith(
      subjects: updatedList,
      currentSubject: state.currentSubject?.id == subjectId ? newCurrent : state.currentSubject,
    );

    try {
      await _subjectRepository.deleteSubject(subjectId);
    } catch (_) {}
  }

  Future<void> updateSubject(SubjectModel subject) async {
    final updatedList = state.subjects.map((s) => s.id == subject.id ? subject : s).toList();
    final newCurrent = state.currentSubject?.id == subject.id ? subject : state.currentSubject;

    state = state.copyWith(
      subjects: updatedList,
      currentSubject: newCurrent,
    );

    try {
      await _subjectRepository.updateSubject(subject);
    } catch (_) {}
  }

  Future<void> archiveSubject(int subjectId, bool isArchived) async {
    final updatedList = state.subjects.map((s) {
      if (s.id == subjectId) {
        return s.copyWith(isArchived: isArchived);
      }
      return s;
    }).toList();

    final activeList = updatedList.where((s) => !s.isArchived).toList();
    final newCurrent = (state.currentSubject?.id == subjectId && isArchived)
        ? (activeList.isNotEmpty ? activeList.first : null)
        : (state.currentSubject ?? (activeList.isNotEmpty ? activeList.first : null));

    state = state.copyWith(
      subjects: updatedList,
      currentSubject: newCurrent,
    );

    try {
      await _subjectRepository.archiveSubject(subjectId, isArchived);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerNotifierProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final timerRepo = ref.watch(timerRepositoryProvider);
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final user = ref.watch(authStateProvider).user;

  return TimerNotifier(
    timerRepository: timerRepo,
    subjectRepository: subjectRepo,
    userStudiconId: user?.studiconId ?? 0,
  );
});
