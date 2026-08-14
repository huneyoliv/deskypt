import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_admin_repository.dart';

final groupAdminRepoProvider = Provider<GroupAdminRepository>((ref) {
  return GroupAdminRepository();
});

class GroupLeaderPanel extends ConsumerStatefulWidget {
  final GroupModel group;
  final List<GroupMemberModel> members;

  const GroupLeaderPanel({
    super.key,
    required this.group,
    required this.members,
  });

  @override
  ConsumerState<GroupLeaderPanel> createState() => _GroupLeaderPanelState();
}

class _GroupLeaderPanelState extends ConsumerState<GroupLeaderPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _noticeController;
  late TextEditingController _passwordController;
  late int _capacity;
  late int _goalHours;
  bool _chatEnabled = true;

  List<Map<String, dynamic>> _bannedList = [];
  List<Map<String, dynamic>> _joinRequests = [];
  bool _isLoadingBanned = false;
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _nameController = TextEditingController(text: widget.group.name);
    _noticeController = TextEditingController();
    _passwordController = TextEditingController();
    _capacity = widget.group.maxCapacity;
    _goalHours = widget.group.dailyGoalHours;
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _noticeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoadingBanned = true;
      _isLoadingRequests = true;
    });

    final repo = ref.read(groupAdminRepoProvider);
    final results = await Future.wait([
      repo.fetchBannedList(widget.group.id),
      repo.fetchJoinRequests(widget.group.id),
    ]);

    if (mounted) {
      setState(() {
        _bannedList = results[0];
        _joinRequests = results[1];
        _isLoadingBanned = false;
        _isLoadingRequests = false;
      });
    }
  }

  Future<void> _updateSettings() async {
    final repo = ref.read(groupAdminRepoProvider);
    final newName = _nameController.text.trim();
    final newNotice = _noticeController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (newName.isNotEmpty && newName != widget.group.name) {
      await repo.updateGroupName(widget.group.id, newName);
    }
    if (_capacity != widget.group.maxCapacity) {
      await repo.updateGroupCapacity(widget.group.id, _capacity);
    }
    if (_goalHours != widget.group.dailyGoalHours) {
      await repo.updateGroupGoal(widget.group.id, _goalHours);
    }
    if (newNotice.isNotEmpty) {
      await repo.updateNotice(widget.group.id, newNotice);
    }
    if (newPassword.isNotEmpty) {
      await repo.updateGroupPassword(widget.group.id, newPassword);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações atualizadas com sucesso!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _promoteGroup() async {
    final repo = ref.read(groupAdminRepoProvider);
    final success = await repo.promoteGroup(widget.group.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Grupo promovido ao topo da busca! 🚀'
                : 'Promoção disponível apenas após 1 hora da última promoção.',
          ),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );
    }
  }

  Future<void> _warnMember(GroupMemberModel member) async {
    final repo = ref.read(groupAdminRepoProvider);
    await repo.warnMember(widget.group.id, member.userId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cartão de advertência emitido para ${member.name}.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _kickMember(GroupMemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Remover Membro', style: TextStyle(color: Colors.white)),
        content: Text('Remover ${member.name} do grupo?', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(groupAdminRepoProvider);
      await repo.kickMember(widget.group.id, member.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.name} foi removido do grupo.')),
        );
      }
    }
  }

  Future<void> _banMember(GroupMemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Banir Membro', style: TextStyle(color: Colors.white)),
        content: Text('Banir ${member.name} do grupo? O usuário entrará na lista negra.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Banir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(groupAdminRepoProvider);
      await repo.banMember(widget.group.id, member.userId);
      _loadAdminData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.name} foi banido.')),
        );
      }
    }
  }

  Future<void> _disbandGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Dissolver Grupo', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja dissolver o grupo "${widget.group.name}"? Esta ação é irreversível.',
          style: const TextStyle(color: AppColors.error),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Dissolver Permanentemente', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(groupAdminRepoProvider);
      await repo.disbandGroup(widget.group.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O grupo foi dissolvido.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Menu do Líder — ${widget.group.name}', style: AppTextStyles.titleLarge),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Informações'),
            Tab(text: 'Membros'),
            Tab(text: 'Solicitações'),
            Tab(text: 'Lista Negra'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Group Settings & Controls
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Configurações Gerais', style: AppTextStyles.titleLarge),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                      label: const Text('Promover Grupo', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _promoteGroup,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome do Grupo',
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                ),
                const SizedBox(height: 16),

                // Notice
                TextField(
                  controller: _noticeController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Aviso do Grupo (Notice Board)',
                    hintText: 'Escreva regras e avisos do grupo...',
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                ),
                const SizedBox(height: 16),

                // Capacity & Goal
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _capacity,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Capacidade de Membros', filled: true, fillColor: AppColors.card),
                        items: [5, 10, 20, 30, 50].map((c) => DropdownMenuItem(value: c, child: Text('$c membros'))).toList(),
                        onChanged: (val) { if (val != null) setState(() => _capacity = val); },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _goalHours,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Meta Diária (Horas)', filled: true, fillColor: AppColors.card),
                        items: [2, 4, 6, 8, 10, 12].map((g) => DropdownMenuItem(value: g, child: Text('$g horas/dia'))).toList(),
                        onChanged: (val) { if (val != null) setState(() => _goalHours = val); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Senha de Acesso (opcional - deixe em branco para público)',
                    filled: true,
                    fillColor: AppColors.card,
                  ),
                ),
                const SizedBox(height: 24),

                // Chat Permissions
                const Text('Configurações de Chat', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Habilitar Chat do Grupo', style: TextStyle(color: Colors.white)),
                  value: _chatEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _chatEnabled = val),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _updateSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Salvar Alterações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),

                const Divider(height: 48, color: AppColors.border),

                // Danger Zone
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Dissolver Grupo Permanentemente', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _disbandGroup,
                ),
              ],
            ),
          ),

          // Tab 2: Manage Members
          ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              final member = widget.members[index];
              return Card(
                color: AppColors.card,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(member.isStudying ? 'Estudando' : 'Inativo', style: TextStyle(color: member.isStudying ? AppColors.success : AppColors.textMuted)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        tooltip: 'Advertir',
                        onPressed: () => _warnMember(member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_remove_outlined, color: Colors.orange),
                        tooltip: 'Remover',
                        onPressed: () => _kickMember(member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.block, color: AppColors.error),
                        tooltip: 'Banir',
                        onPressed: () => _banMember(member),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab 3: Join Requests
          _isLoadingRequests
              ? const Center(child: CircularProgressIndicator())
              : _joinRequests.isEmpty
                  ? const Center(child: Text('Nenhuma solicitação de entrada pendente.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _joinRequests.length,
                      itemBuilder: (context, index) {
                        final req = _joinRequests[index];
                        final reqId = req['id'] as int? ?? 0;
                        final name = req['name']?.toString() ?? 'Usuário';

                        return Card(
                          color: AppColors.card,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final repo = ref.read(groupAdminRepoProvider);
                                    await repo.approveRequest(widget.group.id, reqId);
                                    _loadAdminData();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  child: const Text('Aprovar', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final repo = ref.read(groupAdminRepoProvider);
                                    await repo.rejectRequest(widget.group.id, reqId);
                                    _loadAdminData();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  child: const Text('Rejeitar', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

          // Tab 4: Banned Users (Blacklist)
          _isLoadingBanned
              ? const Center(child: CircularProgressIndicator())
              : _bannedList.isEmpty
                  ? const Center(child: Text('Nenhum usuário na lista negra.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _bannedList.length,
                      itemBuilder: (context, index) {
                        final banned = _bannedList[index];
                        final uId = banned['id'] as int? ?? 0;
                        final name = banned['name']?.toString() ?? 'Usuário Banido';

                        return Card(
                          color: AppColors.card,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final repo = ref.read(groupAdminRepoProvider);
                                await repo.unbanMember(widget.group.id, uId);
                                _loadAdminData();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Desbanir', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
