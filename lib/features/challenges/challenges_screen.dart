import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/challenge_model.dart';
import '../../data/repositories/challenge_repository.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChallengeModel> _available = [];
  List<ChallengeModel> _myChallenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    final repo = ref.read(challengeRepositoryProvider);

    final results = await Future.wait([
      repo.fetchAvailableChallenges(),
      repo.fetchMyChallenges(),
    ]);

    if (mounted) {
      setState(() {
        _available = results[0];
        _myChallenges = results[1];
        _isLoading = false;
      });
    }
  }

  Future<void> _joinChallenge(ChallengeModel challenge) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Participar: ${challenge.name}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Text('Aposta de Entrada: 🔥 ${challenge.flameCost} Flames', style: const TextStyle(color: AppColors.flame, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Text('Regras de Sucesso: ${challenge.rules}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirmar Aposta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(challengeRepositoryProvider);
      final success = await repo.joinChallenge(challenge.id, challenge.flameCost);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Inscrição confirmada! Boa sorte no Desafio! 🚀'
                  : 'Falha ao inscrever no desafio. Verifique seu saldo de Flames.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
          ),
        );
        if (success) _loadChallenges();
      }
    }
  }

  Future<void> _doCheckIn(ChallengeModel challenge) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in do dia registrado com sucesso! Meta de hoje cumprida. 🔥'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildChallengeGrid(List<ChallengeModel> list, {bool isMyList = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              isMyList ? 'Você ainda não entrou em nenhum desafio.' : 'Nenhum desafio disponível no momento.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        childAspectRatio: 0.9,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final challenge = list[index];
        final df = DateFormat('dd/MM');
        final progress = (challenge.checkInCount / 7.0).clamp(0.0, 1.0);

        return Card(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: challenge.isJoined ? AppColors.primary : AppColors.border,
              width: challenge.isJoined ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.flame.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aposta: 🔥 ${challenge.flameCost} Flames',
                        style: const TextStyle(
                          color: AppColors.flame,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Meta: ${(challenge.successThreshold * 100).toInt()}%',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  challenge.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),

                if (isMyList || challenge.isJoined) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progresso de Check-in', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${df.format(challenge.startDate)} a ${df.format(challenge.endDate)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const Spacer(),
                    const Icon(Icons.people_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.participantCount} inscritos',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: challenge.isJoined
                      ? ElevatedButton.icon(
                          onPressed: () => _doCheckIn(challenge),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                          icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                          label: const Text('Fazer Check-in Hoje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      : ElevatedButton(
                          onPressed: () => _joinChallenge(challenge),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Participar do Desafio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Desafios & Metas Yeolpumta', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Desafios Disponíveis'),
            Tab(text: 'Meus Desafios'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildChallengeGrid(_available),
                _buildChallengeGrid(_myChallenges, isMyList: true),
              ],
            ),
    );
  }
}
