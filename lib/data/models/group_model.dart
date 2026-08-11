class GroupModel {
  final int id;
  final String name;
  final String category;
  final int dailyGoalHours;
  final int membersCount;
  final int maxCapacity;
  final bool isPrivate;
  final String leaderName;
  final String? notice;
  final bool isCamStudy;

  const GroupModel({
    required this.id,
    required this.name,
    required this.category,
    required this.dailyGoalHours,
    required this.membersCount,
    required this.maxCapacity,
    required this.isPrivate,
    required this.leaderName,
    this.notice,
    this.isCamStudy = false,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as int? ?? json['groupID'] as int? ?? json['gd'] as int? ?? 0,
      name: json['t'] as String? ?? json['n'] as String? ?? json['name'] as String? ?? 'Grupo',
      category: json['c'] as String? ?? json['ct'] as String? ?? 'Geral',
      dailyGoalHours: json['gt'] as int? ?? json['g'] as int? ?? 8,
      membersCount: json['jc'] as int? ?? json['mc'] as int? ?? json['personnel'] as int? ?? 1,
      maxCapacity: json['mc'] as int? ?? json['mp'] as int? ?? json['maxPersonnel'] as int? ?? 50,
      isPrivate: json['ip'] as bool? ?? json['p'] as bool? ?? false,
      leaderName: json['on'] as String? ?? json['ln'] as String? ?? json['leader'] as String? ?? '',
      notice: json['sn'] as String? ?? json['nt'] as String? ?? json['notice'] as String?,
      isCamStudy: json['cam'] as bool? ?? json['isCam'] as bool? ?? json['isCamStudy'] as bool? ?? false,
    );
  }
}
