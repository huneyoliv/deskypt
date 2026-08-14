import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/localization/app_translation.dart';
import '../../data/models/studicon_item_model.dart';
import '../../data/repositories/store_repository.dart';
import '../../shared/widgets/studicon_avatar.dart';
import '../auth/auth_notifier.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository();
});

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StudiconItemModel> _catalogItems = [];
  List<StudiconItemModel> _myStudicons = [];
  String _selectedCategory = 'Todos';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCatalog();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).user;
    final repo = ref.read(storeRepositoryProvider);
    final catalog = await repo.fetchCatalog();
    final myItems = await repo.fetchMyStudicons(user?.studiconId ?? -1);

    if (mounted) {
      setState(() {
        _catalogItems = catalog;
        _myStudicons = myItems;
        _isLoading = false;
      });
    }
  }

  Future<void> _equipItem(StudiconItemModel item) async {
    setState(() {
      _catalogItems = _catalogItems.map((i) {
        if (i.id == item.id) {
          return i.copyWith(isEquipped: true, isOwned: true);
        }
        return i.copyWith(isEquipped: false);
      }).toList();

      _myStudicons = _myStudicons.map((i) {
        if (i.id == item.id) {
          return i.copyWith(isEquipped: true);
        }
        return i.copyWith(isEquipped: false);
      }).toList();
    });

    final repo = ref.read(storeRepositoryProvider);
    await repo.equipStudicon(item.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Studicon "${item.name}" equipado com sucesso! 🎉'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Widget _buildGrid(List<StudiconItemModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum Studicon encontrado nesta categoria.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isEquipped ? AppColors.primary : AppColors.border,
              width: item.isEquipped ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StudiconAvatar(studiconId: item.id, size: 85),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (item.isEquipped)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'EQUIPADO',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _equipItem(item),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Equipar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appTranslationProvider);
    final categories = ['Todos', 'Animais', 'Pessoas', 'Objetos', 'Natureza', 'Outros'];
    final filteredCatalog = _selectedCategory == 'Todos'
        ? _catalogItems
        : _catalogItems.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(t.tr('store', fallback: 'Loja Studicons'), style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: t.tr('refresh', fallback: 'Atualizar'),
            onPressed: _loadCatalog,
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: t.tr('my_studicons', fallback: 'Meus Studicons')),
            Tab(text: t.tr('catalog', fallback: 'Catálogo Geral')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(_myStudicons),
                Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surface,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(child: _buildGrid(filteredCatalog)),
                  ],
                ),
              ],
            ),
    );
  }
}
