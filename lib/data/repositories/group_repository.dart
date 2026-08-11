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
  }) async {
    final payload = <String, dynamic>{
      'group_id': groupId,
      'nickname': nickname,
      'category': category ?? 'Geral',
      'userID': userId,
      'message': message,
      'createdAt': null,
      'updatedAt': null,
    };
    if (stickerUrl != null) payload['stickerUrl'] = stickerUrl;
    if (imageUrl != null) payload['imageUrl'] = imageUrl;

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
