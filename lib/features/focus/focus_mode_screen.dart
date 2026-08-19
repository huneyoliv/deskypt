import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_translation.dart';
import 'focus_mode_notifier.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> {
  final TextEditingController _customAppController = TextEditingController();

  @override
  void dispose() {
    _customAppController.dispose();
    super.dispose();
  }

  Future<void> _pickExecutableFile(FocusModeNotifier notifier) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['exe', 'app'],
      );
      if (result != null && result.files.isNotEmpty) {
        final fileName = result.files.first.name;
        if (fileName.isNotEmpty) {
          final cleanName = fileName.endsWith('.exe') ? fileName : '$fileName.exe';
          notifier.addBlockedApp(cleanName);
        }
      }
    } catch (_) {}
  }

  void _addCustomApp(FocusModeNotifier notifier) {
    final text = _customAppController.text.trim();
    if (text.isNotEmpty) {
      final appName = text.endsWith('.exe') ? text : '$text.exe';
      notifier.addBlockedApp(appName);
      _customAppController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusModeNotifierProvider);
    final notifier = ref.read(focusModeNotifierProvider.notifier);
    final t = ref.watch(appTranslationProvider);

    final settings = state.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          t.tr('focus_mode', fallback: 'Modo Foco & Bloqueador'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.tr('focus_blocker_active', fallback: 'Bloqueador de Distrações'),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.tr('focus_blocker_desc', fallback: 'Detecta aplicativos distratores durante cronômetro ativo'),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: settings.isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) => notifier.toggleEnabled(val),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.tr('strict_mode', fallback: 'Modo Estrito (Desktop)'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.tr('strict_mode_desc', fallback: 'Exibe alertas bloqueantes ao abrir apps restritos'),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: settings.isStrict,
                        activeColor: AppColors.primary,
                        onChanged: settings.isEnabled ? (val) => notifier.toggleStrict(val) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.tr('blocked_apps', fallback: 'Aplicativos Bloqueados'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              t.tr('blocked_apps_hint', fallback: 'Adicione executáveis de jogos ou redes sociais que devem ser monitorados.'),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customAppController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: t.tr('app_input_example', fallback: 'Ex: league of legends, riotclient, netflix'),
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) => _addCustomApp(notifier),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _addCustomApp(notifier),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: Text(t.tr('add', fallback: 'Adicionar'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickExecutableFile(notifier),
                  icon: const Icon(Icons.folder_open_rounded, color: AppColors.textSecondary, size: 20),
                  label: Text(
                    t.tr('browse_exe', fallback: 'Procurar .exe'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: settings.blockedProcesses.map((proc) {
                return Chip(
                  label: Text(proc, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  backgroundColor: AppColors.surfaceLight,
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                  onDeleted: () => notifier.removeBlockedApp(proc),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
