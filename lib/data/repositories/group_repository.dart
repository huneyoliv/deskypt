import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/group_model.dart';
import '../models/group_member_model.dart';
import '../models/chat_message_model.dart';

class GroupRepository {
  final ApiClient _apiClient;

  GroupRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<GroupMemberModel>> fetchMembers(int groupId) async {
    try {
      final response = await _apiClient.get(
        '/logs/group/members/v2?groupID=$groupId&countryID=23&isLooking=false&version=810041',
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['ms'] ?? data['members'];
      if (list != null && list is List) {
        return list
            .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    try {
      final response = await _apiClient.get(
        '${ApiConstants.groupMembers}?groupID=$groupId',
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['ms'] ?? data['members'];
      if (list != null && list is List) {
        return list
            .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<List<GroupMemberModel>> fetchGroupRanks(int groupId, {String period = 'week'}) async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month}-${now.day}';
      final response = await _apiClient.get(
        '/logs/group/member/ranks?type=$period&countryID=23&categoryID=0&groupID=$groupId&isCam=false&date=$dateStr&page=1',
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        final list = data['ms'] ?? data['ranks'];
        if (list is List) {
          final members = list
              .whereType<Map<String, dynamic>>()
              .map((m) => GroupMemberModel.fromJson(m))
              .toList();
          members.sort((a, b) => b.studyMs.compareTo(a.studyMs));
          return members;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<GroupMemberModel>> fetchWeeklyRanks(int groupId) => fetchGroupRanks(groupId, period: 'week');

  Future<bool> shakeMember({required int groupId, required int targetUserId}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.groupShake,
        data: {
          'groupID': groupId,
          'targetUserID': targetUserId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<List<ChatMessageModel>> fetchChatMessages(int groupId) async {
    try {
      final response = await _apiClient.get(
        '/chat/group/messages?group_id=$groupId&include_meta=1',
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['m'] ?? data['messages'];
      if (list != null && list is List) {
        return list
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ChatMessageModel> sendMessage({
    required int groupId,
    String nickname = 'Usuário',
    int userId = 0,
    String message = '',
    String? category,
    String? stickerUrl,
    String? imageUrl,
    String? thumbUrl,
  }) async {
    final payload = <String, dynamic>{
      'group_id': groupId,
      'nickname': nickname,
      'category': category ?? 'Geral',
      'userID': userId,
      'message': message.isNotEmpty ? message : (imageUrl != null ? 'Photo' : ''),
      'createdAt': null,
      'updatedAt': null,
    };
    if (stickerUrl != null) payload['stickerUrl'] = stickerUrl;
    if (imageUrl != null) {
      payload['img'] = imageUrl;
      payload['imageUrl'] = imageUrl;
    }
    if (thumbUrl != null) {
      payload['th'] = thumbUrl;
    }

    final response = await _apiClient.post(
      '/chat/group/message',
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    if (data['s'] != true && data['idx'] == null) {
      throw Exception(data['m'] ?? 'Falha ao enviar mensagem');
    }

    return ChatMessageModel.fromJson(data);
  }

  Future<bool> sendReaction({
    required int groupId,
    required int messageId,
    required String emoji,
  }) async {
    try {
      final response = await _apiClient.post(
        '/chat/group/reaction',
        data: {
          'group_id': groupId,
          'idx': messageId,
          'reaction': emoji,
        },
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<List<GroupModel>> searchGroups(String query) async {
    try {
      final response = await _apiClient.post(
        '/group/search-info/v2',
        data: {'query': query},
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['groups'] ?? data['g'] ?? data['list'];
      if (list != null && list is List) {
        return list
            .map((g) => GroupModel.fromJson(g as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    try {
      final response = await _apiClient.post(
        '/group/list-new-2',
        data: {'q': query},
      );

      final data = response.data as Map<String, dynamic>;
      final list = data['groups'] ?? data['g'];
      if (list != null && list is List) {
        return list
            .map((g) => GroupModel.fromJson(g as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [];
  }

  Future<bool> joinGroup(int groupId) async {
    try {
      final response = await _apiClient.post(
        '/group/join/v2',
        data: {'group_id': groupId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> leaveGroup(int groupId) async {
    try {
      final response = await _apiClient.post(
        '/group/leave/v2',
        data: {'group_id': groupId},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }
}
