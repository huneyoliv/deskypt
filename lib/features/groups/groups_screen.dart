import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/app_translation.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import '../auth/auth_notifier.dart';
import 'group_detail_screen.dart';

final groupRepoProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  List<GroupModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  List<GroupModel> _exploreGroups = [];
  bool _isLoadingExplore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).refreshUserGroups();
    });
    _loadExploreGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExploreGroups() async {
    setState(() {
      _isLoadingExplore = true;
    });

    try {
      final repo = ref.read(groupRepoProvider);
      final results = await repo.fetchExploreGroups();
      if (mounted) {
        setState(() {
          _exploreGroups = results;
          _isLoadingExplore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _exploreGroups = [];
          _isLoadingExplore = false;
        });
      }
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      _loadExploreGroups();
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final repo = ref.read(groupRepoProvider);
      final results = await repo.searchGroups(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildGroupCard(GroupModel group, AppTranslation t, {bool isMyGroup = false}) {
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
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${group.category} • ${group.membersCount}/${group.maxCapacity} ${t.tr("members", fallback: "membros")} • ${t.tr("goal", fallback: "Meta")}: ${group.dailyGoalHours}h/${t.tr("today", fallback: "dia")}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(group: group),
              ),
            );
            if (mounted) {
              ref.read(authStateProvider.notifier).refreshUserGroups();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isMyGroup ? AppColors.surface : AppColors.primary,
            side: isMyGroup ? const BorderSide(color: AppColors.border) : null,
          ),
          child: Text(
            isMyGroup
                ? t.tr('open', fallback: 'Abrir')
                : t.tr('join', fallback: 'Entrar'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myGroups = ref.watch(authStateProvider).user?.userGroups ?? [];
    final t = ref.watch(appTranslationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(t.tr('groups', fallback: 'Grupos de Estudo'), style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.tr('refresh', fallback: 'Atualizar'),
            onPressed: () {
              ref.read(authStateProvider.notifier).refreshUserGroups();
              if (_tabController.index == 1) {
                _performSearch();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: t.tr('my_groups', fallback: 'Meus Grupos')),
            Tab(text: t.tr('explore', fallback: 'Explorar Grupos')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Groups
          myGroups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_off_rounded,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          t.tr('no_groups', fallback: 'Você não participa de nenhum grupo de estudos no momento.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(authStateProvider.notifier).refreshUserGroups();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: myGroups.length,
                    itemBuilder: (context, index) {
                      return _buildGroupCard(myGroups[index], t, isMyGroup: true);
                    },
                  ),
                ),

          // Tab 2: Browse & Search
          RefreshIndicator(
            onRefresh: () async {
              if (_hasSearched) {
                await _performSearch();
              } else {
                await _loadExploreGroups();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: t.tr('search', fallback: 'Buscar grupos por nome ou categoria...'),
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch();
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        child: Text(t.tr('search', fallback: 'Buscar'), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: (_isSearching || _isLoadingExplore)
                        ? const Center(child: CircularProgressIndicator())
                        : _hasSearched
                            ? _searchResults.isEmpty
                                ? Center(
                                    child: Text(
                                      t.tr('no_results', fallback: 'Nenhum grupo encontrado para sua busca.'),
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final isMine = myGroups.any((g) => g.id == _searchResults[index].id);
                                      return _buildGroupCard(_searchResults[index], t, isMyGroup: isMine);
                                    },
                                  )
                            : _exploreGroups.isEmpty
                                ? Center(
                                    child: Text(
                                      t.tr('no_groups_found', fallback: 'Nenhum grupo disponível para explorar no momento.'),
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _exploreGroups.length,
                                    itemBuilder: (context, index) {
                                      final isMine = myGroups.any((g) => g.id == _exploreGroups[index].id);
                                      return _buildGroupCard(_exploreGroups[index], t, isMyGroup: isMine);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
