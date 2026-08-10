import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/group_model.dart';
import '../../data/models/group_member_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/group_repository.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

class GroupDetailScreen extends ConsumerStatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  List<GroupMemberModel> _members = [];
  List<ChatMessageModel> _chatMessages = [];
  bool _isLoadingMembers = true;

  final _chatInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGroupData();

    // Auto refresh active members every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadMembersSilently();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupData() async {
    setState(() => _isLoadingMembers = true);
    await Future.wait([
      _loadMembersSilently(),
      _loadChatSilently(),
    ]);
    if (mounted) setState(() => _isLoadingMembers = false);
  }

  Future<void> _loadMembersSilently() async {
    try {
      final repo = ref.read(groupRepositoryProvider);
      final list = await repo.fetchMembers(widget.group.id);
      if (mounted) {
        setState(() => _members = list);
      }
    } catch (_) {
      // Offline fallback mock list
      if (_members.isEmpty && mounted) {
        setState(() {
          _members = [
            const GroupMemberModel(
              userId: 1,
              name: 'Lucas (Você)',
              studiconId: 377,
              isStudying: true,
              studyMs: 5400000,
              hasCustomAvatar: false,
            ),
            const GroupMemberModel(
              userId: 2,
              name: 'Ana Silva',
              studiconId: 120,
              isStudying: true,
              studyMs: 9000000,
              hasCustomAvatar: false,
            ),
            const GroupMemberModel(
              userId: 3,
              name: 'Carlos M.',
              studiconId: 50,
              isStudying: false,
              studyMs: 3600000,
              hasCustomAvatar: false,
            ),
          ];
        });
      }
    }
  }

  Future<void> _loadChatSilently() async {
    try {
      final repo = ref.read(groupRepositoryProvider);
      final messages = await repo.fetchChatMessages(widget.group.id);
      if (mounted) {
        setState(() => _chatMessages = messages);
      }
    } catch (_) {
      if (_chatMessages.isEmpty && mounted) {
        setState(() {
          _chatMessages = [
            ChatMessageModel(
              id: 1,
              senderId: 2,
              senderName: 'Ana Silva',
              studiconId: 120,
              message: 'Bora focar pessoal! 2h seguidas hoje 🔥',
              sentAt: DateTime.now().subtract(const Duration(minutes: 15)),
            ),
          ];
        });
      }
    }
  }

  Future<void> _shakeUser(GroupMemberModel member) async {
    try {
      final repo = ref.read(groupRepositoryProvider);
      await repo.shakeMember(groupId: widget.group.id, targetUserId: member.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chacoalhada enviada para ${member.name}! 🔔'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificação enviada para ${member.name}!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;

    _chatInputController.clear();
    final newMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 1,
      senderName: 'Você',
      studiconId: 377,
      message: text,
      sentAt: DateTime.now(),
    );

    setState(() {
      _chatMessages = [newMsg, ..._chatMessages];
    });

    try {
      final repo = ref.read(groupRepositoryProvider);
      await repo.sendMessage(groupId: widget.group.id, message: text);
    } catch (_) {}
  }

  String _formatMs(int ms) {
    final mins = ms ~/ 60000;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final studyingMembers = _members.where((m) => m.isStudying).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name, style: AppTextStyles.titleLarge),
            Text(
              '${studyingMembers.length} estudando agora • Meta: ${widget.group.dailyGoalHours}h/dia',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Estudando Agora'),
            Tab(text: 'Chat do Grupo'),
            Tab(text: 'Ranking Semanal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Studying Now Live Grid
          _isLoadingMembers
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: member.isStudying
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : AppColors.border,
                            width: member.isStudying ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: NetworkImage(member.avatarUrl),
                                ),
                                if (member.isStudying)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.card, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.isStudying
                                  ? 'Estudando (${_formatMs(member.studyMs)})'
                                  : 'Pausado',
                              style: TextStyle(
                                fontSize: 12,
                                color: member.isStudying
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                            ),
                            if (!member.isStudying) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _shakeUser(member),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '🔔 Shake',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

          // Tab 2: Group Chat
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  reverse: true,
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _chatMessages[index];
                    final isMe = msg.senderId == 1;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg.senderName,
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              msg.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatInputController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppColors.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tab 3: Rankings
          ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.surface,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(member.name,
                    style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  _formatMs(member.studyMs),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
