import 'package:flutter/material.dart';
import '../../../data/models/subject_model.dart';
import '../../../shared/widgets/subject_chip.dart';
import '../../../core/theme/app_colors.dart';

class SubjectSelector extends StatelessWidget {
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final ValueChanged<SubjectModel> onSelectSubject;
  final Function(String title, int colorInt) onCreateSubject;
  final ValueChanged<SubjectModel>? onUpdateSubject;
  final ValueChanged<int>? onArchiveSubject;
  final ValueChanged<int>? onDeleteSubject;

  const SubjectSelector({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelectSubject,
    required this.onCreateSubject,
    this.onUpdateSubject,
    this.onArchiveSubject,
    this.onDeleteSubject,
  });

  void _showAddSubjectDialog(BuildContext context, {SubjectModel? editSubject}) {
    final titleController = TextEditingController(text: editSubject?.title ?? '');
    int selectedColorInt = editSubject?.colorInt ?? 4292557552;

    final presetColors = [
      4292557552, // Indigo
      4294948685, // Pink/Red
      4278241526, // Green
      4294951168, // Orange
      4278235391, // Cyan/Blue
      4294961920, // Yellow
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isEditing = editSubject != null;
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              isEditing ? 'Editar Matéria' : 'Nova Matéria',
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nome da matéria (ex: Matemática)',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cor da Matéria:', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: presetColors.map((colorInt) {
                    final color = Color(colorInt).withValues(alpha: 1.0);
                    final isSelected = colorInt == selectedColorInt;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorInt = colorInt;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final text = titleController.text.trim();
                  if (text.isNotEmpty) {
                    if (isEditing && onUpdateSubject != null) {
                      onUpdateSubject!(
                        editSubject.copyWith(
                          title: text,
                          colorInt: selectedColorInt,
                        ),
                      );
                    } else {
                      onCreateSubject(text, selectedColorInt);
                    }
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  isEditing ? 'Salvar' : 'Criar',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSubjectOptionsMenu(BuildContext context, SubjectModel subject) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Editar Matéria', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _showAddSubjectDialog(context, editSubject: subject);
              },
            ),
            if (onArchiveSubject != null)
              ListTile(
                leading: const Icon(Icons.archive, color: AppColors.warning),
                title: const Text('Arquivar Matéria', style: TextStyle(color: AppColors.warning)),
                onTap: () {
                  Navigator.of(context).pop();
                  onArchiveSubject!(subject.id);
                },
              ),
            if (onDeleteSubject != null)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Excluir Matéria', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmDialog(context, subject);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SubjectModel subject) {
    if (onDeleteSubject == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Excluir "${subject.title}"?', style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja excluir esta matéria do servidor?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              onDeleteSubject!(subject.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManageSubjectsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Gerenciar Matérias', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhuma matéria cadastrada',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: subjects.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                    itemBuilder: (context, index) {
                      final s = subjects[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: s.color,
                          radius: 8,
                        ),
                        title: Text(
                          s.title,
                          style: TextStyle(
                            color: s.isArchived ? AppColors.textMuted : Colors.white,
                            decoration: s.isArchived ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          s.isArchived ? 'Arquivada' : 'Ativa',
                          style: TextStyle(
                            color: s.isArchived ? AppColors.warning : AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showAddSubjectDialog(context, editSubject: s);
                              },
                            ),
                            if (onArchiveSubject != null)
                              IconButton(
                                icon: Icon(
                                  s.isArchived ? Icons.unarchive : Icons.archive,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                                tooltip: s.isArchived ? 'Desarquivar' : 'Arquivar',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onArchiveSubject!(s.id);
                                },
                              ),
                            if (onDeleteSubject != null)
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: AppColors.error, size: 18),
                                tooltip: 'Excluir',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showDeleteConfirmDialog(context, s);
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSubjects = subjects.where((s) => !s.isArchived).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...activeSubjects.map((subject) {
            final isSelected = selectedSubject?.id == subject.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onLongPress: () => _showSubjectOptionsMenu(context, subject),
                child: SubjectChip(
                  subject: subject,
                  isSelected: isSelected,
                  onTap: () => onSelectSubject(subject),
                ),
              ),
            );
          }),

          // Add Subject Button
          IconButton(
            onPressed: () => _showAddSubjectDialog(context),
            tooltip: 'Adicionar Matéria',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),

          // Manage Subjects Button
          IconButton(
            onPressed: () => _showManageSubjectsModal(context),
            tooltip: 'Gerenciar Matérias (Editar, Arquivar, Deletar)',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune_outlined, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
