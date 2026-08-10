import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/cdn/cdn_resolver.dart';
import '../../shared/widgets/studicon_avatar.dart';
import 'timer_notifier.dart';
import 'widgets/progress_ring_painter.dart';
import 'widgets/timer_display.dart';
import 'widgets/subject_selector.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  StudiconPose _getStudiconPose(TimerState state) {
    if (state.isPaused) return StudiconPose.smoke1;
    if (!state.isRunning) return StudiconPose.normal1;
    if (state.sessionElapsedMs > 7200000) return StudiconPose.ignite1;
    return StudiconPose.sweat1;
  }

  String _formatTotalTime(int ms) {
    final totalSecs = ms ~/ 1000;
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    final currentSubjectColor =
        timerState.currentSubject?.color ?? AppColors.primary;
    const targetMs = 28800000; // Meta diária de 8 horas em milissegundos
    final progress = timerState.todayTotalMs / targetMs;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar - Total Study Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total de Hoje',
                        style: AppTextStyles.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTotalTime(timerState.todayTotalMs),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontPretendard,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (timerState.currentSubject != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: currentSubjectColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: currentSubjectColor),
                      ),
                      child: Text(
                        timerState.currentSubject!.title,
                        style: TextStyle(
                          color: currentSubjectColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Center Interactive Ring & Timer Area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 320,
                      height: 320,
                      child: CustomPaint(
                        painter: ProgressRingPainter(
                          progress: progress,
                          activeColor: currentSubjectColor,
                          backgroundColor: AppColors.surface,
                          strokeWidth: 16,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Studicon Character
                              StudiconAvatar(
                                studiconId: timerState.studiconId,
                                pose: _getStudiconPose(timerState),
                                size: 100,
                              ),
                              const SizedBox(height: 12),

                              // Timer Digits
                              TimerDisplay(
                                elapsedMs: timerState.sessionElapsedMs,
                                fontSize: 44,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Controls: Play / Pause / Stop Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!timerState.isRunning && !timerState.isPaused)
                          ElevatedButton.icon(
                            onPressed: () => notifier.startStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentSubjectColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 36, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 28),
                            label: const Text(
                              'INICIAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),

                        if (timerState.isRunning) ...[
                          ElevatedButton.icon(
                            onPressed: () => notifier.pauseStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.resting,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.pause_rounded,
                                color: Colors.white, size: 24),
                            label: const Text('PAUSAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => notifier.stopStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.stop_rounded,
                                color: Colors.white, size: 24),
                            label: const Text('PARAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],

                        if (timerState.isPaused) ...[
                          ElevatedButton.icon(
                            onPressed: () => notifier.startStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentSubjectColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 24),
                            label: const Text('RETOMAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => notifier.stopStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.stop_rounded,
                                color: Colors.white, size: 24),
                            label: const Text('PARAR',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Subject Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SubjectSelector(
                subjects: timerState.subjects,
                selectedSubject: timerState.currentSubject,
                onSelectSubject: (subject) => notifier.selectSubject(subject),
                onCreateSubject: (title, colorInt) =>
                    notifier.createSubject(title, colorInt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
