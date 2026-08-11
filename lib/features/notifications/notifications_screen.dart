import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../shared/widgets/notifications_panel.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationModel> _allNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final repo = ref.read(notificationRepositoryProvider);
    final list = await repo.fetchNotifications();
    if (mounted) {
      setState(() {
        _allNotifications = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(NotificationModel notice) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(notice.id);
    _loadNotifications();
  }

  Widget _buildList(List<NotificationModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'Nenhuma notificação nesta categoria.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notice = list[index];
        final df = DateFormat('dd/MM/yyyy HH:mm');

        return Card(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: notice.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.5),
              width: notice.isRead ? 1 : 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: notice.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.2),
              child: Icon(
                notice.type == 'shake'
                    ? Icons.vibration
                    : notice.type == 'warning'
                        ? Icons.warning_amber_rounded
                        : Icons.notifications,
                color: notice.type == 'warning' ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              notice.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: notice.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notice.message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Text(df.format(notice.createdAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
            trailing: notice.isRead
                ? null
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                    tooltip: 'Marcar como lida',
                    onPressed: () => _markRead(notice),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _allNotifications.where((n) => !n.isRead).toList();
    final groupNotices = _allNotifications.where((n) => n.type == 'shake' || n.type == 'warning').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Central de Notificações', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'Todas (${_allNotifications.length})'),
            Tab(text: 'Não Lidas (${unread.length})'),
            Tab(text: 'Grupos (${groupNotices.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_allNotifications),
                _buildList(unread),
                _buildList(groupNotices),
              ],
            ),
    );
  }
}
