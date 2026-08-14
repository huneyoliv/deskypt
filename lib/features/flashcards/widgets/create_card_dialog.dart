import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CreateCardDialog extends StatefulWidget {
  final void Function(String front, String back, String? hint) onSave;

  const CreateCardDialog({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required void Function(String front, String back, String? hint) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CreateCardDialog(onSave: onSave),
    );
  }

  @override
  State<CreateCardDialog> createState() => _CreateCardDialogState();
}

class _CreateCardDialogState extends State<CreateCardDialog> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Novo Flashcard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _frontController,
                autofocus: true,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Frente (Pergunta ou Termo)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintText: 'Ex: Qual a fórmula da energia cinética?',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _backController,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Verso (Resposta ou Definição)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintText: 'Ex: Ec = (m * v²) / 2',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hintController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Dica (opcional)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintText: 'Ex: Depende da massa e velocidade',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            final front = _frontController.text.trim();
            final back = _backController.text.trim();
            if (front.isNotEmpty && back.isNotEmpty) {
              widget.onSave(front, back, _hintController.text.trim());
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Adicionar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
