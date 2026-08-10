import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/group_model.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<GroupModel> _myGroups = [
    const GroupModel(
      id: 6487271,
      name: 'Foco Total 2026 🎯',
      category: 'Concursos',
      dailyGoalHours: 8,
      membersCount: 18,
      maxCapacity: 50,
      isPrivate: false,
      leaderName: 'Longkun',
      notice: 'Proibido ficar mais de 2 dias sem registrar estudo!',
    ),
    const GroupModel(
      id: 6487272,
      name: 'Devs & Programação 💻',
      category: 'Tecnologia',
      dailyGoalHours: 6,
      membersCount: 32,
      maxCapacity: 50,
      isPrivate: false,
      leaderName: 'Ana Silva',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grupos de Estudo', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Meus Grupos'),
            Tab(text: 'Explorar Grupos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Groups
          ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _myGroups.length,
            itemBuilder: (context, index) {
              final group = _myGroups[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: AppColors.card,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group_work, color: AppColors.primary),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Categoria: ${group.category} • ${group.membersCount}/${group.maxCapacity} membros • Meta: ${group.dailyGoalHours}h/dia',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupDetailScreen(group: group),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Entrar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          ),

          // Tab 2: Browse
          const Center(
            child: Text(
              'Buscar Novos Grupos',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
