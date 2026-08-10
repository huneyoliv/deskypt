import '../../core/api/api_client.dart';
import '../models/dday_model.dart';
import '../models/todo_item_model.dart';

class PlannerRepository {
  final ApiClient _apiClient;

  PlannerRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<DDayModel>> fetchDDays() async {
    try {
      final response = await _apiClient.get('/planner/ddays');
      final data = response.data as Map<String, dynamic>;
      if (data['ddays'] != null && data['ddays'] is List) {
        final list = data['ddays'] as List;
        return list
            .map((item) => DDayModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [
      DDayModel(
        id: 1,
        title: 'Exame Nacional / Concurso',
        targetDate: DateTime.now().add(const Duration(days: 45)),
        colorInt: 4294948685,
      ),
      DDayModel(
        id: 2,
        title: 'Simulado Geral',
        targetDate: DateTime.now().add(const Duration(days: 12)),
        colorInt: 4292557552,
      ),
    ];
  }

  Future<List<TodoItemModel>> fetchTodos(String dateYmd) async {
    try {
      final response = await _apiClient.get('/planner/todos?date=$dateYmd');
      final data = response.data as Map<String, dynamic>;
      if (data['todos'] != null && data['todos'] is List) {
        final list = data['todos'] as List;
        return list
            .map((item) => TodoItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [
      TodoItemModel(
        id: 10,
        subjectTitle: 'Português',
        subjectColorInt: 4292557552,
        title: 'Resolver 30 questões de Sintaxe',
        isCompleted: true,
        dateYmd: dateYmd,
      ),
      TodoItemModel(
        id: 11,
        subjectTitle: 'Matemática',
        subjectColorInt: 4294948685,
        title: 'Revisar aula de Geometria Plana',
        isCompleted: false,
        dateYmd: dateYmd,
      ),
      TodoItemModel(
        id: 12,
        subjectTitle: 'Direito Constitucional',
        subjectColorInt: 4278241526,
        title: 'Leitura dos Artigos 5º a 11º da CF/88',
        isCompleted: false,
        dateYmd: dateYmd,
      ),
    ];
  }
}
