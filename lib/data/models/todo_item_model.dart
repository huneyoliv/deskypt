class TodoItemModel {
  final int id;
  final int? subjectId;
  final String subjectTitle;
  final int subjectColorInt;
  final String title;
  final bool isCompleted;
  final String dateYmd;

  const TodoItemModel({
    required this.id,
    this.subjectId,
    required this.subjectTitle,
    required this.subjectColorInt,
    required this.title,
    required this.isCompleted,
    required this.dateYmd,
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      id: json['id'] as int? ?? 0,
      subjectId: json['subjectId'] as int?,
      subjectTitle: json['subjectTitle'] as String? ?? 'Geral',
      subjectColorInt: json['subjectColorInt'] as int? ?? 4292557552,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      dateYmd: json['dateYmd'] as String? ?? '',
    );
  }

  TodoItemModel copyWith({
    int? id,
    int? subjectId,
    String? subjectTitle,
    int? subjectColorInt,
    String? title,
    bool? isCompleted,
    String? dateYmd,
  }) {
    return TodoItemModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectTitle: subjectTitle ?? this.subjectTitle,
      subjectColorInt: subjectColorInt ?? this.subjectColorInt,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dateYmd: dateYmd ?? this.dateYmd,
    );
  }
}
