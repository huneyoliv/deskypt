import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/dday_model.dart';
import '../../data/models/todo_item_model.dart';
import '../../data/repositories/planner_repository.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository();
});

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DDayModel> _ddays = [];
  List<TodoItemModel> _todos = [];
  bool _isLoading = true;

  final _todoTitleController = TextEditingController();
  final _ddayTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _todoTitleController.dispose();
    _ddayTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final repo = ref.read(plannerRepositoryProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final results = await Future.wait([
      repo.fetchDDays(),
      repo.fetchTodos(dateStr),
    ]);

    if (mounted) {
      setState(() {
        _ddays = results[0] as List<DDayModel>;
        _todos = results[1] as List<TodoItemModel>;
        _isLoading = false;
      });
    }
  }

  void _toggleTodo(TodoItemModel todo) {
    setState(() {
      _todos = _todos.map((t) {
        if (t.id == todo.id) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
    });
  }

  void _showAddTodoDialog() {
    String selectedSubjectTitle = 'Português';
    int selectedColorInt = 4292557552;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Nova Tarefa', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _todoTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Descrição da tarefa',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
              final text = _todoTitleController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _todos.add(
                    TodoItemModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      subjectTitle: selectedSubjectTitle,
                      subjectColorInt: selectedColorInt,
                      title: text,
                      isCompleted: false,
                      dateYmd: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    ),
                  );
                });
                _todoTitleController.clear();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDDayDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Novo D-Day', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ddayTitleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nome do evento/prova (ex: ENEM 2026)',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
              final text = _ddayTitleController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _ddays.add(
                    DDayModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: text,
                      targetDate: selectedDate,
                      colorInt: 4294948685,
                    ),
                  );
                });
                _ddayTitleController.clear();
                Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    final totalCount = _todos.length;
    final progressPct = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Left Column - D-Days & Calendar
          SizedBox(
            width: 380,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Eventos D-Day', style: AppTextStyles.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: AppColors.primary),
                        onPressed: _showAddDDayDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // D-Day List Cards
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _ddays.length,
                      itemBuilder: (context, index) {
                        final dday = _ddays[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: dday.color.withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dday.label,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: dday.color,
                                ),
                              ),
                              Text(
                                dday.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text('Calendário', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),

                  // Mini Calendar View
                  CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Right Column - To-Do Checklist
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lista de Tarefas (To-Do)',
                            style: AppTextStyles.displayMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy', 'pt')
                                .format(_selectedDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddTodoDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Nova Tarefa',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso do Dia: $completedCount de $totalCount concluídas',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${(progressPct * 100).toInt()}%',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressPct,
                            minHeight: 8,
                            backgroundColor: AppColors.surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // To-Do Checklist Items
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: _todos.length,
                            itemBuilder: (context, index) {
                              final todo = _todos[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: todo.isCompleted
                                        ? AppColors.border
                                        : Color(todo.subjectColorInt)
                                            .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: todo.isCompleted,
                                      activeColor: AppColors.primary,
                                      onChanged: (_) => _toggleTodo(todo),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Color(todo.subjectColorInt),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo.title,
                                            style: TextStyle(
                                              color: todo.isCompleted
                                                  ? AppColors.textMuted
                                                  : Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            todo.subjectTitle,
                                            style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
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
          ),
        ],
      ),
    );
  }
}
