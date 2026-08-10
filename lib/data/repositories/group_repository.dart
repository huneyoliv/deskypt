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
    final response = await _apiClient.get(
      '${ApiConstants.groupMembers}?groupID=$groupId',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['ms'] != null && data['ms'] is List) {
      final list = data['ms'] as List;
      return list
          .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> shakeMember({required int groupId, required int targetUserId}) async {
    final response = await _apiClient.post(
      ApiConstants.groupShake,
      data: {
        'groupID': groupId,
        'targetUserID': targetUserId,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return data['s'] == true;
  }

  Future<List<ChatMessageModel>> fetchChatMessages(int groupId) async {
    final response = await _apiClient.get(
      '${ApiConstants.groupChatMessages}?groupID=$groupId',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['messages'] != null && data['messages'] is List) {
      final list = data['messages'] as List;
      return list
          .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ChatMessageModel> sendMessage({
    required int groupId,
    required String message,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.groupChatMessages,
      data: {
        'groupID': groupId,
        'message': message,
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['s'] != true) {
      throw Exception(data['m'] ?? 'Falha ao enviar mensagem');
    }

    return ChatMessageModel.fromJson(data['msg'] ?? data);
  }

  Future<List<GroupModel>> searchGroups(String query) async {
    final response = await _apiClient.get(
      '/group/list-new-2?q=$query',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['groups'] != null && data['groups'] is List) {
      final list = data['groups'] as List;
      return list
          .map((g) => GroupModel.fromJson(g as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
