import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/subject_model.dart';

class SubjectManagementDialog extends StatefulWidget {
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final ValueChanged<SubjectModel> onSelectSubject;
  final Function(String title, int colorInt) onCreateSubject;
  final Function(SubjectModel subject) onUpdateSubject;
  final Function(int id) onDeleteSubject;

  const SubjectManagementDialog({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelectSubject,
    required this.onCreateSubject,
    required this.onUpdateSubject,
    required this.onDeleteSubject,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SubjectModel> subjects,
    required SubjectModel? selectedSubject,
    required ValueChanged<SubjectModel> onSelectSubject,
    required Function(String title, int colorInt) onCreateSubject,
    required Function(SubjectModel subject) onUpdateSubject,
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
          onDeleteSubject: onDeleteSubject,
        ),
      ),
    );
  }

  @override
  State<SubjectManagementDialog> createState() => _SubjectManagementDialogState();
}

class _SubjectManagementDialogState extends State<SubjectManagementDialog> {
  final _titleController = TextEditingController();
  int _selectedColorInt = 0xFF4CAF50;

  final List<int> _availableColors = const [
    0xFF4CAF50, 0xFF2196F3, 0xFFFF9800, 0xFF9C27B0,
    0xFFE91E63, 0xFF00BCD4, 0xFFFF5722, 0xFF795548,
    0xFF607D8B, 0xFF3F51B5,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showAddSubjectDialog() {
    _titleController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Nova Matéria', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome da Matéria',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
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
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  widget.onCreateSubject(_titleController.text.trim(), _selectedColorInt);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Criar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMs(int ms) {
    final m = ms ~/ 60000;
    final h = m ~/ 60;
    if (h > 0) return '${h}h ${m % 60}m';
    return '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                const Text('Selecionar & Gerenciar Matérias', style: AppTextStyles.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Clique em uma matéria para selecioná-la para o cronômetro.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final subject = widget.subjects[index];
                  final isSelected = widget.selectedSubject?.id == subject.id;

                  return InkWell(
                    onTap: () {
                      widget.onSelectSubject(subject);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: subject.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              subject.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _formatMs(subject.studyMs),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                            onPressed: () => widget.onDeleteSubject(subject.id),
                          ),
                        ],
                      ),
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
                label: const Text('Nova Matéria', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
