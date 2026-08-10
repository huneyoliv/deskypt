import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    this.studiconId = 377,
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
      final subjects = await _subjectRepository.fetchSubjects();
      final current = subjects.isNotEmpty ? subjects.first : null;
      final total = subjects.fold<int>(0, (sum, s) => sum + s.studyMs);

      state = state.copyWith(
        subjects: subjects,
        currentSubject: current,
        todayTotalMs: total,
      );
    } catch (_) {
      // Usar subjects padrão de fallback em ambiente offline
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

    if (state.currentSubject != null && state.sessionElapsedMs > 0) {
      try {
        await _timerRepository.stopStudy(
          subjectId: state.currentSubject!.id,
          stopAt: now,
          studyMs: state.sessionElapsedMs,
        );
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
    userStudiconId: user?.studiconId ?? 377,
  );
});
