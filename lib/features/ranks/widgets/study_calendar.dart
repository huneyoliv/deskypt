import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StudyCalendar extends StatelessWidget {
  final Map<String, int> dailyStudyTimeMs; // Key: 'yyyy-MM-dd', Value: ms

  const StudyCalendar({
    super.key,
    required this.dailyStudyTimeMs,
  });

  Color _getDayColor(int ms) {
    if (ms <= 0) return AppColors.card;
    final hours = ms / 3600000;
    if (hours < 2) return const Color(0xFF0E4429);
    if (hours < 4) return const Color(0xFF006D32);
    if (hours < 7) return const Color(0xFF26A641);
    return const Color(0xFF39D353);
  }

  String _formatMs(int ms) {
    final mins = ms ~/ 60000;
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayWeekday = DateTime(now.year, now.month, 1).weekday; // 1=Mon...7=Sun

    final dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Calendário de Presença — ${now.month}/${now.year}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekday Header
        Row(
          children: dayLabels.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: (firstDayWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstDayWeekday - 1) {
              return const SizedBox.shrink();
            }

            final dayNum = index - (firstDayWeekday - 1) + 1;
            final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
            final studyMs = dailyStudyTimeMs[dateStr] ?? 0;
            final color = _getDayColor(studyMs);

            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: Text('Estudos em $dateStr', style: const TextStyle(color: Colors.white)),
                    content: Text(
                      studyMs > 0
                          ? 'Tempo total estudado: ${_formatMs(studyMs)}'
                          : 'Nenhum estudo registrado neste dia.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: dayNum == now.day ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayNum',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: dayNum == now.day ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    if (studyMs > 0)
                      Text(
                        _formatMs(studyMs),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
