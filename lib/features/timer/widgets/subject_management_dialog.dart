import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/localization/app_translation.dart';
import '../../../data/models/subject_model.dart';

class SubjectManagementDialog extends ConsumerStatefulWidget {
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final ValueChanged<SubjectModel> onSelectSubject;
  final Function(String title, int colorInt) onCreateSubject;
  final Function(SubjectModel subject) onUpdateSubject;
  final Function(int id, bool archive) onArchiveSubject;
  final Function(int id) onDeleteSubject;

  const SubjectManagementDialog({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelectSubject,
    required this.onCreateSubject,
    required this.onUpdateSubject,
    required this.onArchiveSubject,
    required this.onDeleteSubject,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SubjectModel> subjects,
    required SubjectModel? selectedSubject,
    required ValueChanged<SubjectModel> onSelectSubject,
    required Function(String title, int colorInt) onCreateSubject,
    required Function(SubjectModel subject) onUpdateSubject,
    required Function(int id, bool archive) onArchiveSubject,
    required Function(int id) onDeleteSubject,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SubjectManagementDialog(
          subjects: subjects,
          selectedSubject: selectedSubject,
          onSelectSubject: onSelectSubject,
          onCreateSubject: onCreateSubject,
          onUpdateSubject: onUpdateSubject,
          onArchiveSubject: onArchiveSubject,
          onDeleteSubject: onDeleteSubject,
        ),
      ),
    );
  }

  @override
  ConsumerState<SubjectManagementDialog> createState() => _SubjectManagementDialogState();
}

class _SubjectManagementDialogState extends ConsumerState<SubjectManagementDialog> {
  final _titleController = TextEditingController();
  int _selectedColorInt = 0xFF4CAF50;
  bool _showArchived = false;
  late List<SubjectModel> _localSubjects;

  final List<int> _availableColors = const [
    0xFF4CAF50, 0xFF2196F3, 0xFFFF9800, 0xFF9C27B0,
    0xFFE91E63, 0xFF00BCD4, 0xFFFF5722, 0xFF795548,
    0xFF607D8B, 0xFF3F51B5,
  ];

  @override
  void initState() {
    super.initState();
    _localSubjects = List.from(widget.subjects);
  }

  @override
  void didUpdateWidget(SubjectManagementDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subjects != oldWidget.subjects) {
      _localSubjects = List.from(widget.subjects);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddSubjectDialog() {
    final t = ref.read(appTranslationProvider);
    _titleController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(t.tr('new_subject', fallback: 'Nova Matéria'), style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: t.tr('subject_title', fallback: 'Nome da Matéria'),
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((c) {
                  final color = Color(c);
                  final isSel = _selectedColorInt == c;
                  return GestureDetector(
                    onTap: () => setDialogState(() => _selectedColorInt = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.tr('cancel', fallback: 'Cancelar'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isNotEmpty) {
                  final newSub = SubjectModel(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: title,
                    colorInt: _selectedColorInt,
                  );
                  setState(() {
                    _localSubjects = [..._localSubjects, newSub];
                  });
                  widget.onCreateSubject(title, _selectedColorInt);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(t.tr('save', fallback: 'Criar'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSubjectDialog(SubjectModel subject) {
    final t = ref.read(appTranslationProvider);
    _titleController.text = subject.title;
    int editColorInt = subject.colorInt;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text('${t.tr("edit", fallback: "Editar")}: ${subject.title}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: t.tr('subject_title', fallback: 'Nome da Matéria'),
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((c) {
                  final color = Color(c);
                  final isSel = editColorInt == c;
                  return GestureDetector(
                    onTap: () => setDialogState(() => editColorInt = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.tr('cancel', fallback: 'Cancelar'), style: const TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final newTitle = _titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  final updated = subject.copyWith(title: newTitle, colorInt: editColorInt);
                  setState(() {
                    _localSubjects = _localSubjects.map((s) => s.id == subject.id ? updated : s).toList();
                  });
                  widget.onUpdateSubject(updated);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(t.tr('save', fallback: 'Salvar'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleArchive(int subjectId, bool archive) {
    setState(() {
      _localSubjects = _localSubjects.map((s) {
        if (s.id == subjectId) {
          return s.copyWith(isArchived: archive);
        }
        return s;
      }).toList();
    });
    widget.onArchiveSubject(subjectId, archive);
  }

  void _handleDelete(int subjectId) {
    setState(() {
      _localSubjects = _localSubjects.where((s) => s.id != subjectId).toList();
    });
    widget.onDeleteSubject(subjectId);
  }

  String _formatMs(int ms) {
    final m = ms ~/ 60000;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appTranslationProvider);
    final filteredSubjects = _localSubjects.where((s) => s.isArchived == _showArchived).toList();

    return Dialog(
      backgroundColor: AppColors.card.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                Text(t.tr('manage_subjects', fallback: 'Gerenciar Matérias'), style: AppTextStyles.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: Text(t.tr('active', fallback: 'Ativas')),
                  selected: !_showArchived,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(color: !_showArchived ? Colors.white : AppColors.textMuted),
                  onSelected: (_) => setState(() => _showArchived = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(t.tr('archived', fallback: 'Arquivadas')),
                  selected: _showArchived,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(color: _showArchived ? Colors.white : AppColors.textMuted),
                  onSelected: (_) => setState(() => _showArchived = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: filteredSubjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _showArchived
                              ? t.tr('no_archived_subjects', fallback: 'Nenhuma matéria arquivada.')
                              : t.tr('no_active_subjects', fallback: 'Nenhuma matéria ativa.'),
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredSubjects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final subject = filteredSubjects[index];
                        final isSelected = widget.selectedSubject?.id == subject.id;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? subject.color.withValues(alpha: 0.2)
                                : AppColors.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? subject.color : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  widget.onSelectSubject(subject);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: subject.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onSelectSubject(subject);
                                    Navigator.pop(context);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        _formatMs(subject.studyMs),
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                                tooltip: t.tr('edit_subject', fallback: 'Editar Matéria'),
                                onPressed: () => _showEditSubjectDialog(subject),
                              ),
                              IconButton(
                                icon: Icon(
                                  _showArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                tooltip: _showArchived
                                    ? t.tr('unarchive', fallback: 'Desarquivar')
                                    : t.tr('archive', fallback: 'Arquivar'),
                                onPressed: () => _handleArchive(subject.id, !_showArchived),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                tooltip: t.tr('delete_subject', fallback: 'Excluir Matéria'),
                                onPressed: () => _handleDelete(subject.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddSubjectDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: Text(t.tr('new_subject', fallback: 'Nova Matéria'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
