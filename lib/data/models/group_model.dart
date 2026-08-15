import '../../core/utils/json_utils.dart';

class GroupModel {
  final int id;
  final String name;
  final String category;
  final int dailyGoalHours;
  final int membersCount;
  final int maxCapacity;
  final bool isPrivate;
  final String leaderName;
  final int leaderUserId;
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
    this.leaderUserId = 0,
    this.notice,
    this.isCamStudy = false,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: safeInt(json['id'] ?? json['groupID'] ?? json['gd']),
      name: safeString(json['t'] ?? json['n'] ?? json['name'], 'Grupo'),
      category: safeString(json['c'] ?? json['ct'], 'Geral'),
      dailyGoalHours: safeInt(json['gt'] ?? json['g'], 8),
      membersCount: safeInt(json['jc'] ?? json['mc'] ?? json['personnel'], 1),
      maxCapacity: safeInt(json['mc'] ?? json['mp'] ?? json['maxPersonnel'], 50),
      isPrivate: safeBool(json['ip'] ?? json['p']),
      leaderName: safeString(json['on'] ?? json['ln'] ?? json['leader']),
      leaderUserId: safeInt(json['ou'] ?? json['oid'] ?? json['leaderID'] ?? json['uid']),
      notice: json['sn'] != null || json['nt'] != null || json['notice'] != null
          ? safeString(json['sn'] ?? json['nt'] ?? json['notice'])
          : null,
      isCamStudy: safeBool(json['cam'] ?? json['isCam'] ?? json['isCamStudy']),
    );
  }
}
