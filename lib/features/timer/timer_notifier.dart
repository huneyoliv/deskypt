import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/json_utils.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../auth/auth_notifier.dart';

enum TimerMode {
  stopwatch,
  pomodoro,
}

enum PomodoroPhase {
  focus,
  shortBreak,
  longBreak,
}

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

  // Pomodoro properties
  final TimerMode mode;
  final PomodoroPhase pomodoroPhase;
  final int currentPomodoroCycle;
  final int totalPomodoroCycles;
  final int pomodoroFocusMinutes;
  final int pomodoroShortBreakMinutes;
  final int pomodoroLongBreakMinutes;
  final int pomodoroRemainingMs;
  final bool autoStartBreaks;
  final bool autoStartFocus;

  const TimerState({
    this.isRunning = false,
    this.isPaused = false,
    this.sessionElapsedMs = 0,
    this.todayTotalMs = 0,
    this.currentSubject,
    this.subjects = const [],
    this.sessionStartAt,
    this.studiconId = -1,
    this.mode = TimerMode.stopwatch,
    this.pomodoroPhase = PomodoroPhase.focus,
    this.currentPomodoroCycle = 1,
    this.totalPomodoroCycles = 4,
    this.pomodoroFocusMinutes = 25,
    this.pomodoroShortBreakMinutes = 5,
    this.pomodoroLongBreakMinutes = 15,
    this.pomodoroRemainingMs = 25 * 60 * 1000,
    this.autoStartBreaks = false,
    this.autoStartFocus = false,
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
    TimerMode? mode,
    PomodoroPhase? pomodoroPhase,
    int? currentPomodoroCycle,
    int? totalPomodoroCycles,
    int? pomodoroFocusMinutes,
    int? pomodoroShortBreakMinutes,
    int? pomodoroLongBreakMinutes,
    int? pomodoroRemainingMs,
    bool? autoStartBreaks,
    bool? autoStartFocus,
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
      mode: mode ?? this.mode,
      pomodoroPhase: pomodoroPhase ?? this.pomodoroPhase,
      currentPomodoroCycle: currentPomodoroCycle ?? this.currentPomodoroCycle,
      totalPomodoroCycles: totalPomodoroCycles ?? this.totalPomodoroCycles,
      pomodoroFocusMinutes: pomodoroFocusMinutes ?? this.pomodoroFocusMinutes,
      pomodoroShortBreakMinutes: pomodoroShortBreakMinutes ?? this.pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes: pomodoroLongBreakMinutes ?? this.pomodoroLongBreakMinutes,
      pomodoroRemainingMs: pomodoroRemainingMs ?? this.pomodoroRemainingMs,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
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
        const fallbackSubject = SubjectModel(
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
    if (state.isRunning) return;
    state = state.copyWith(currentSubject: subject);
  }

  void setTimerMode(TimerMode mode) {
    if (state.isRunning) return;
    state = state.copyWith(
      mode: mode,
      isPaused: false,
      sessionElapsedMs: 0,
      pomodoroRemainingMs: state.pomodoroFocusMinutes * 60 * 1000,
      pomodoroPhase: PomodoroPhase.focus,
    );
  }

  void configurePomodoro({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? totalCycles,
    bool? autoStartBreaks,
    bool? autoStartFocus,
  }) {
    final newFocus = focusMinutes ?? state.pomodoroFocusMinutes;
    final newShort = shortBreakMinutes ?? state.pomodoroShortBreakMinutes;
    final newLong = longBreakMinutes ?? state.pomodoroLongBreakMinutes;
    final newCycles = totalCycles ?? state.totalPomodoroCycles;
    final newAutoBreaks = autoStartBreaks ?? state.autoStartBreaks;
    final newAutoFocus = autoStartFocus ?? state.autoStartFocus;

    int newRemaining = state.pomodoroRemainingMs;
    if (!state.isRunning) {
      if (state.pomodoroPhase == PomodoroPhase.focus) {
        newRemaining = newFocus * 60 * 1000;
      } else if (state.pomodoroPhase == PomodoroPhase.shortBreak) {
        newRemaining = newShort * 60 * 1000;
      } else {
        newRemaining = newLong * 60 * 1000;
      }
    }

    state = state.copyWith(
      pomodoroFocusMinutes: newFocus,
      pomodoroShortBreakMinutes: newShort,
      pomodoroLongBreakMinutes: newLong,
      totalPomodoroCycles: newCycles,
      autoStartBreaks: newAutoBreaks,
      autoStartFocus: newAutoFocus,
      pomodoroRemainingMs: newRemaining,
    );
  }

  Future<void> startStudy() async {
    if (state.currentSubject == null && state.pomodoroPhase == PomodoroPhase.focus) return;
    final now = DateTime.now();

    if (state.pomodoroPhase == PomodoroPhase.focus && state.currentSubject != null) {
      try {
        await _timerRepository.startStudy(
          subjectTitle: state.currentSubject!.title,
          subjectId: state.currentSubject!.id,
          startAt: now,
        );
      } catch (_) {}
    }

    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      sessionStartAt: state.sessionStartAt ?? now,
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _handleTick();
    });
  }

  void _handleTick() {
    if (state.mode == TimerMode.stopwatch) {
      final newSessionMs = state.sessionElapsedMs + 1000;
      final newTodayMs = state.todayTotalMs + 1000;
      state = state.copyWith(
        sessionElapsedMs: newSessionMs,
        todayTotalMs: newTodayMs,
      );
    } else {
      // Pomodoro Mode
      if (state.pomodoroPhase == PomodoroPhase.focus) {
        final newSessionMs = state.sessionElapsedMs + 1000;
        final newTodayMs = state.todayTotalMs + 1000;
        final newRemaining = state.pomodoroRemainingMs - 1000;

        if (newRemaining <= 0) {
          _advancePomodoroPhase();
        } else {
          state = state.copyWith(
            sessionElapsedMs: newSessionMs,
            todayTotalMs: newTodayMs,
            pomodoroRemainingMs: newRemaining,
          );
        }
      } else {
        // Break phase (no study time added to subject)
        final newRemaining = state.pomodoroRemainingMs - 1000;
        if (newRemaining <= 0) {
          _advancePomodoroPhase();
        } else {
          state = state.copyWith(
            pomodoroRemainingMs: newRemaining,
          );
        }
      }
    }
  }

  Future<void> _advancePomodoroPhase() async {
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      // Save completed focus session
      await _syncCompletedFocusSession();

      if (state.currentPomodoroCycle >= state.totalPomodoroCycles) {
        // Transition to Long Break
        state = state.copyWith(
          pomodoroPhase: PomodoroPhase.longBreak,
          pomodoroRemainingMs: state.pomodoroLongBreakMinutes * 60 * 1000,
          currentPomodoroCycle: 1,
          isRunning: state.autoStartBreaks,
          isPaused: !state.autoStartBreaks,
          sessionElapsedMs: 0,
        );
      } else {
        // Transition to Short Break
        state = state.copyWith(
          pomodoroPhase: PomodoroPhase.shortBreak,
          pomodoroRemainingMs: state.pomodoroShortBreakMinutes * 60 * 1000,
          currentPomodoroCycle: state.currentPomodoroCycle + 1,
          isRunning: state.autoStartBreaks,
          isPaused: !state.autoStartBreaks,
          sessionElapsedMs: 0,
        );
      }

      if (!state.autoStartBreaks) {
        _ticker?.cancel();
      }
    } else {
      // Transition from Break to Focus
      state = state.copyWith(
        pomodoroPhase: PomodoroPhase.focus,
        pomodoroRemainingMs: state.pomodoroFocusMinutes * 60 * 1000,
        isRunning: state.autoStartFocus,
        isPaused: !state.autoStartFocus,
        sessionElapsedMs: 0,
      );

      if (!state.autoStartFocus) {
        _ticker?.cancel();
      }
    }
  }

  Future<void> _syncCompletedFocusSession() async {
    final now = DateTime.now();
    final elapsed = state.sessionElapsedMs;
    final currentSub = state.currentSubject;

    if (currentSub != null && elapsed > 0) {
      try {
        final res = await _timerRepository.stopStudy(
          subjectTitle: currentSub.title,
          subjectId: currentSub.id,
          startAt: state.sessionStartAt ?? now.subtract(Duration(milliseconds: elapsed)),
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
  }

  Future<void> skipPomodoroPhase() async {
    await _advancePomodoroPhase();
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
    await _syncCompletedFocusSession();

    int initialRemaining = state.pomodoroFocusMinutes * 60 * 1000;
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      sessionElapsedMs: 0,
      sessionStartAt: null,
      pomodoroPhase: PomodoroPhase.focus,
      pomodoroRemainingMs: initialRemaining,
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
