import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'timer_notifier.dart';
import 'widgets/timer_display.dart';
import 'widgets/subject_management_dialog.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  String _formatTotalTime(int ms) {
    final totalSecs = ms ~/ 1000;
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final s = totalSecs % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerNotifierProvider);
    final notifier = ref.read(timerNotifierProvider.notifier);

    final currentSubjectColor =
        timerState.currentSubject?.color ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header - Total Today & Currently Selected Subject Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppColors.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Estudado Hoje',
                          style: AppTextStyles.labelSmall),
                      const SizedBox(height: 2),
                      Text(
                        _formatTotalTime(timerState.todayTotalMs),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontPretendard,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      SubjectManagementDialog.show(
                        context,
                        subjects: timerState.subjects,
                        selectedSubject: timerState.currentSubject,
                        onSelectSubject: (subject) => notifier.selectSubject(subject),
                        onCreateSubject: (title, colorInt) => notifier.createSubject(title, colorInt),
                        onUpdateSubject: (subject) => notifier.updateSubject(subject),
                        onArchiveSubject: (id, archive) => notifier.archiveSubject(id, archive),
                        onDeleteSubject: (id) => notifier.deleteSubject(id),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: currentSubjectColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: currentSubjectColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: currentSubjectColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timerState.currentSubject?.title ?? 'Selecionar Matéria',
                            style: TextStyle(
                              color: currentSubjectColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down_rounded, color: currentSubjectColor, size: 18),
                        ],
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
                    TimerDisplay(
                      elapsedMs: timerState.sessionElapsedMs,
                      fontSize: 64,
                    ),
                    const SizedBox(height: 40),

                    // Timer Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!timerState.isRunning && !timerState.isPaused)
                          ElevatedButton.icon(
                            onPressed: () => notifier.startStudy(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentSubjectColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 28),
                            label: Text(
                              'INICIAR (${timerState.currentSubject?.title ?? "Selecione"})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
