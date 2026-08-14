import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../timer_notifier.dart';

class PomodoroConfigDialog extends StatefulWidget {
  final TimerState state;
  final void Function({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? totalCycles,
    bool? autoStartBreaks,
    bool? autoStartFocus,
  }) onSave;

  const PomodoroConfigDialog({
    super.key,
    required this.state,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required TimerState state,
    required void Function({
      int? focusMinutes,
      int? shortBreakMinutes,
      int? longBreakMinutes,
      int? totalCycles,
      bool? autoStartBreaks,
      bool? autoStartFocus,
    }) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PomodoroConfigDialog(
        state: state,
        onSave: onSave,
      ),
    );
  }

  @override
  State<PomodoroConfigDialog> createState() => _PomodoroConfigDialogState();
}

class _PomodoroConfigDialogState extends State<PomodoroConfigDialog> {
  late int _focusMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _totalCycles;
  late bool _autoStartBreaks;
  late bool _autoStartFocus;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.state.pomodoroFocusMinutes;
    _shortBreakMinutes = widget.state.pomodoroShortBreakMinutes;
    _longBreakMinutes = widget.state.pomodoroLongBreakMinutes;
    _totalCycles = widget.state.totalPomodoroCycles;
    _autoStartBreaks = widget.state.autoStartBreaks;
    _autoStartFocus = widget.state.autoStartFocus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.timer_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Text(
            'Configurações do Pomodoro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepper(
                label: 'Tempo de Foco',
                value: '$_focusMinutes min',
                icon: Icons.local_fire_department,
                iconColor: AppColors.primary,
                onDecrement: _focusMinutes > 5 ? () => setState(() => _focusMinutes -= 5) : null,
                onIncrement: _focusMinutes < 120 ? () => setState(() => _focusMinutes += 5) : null,
              ),
              const Divider(color: AppColors.border),
              _buildStepper(
                label: 'Pausa Curta',
                value: '$_shortBreakMinutes min',
                icon: Icons.coffee,
                iconColor: AppColors.success,
                onDecrement: _shortBreakMinutes > 1 ? () => setState(() => _shortBreakMinutes -= 1) : null,
                onIncrement: _shortBreakMinutes < 30 ? () => setState(() => _shortBreakMinutes += 1) : null,
              ),
              const Divider(color: AppColors.border),
              _buildStepper(
                label: 'Pausa Longa',
                value: '$_longBreakMinutes min',
                icon: Icons.beach_access,
                iconColor: AppColors.warning,
                onDecrement: _longBreakMinutes > 5 ? () => setState(() => _longBreakMinutes -= 5) : null,
                onIncrement: _longBreakMinutes < 60 ? () => setState(() => _longBreakMinutes += 5) : null,
              ),
              const Divider(color: AppColors.border),
              _buildStepper(
                label: 'Ciclos até Pausa Longa',
                value: '$_totalCycles ciclos',
                icon: Icons.repeat,
                iconColor: AppColors.textSecondary,
                onDecrement: _totalCycles > 2 ? () => setState(() => _totalCycles -= 1) : null,
                onIncrement: _totalCycles < 10 ? () => setState(() => _totalCycles += 1) : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Iniciar pausas automaticamente', style: TextStyle(color: Colors.white, fontSize: 14)),
                value: _autoStartBreaks,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _autoStartBreaks = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Iniciar foco automaticamente', style: TextStyle(color: Colors.white, fontSize: 14)),
                value: _autoStartFocus,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _autoStartFocus = val),
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
            widget.onSave(
              focusMinutes: _focusMinutes,
              shortBreakMinutes: _shortBreakMinutes,
              longBreakMinutes: _longBreakMinutes,
              totalCycles: _totalCycles,
              autoStartBreaks: _autoStartBreaks,
              autoStartFocus: _autoStartFocus,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStepper({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onDecrement,
    required VoidCallback? onIncrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary, size: 22),
                onPressed: onDecrement,
              ),
              SizedBox(
                width: 70,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
