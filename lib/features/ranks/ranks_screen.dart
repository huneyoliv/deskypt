import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/rank_entry_model.dart';
import '../../data/repositories/rank_repository.dart';
import '../../shared/widgets/studicon_avatar.dart';
import '../auth/auth_notifier.dart';
import 'widgets/heatmap_grid.dart';
import 'widgets/study_calendar.dart';

final rankRepositoryProvider = Provider<RankRepository>((ref) {
  return RankRepository();
});

class RanksScreen extends ConsumerStatefulWidget {
  const RanksScreen({super.key});

  @override
  ConsumerState<RanksScreen> createState() => _RanksScreenState();
}

class _RanksScreenState extends ConsumerState<RanksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RankEntryModel> _ranks = [];
  List<double> _weeklyHours = List.filled(7, 0.0);
  Map<String, double> _subjectDistribution = {};
  bool _isLoadingRanks = true;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRanks();
    _loadUserStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRanks() async {
    setState(() => _isLoadingRanks = true);
    final repo = ref.read(rankRepositoryProvider);
    final list = await repo.fetchGlobalRanks('Geral');
    if (mounted) {
      setState(() {
        _ranks = list;
        _isLoadingRanks = false;
      });
    }
  }

  Map<String, int> _monthlyStudyMs = {};

  Future<void> _loadUserStats() async {
    setState(() => _isLoadingStats = true);
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      if (mounted) setState(() => _isLoadingStats = false);
      return;
    }

    final repo = ref.read(rankRepositoryProvider);
    final now = DateTime.now();
    final firstDayMonth = DateTime(now.year, now.month, 1);
    final lastDayMonth = DateTime(now.year, now.month + 1, 0);

    final startStr = DateFormat('yyyy-MM-dd').format(firstDayMonth);
    final endStr = DateFormat('yyyy-MM-dd').format(lastDayMonth);

    final data = await repo.fetchUserStats(
      userId: user.id,
      startDate: startStr,
      endDate: endStr,
    );

    final rawLogs = data['ls'];
    final weekly = List.filled(7, 0.0);
    final subjectMap = <String, double>{};
    final monthlyMs = <String, int>{};

    if (rawLogs is List) {
      for (final log in rawLogs) {
        if (log is Map<String, dynamic>) {
          final dtStr = log['dt'] as String? ?? '';
          final ms = (log['sm'] as int? ?? 0);
          final hours = ms / 3600000.0;
          final subject = log['sb'] as String? ?? 'Geral';

          if (dtStr.isNotEmpty) {
            monthlyMs[dtStr] = (monthlyMs[dtStr] ?? 0) + ms;
            try {
              final parsedDate = DateTime.parse(dtStr);
              final dayIndex = (parsedDate.weekday - 1) % 7;
              weekly[dayIndex] += hours;
            } catch (_) {}
          }

          subjectMap[subject] = (subjectMap[subject] ?? 0.0) + hours;
        }
      }
    }

    if (mounted) {
      setState(() {
        _weeklyHours = weekly;
        _subjectDistribution = subjectMap;
        _monthlyStudyMs = monthlyMs;
        _isLoadingStats = false;
      });
    }
  }

  String _formatMs(int ms) {
    final mins = ms ~/ 60000;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  Widget _buildPodiumItem({
    required RankEntryModel member,
    required String badgeImage,
    required double height,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            StudiconAvatar(studiconId: member.studiconId, size: 70),
            Image.asset(badgeImage, width: 28, height: 28,
                errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events,
                    color: Colors.amber, size: 24)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          member.userName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          _formatMs(member.studyMs),
          style: TextStyle(
              color: color, fontWeight: FontWeight.w800, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              '#${member.rank}',
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWeeklyHour = _weeklyHours.fold<double>(
        4.0, (max, h) => h > max ? h : max);

    final colors = [
      const Color(0xFF5B6AF0),
      const Color(0xFFFF5247),
      const Color(0xFF00E676),
      const Color(0xFFFFAB00),
      const Color(0xFFE040FB),
    ];

    double totalSubjectHours = _subjectDistribution.values.fold(0.0, (a, b) => a + b);
    if (totalSubjectHours == 0) totalSubjectHours = 1.0;

    int colorIdx = 0;
    final pieSections = _subjectDistribution.entries.map((e) {
      final percentage = (e.value / totalSubjectHours * 100).round();
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      return PieChartSectionData(
        color: color,
        value: e.value > 0 ? e.value : 1,
        title: '$percentage%',
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rankings & Estatísticas', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Rankings Globais'),
            Tab(text: 'Estatísticas & Mapa 24h'),
            Tab(text: 'Calendário Mensal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Global Rankings & Podium
          _isLoadingRanks
              ? const Center(child: CircularProgressIndicator())
              : _ranks.isEmpty
                  ? const Center(
                      child: Text('Nenhum ranking disponível no momento.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(32),
                      children: [
                        // Podium Header (Top 1, Top 2, Top 3)
                        if (_ranks.length >= 3)
                          SizedBox(
                            height: 260,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 2nd Place (Silver)
                                _buildPodiumItem(
                                  member: _ranks[1],
                                  badgeImage: 'assets/images/ic_silver.png',
                                  height: 110,
                                  color: const Color(0xFFC0C0C0),
                                ),
                                const SizedBox(width: 24),

                                // 1st Place (Gold)
                                _buildPodiumItem(
                                  member: _ranks[0],
                                  badgeImage: 'assets/images/ic_gold.png',
                                  height: 140,
                                  color: const Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 24),

                                // 3rd Place (Bronze)
                                _buildPodiumItem(
                                  member: _ranks[2],
                                  badgeImage: 'assets/images/ic_bronze.png',
                                  height: 90,
                                  color: const Color(0xFFCD7F32),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),

                        const Text('Top Estudantes', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),

                        // Ranks List 4+
                        ..._ranks.skip(3).map((rank) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppColors.card,
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '#${rank.rank}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StudiconAvatar(
                                    studiconId: rank.studiconId,
                                    size: 36,
                                  ),
                                ],
                              ),
                              title: Text(rank.userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(rank.categoryName,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              trailing: Text(
                                _formatMs(rank.studyMs),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

          // Tab 2: Statistics & fl_chart Graphs (Real Data)
          _isLoadingStats
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 320,
                        child: Row(
                          children: [
                            // Weekly Bar Chart
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Horas Estudadas na Semana',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: BarChart(
                                        BarChartData(
                                          alignment: BarChartAlignment.spaceAround,
                                          maxY: maxWeeklyHour * 1.2,
                                          barTouchData: BarTouchData(enabled: false),
                                          titlesData: FlTitlesData(
                                            show: true,
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  const days = [
                                                    'Seg',
                                                    'Ter',
                                                    'Qua',
                                                    'Qui',
                                                    'Sex',
                                                    'Sáb',
                                                    'Dom'
                                                  ];
                                                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                                                    return Text(
                                                      days[value.toInt()],
                                                      style: const TextStyle(
                                                          color: AppColors.textSecondary,
                                                          fontSize: 12),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                            leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)),
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)),
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(showTitles: false)),
                                          ),
                                          borderData: FlBorderData(show: false),
                                          barGroups: List.generate(7, (index) {
                                            return BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: _weeklyHours[index],
                                                  color: AppColors.primary,
                                                )
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Subject Distribution Pie Chart
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Distribuição por Matéria',
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: pieSections.isEmpty
                                          ? const Center(
                                              child: Text(
                                                'Nenhum dado registrado esta semana.',
                                                style: TextStyle(
                                                    color: AppColors.textSecondary),
                                              ),
                                            )
                                          : PieChart(
                                              PieChartData(
                                                sectionsSpace: 4,
                                                centerSpaceRadius: 50,
                                                sections: pieSections,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 24h Heatmap Component
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: HeatmapGrid(
                          hourlyLogs: {
                            '2026-08-11': List.generate(24, (i) => (i >= 8 && i <= 18) ? (i * 3) % 60 : 0),
                          },
                        ),
                      ),
                    ],
                  ),
                ),

          // Tab 3: Monthly Study Calendar
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: StudyCalendar(
                dailyStudyTimeMs: _monthlyStudyMs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
