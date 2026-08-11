import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/studicon_avatar.dart';
import '../auth/auth_notifier.dart';
import '../timer/timer_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatHours(int ms) {
    final mins = ms ~/ 60000;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  void _showEditNicknameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Alterar Apelido (Nickname)', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Digite seu novo apelido',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final success =
                    await ref.read(authStateProvider.notifier).updateNickname(newName);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Apelido alterado com sucesso!'
                            : 'Falha ao alterar apelido no servidor',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditStatusMsgDialog(BuildContext context, WidgetRef ref, String currentStatus) {
    final controller = TextEditingController(text: currentStatus);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Alterar Mensagem de Status', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Digite sua mensagem de status',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStatus = controller.text.trim();
              final success =
                  await ref.read(authStateProvider.notifier).updateStatusMessage(newStatus);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Mensagem de status alterada!'
                          : 'Falha ao atualizar status no servidor',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final timerState = ref.watch(timerNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil & Configurações', style: AppTextStyles.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Sair da Conta',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: const Text('Sair do DeskYPT', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Tem certeza que deseja encerrar sua sessão?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(authStateProvider.notifier).logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Sair', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  StudiconAvatar(
                    studiconId: user?.studiconId ?? -1,
                    size: 80,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.name ?? 'Estudante YPT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                              tooltip: 'Editar Apelido',
                              onPressed: () => _showEditNicknameDialog(
                                context,
                                ref,
                                user?.name ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user?.statusMessage.isNotEmpty == true
                                    ? '"${user!.statusMessage}"'
                                    : 'Sem mensagem de status',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mode_comment_outlined,
                                  size: 16, color: AppColors.textMuted),
                              tooltip: 'Editar Mensagem de Status',
                              onPressed: () => _showEditStatusMsgDialog(
                                context,
                                ref,
                                user?.statusMessage ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'contato@tgclab.com',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ID: ${user?.id ?? 0}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ActionChip(
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.border),
                              avatar: const Icon(Icons.school, size: 14, color: AppColors.warning),
                              label: Text(
                                user?.categoryName.isNotEmpty == true
                                    ? user!.categoryName
                                    : 'Graduação',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              onPressed: () {
                                final categories = [
                                  {'id': 201, 'name': 'Graduação'},
                                  {'id': 439, 'name': 'Concurso'},
                                  {'id': 260, 'name': 'Vestibular / ENEM'},
                                  {'id': 259, 'name': 'Ensino Médio'},
                                  {'id': 258, 'name': 'Ensino Fundamental'},
                                ];
                                showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                    backgroundColor: AppColors.card,
                                    title: const Text('Selecionar Categoria / Objetivo',
                                        style: TextStyle(color: Colors.white)),
                                    children: categories.map((cat) {
                                      final id = cat['id'] as int;
                                      final name = cat['name'] as String;
                                      return SimpleDialogOption(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          final ok = await ref
                                              .read(authStateProvider.notifier)
                                              .updateCategory(id, name);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  ok
                                                      ? 'Categoria alterada para $name'
                                                      : 'Falha ao atualizar categoria',
                                                ),
                                                backgroundColor:
                                                    ok ? AppColors.success : AppColors.error,
                                              ),
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            name,
                                            style: const TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.timer, color: AppColors.primary, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          _formatHours(timerState.todayTotalMs),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Estudados Hoje',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.book_rounded, color: AppColors.success, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          '${timerState.subjects.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Matérias',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.groups_rounded, color: AppColors.flame, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          '${user?.userGroups.length ?? 0}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Meus Grupos',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Settings Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Configurações & Dispositivo', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.language, color: AppColors.primary),
                    title: Text('Idioma do Aplicativo', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Português (Brasil)',
                        style: TextStyle(color: AppColors.textSecondary)),
                    trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  const ListTile(
                    leading: Icon(Icons.access_time, color: AppColors.primary),
                    title: Text('Fuso Horário Local', style: TextStyle(color: Colors.white)),
                    subtitle: Text('America/Sao_Paulo (GMT-3)',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  const ListTile(
                    leading: Icon(Icons.computer, color: AppColors.primary),
                    title: Text('Plataforma', style: TextStyle(color: Colors.white)),
                    subtitle: Text('DeskYPT Desktop (Windows x64)',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.primary),
                    title: Text('Versão do Cliente API', style: TextStyle(color: Colors.white)),
                    subtitle: Text('v8.1.0 (build 810041)',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
