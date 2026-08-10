import 'package:flutter/material.dart';
import '../../../data/models/subject_model.dart';
import '../../../shared/widgets/subject_chip.dart';
import '../../../core/theme/app_colors.dart';

class SubjectSelector extends StatelessWidget {
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final ValueChanged<SubjectModel> onSelectSubject;
  final Function(String title, int colorInt) onCreateSubject;

  const SubjectSelector({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSelectSubject,
    required this.onCreateSubject,
  });

  void _showAddSubjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    int selectedColorInt = 4292557552; // Default purple/indigo

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
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Nova Matéria', style: TextStyle(color: Colors.white)),
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
                    onCreateSubject(text, selectedColorInt);
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Criar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ...subjects.map((subject) {
            final isSelected = selectedSubject?.id == subject.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SubjectChip(
                subject: subject,
                isSelected: isSelected,
                onTap: () => onSelectSubject(subject),
              ),
            );
          }),

          // Add Subject Button
          IconButton(
            onPressed: () => _showAddSubjectDialog(context),
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
        ],
      ),
    );
  }
}
