
import 'package:dio/dio.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/models/api_info_mode.dart';
import 'package:planner_messenger/models/chats/chat_join_response.dart';
import 'package:planner_messenger/models/message/chat_message_attachment.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/auth/user.dart';
import '../models/chats/chat.dart';
import '../models/chats/chat_user.dart';

class ChatService {
  final MessengerService service;

  ChatService({required this.service});

  Future<List<Chat>?> listChat({bool? archive, int page = 1, bool? refresh}) async {
    var response = await service.dio.get("/chats", queryParameters: {
      "archived": archive ?? false,
      "page": page,
      "refresh": refresh,
    });
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => Chat.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<Chat?> createChat(String chatName, List<String> users, String chatType, {IFilePickerItem? file}) async {
    var response = await service.dio.post(
      "/chats",
      data: FormData.fromMap({
        "name": chatName,
        "users": users.join(","),
        "chat_type": chatType,
        "file": file != null
            ? MultipartFile.fromBytes(
                file.bytes,
                filename: file.name,
              )
            : null,
      }),
    );
    if (response.data != null) {
      return Chat.fromJson(response.data);
    }
    return response.data;
  }

  Future<Chat?> updateChat(String chatId, String chatName, {IFilePickerItem? file}) async {
    var response = await service.dio.post(
      "/chats/update/$chatId",
      data: FormData.fromMap({
        "name": chatName,
        "file": file != null ? MultipartFile.fromBytes(file.bytes, filename: file.name) : null,
      }),
    );
    if (response.data != null) {
      return Chat.fromJson(response.data);
    }
    return response.data;
  }

  Future<ApiInfoModel<ChatJoinResponse>?> joinChat({required String chatId, String? userId}) async {
    var response = await service.dio.post(
      "/chats/join",
      data: {
        "user_id": userId,
        "chat_id": chatId,
      },
    );
    if (response.data != null) {
      return ApiInfoModel<ChatJoinResponse>.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel<Chat>?> archiveChat(String chatId) async {
    var response = await service.dio.post("/chats/archive/$chatId");
    if (response.data != null) {
      return ApiInfoModel<Chat>.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel<Chat>?> unArchiveChat(String chatId) async {
    var response = await service.dio.post("/chats/un-archive/$chatId");
    if (response.data != null) {
      return ApiInfoModel<Chat>.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel<Chat>?> deleteChat(String chatId) async {
    var response = await service.dio.delete(
      "/chats/delete",
      data: {
        "chat_id": chatId,
      },
    );
    if (response.data != null) {
      return ApiInfoModel<Chat>.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel?> leaveChat(String chatId, {int? userId}) async {
    var response = await service.dio.post(
      "/chats/leave",
      data: {
        "chat_id": chatId,
        "user_id": userId,
      },
    );
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<List<ChatMessageAttachment>?> listChatDocuments(String chatId) async {
    var response = await service.dio.get(
      "/chats/attachments/$chatId",
    );
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => ChatMessageAttachment.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<List<ChatUser>?> addMembersToChat(String chatId, List<User> users) async {
    var response = await service.dio.post("/chats/add-members/$chatId", data: {
      "added_users": users.map((e) => e.id).toList(),
    });
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => ChatUser.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<ChatUser?> updateChatUserRole({required String chatId, required int userId, required String role}) async {
    var response = await service.dio.post(
      "/chats/update-user-role/$chatId",
      data: {
        "user_id": userId,
        "role": role,
      },
    );
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is Map) {
        return ChatUser.fromJson(jsonResponse);
      }
    }
    return null;
  }

  Future<ApiInfoModel?> pinMessage(String chatId, int messageId) async {
    var response = await service.dio.post(
      "/chats/pin-message/$chatId",
      data: {
        "message_id": messageId,
      },
    );
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel?> removePinMessage(String chatId) async {
    var response = await service.dio.post("/chats/remove-pin-message/$chatId");
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<bool> disableChatNotification(String chatId) async {
    var response = await service.dio.post("/chats/notifications/disable/$chatId");
    if (response.data != null) {
      return true;
    }
    return false;
  }

  Future<bool> enableChatNotification(String chatId) async {
    var response = await service.dio.post("/chats/notifications/enable/$chatId");
    if (response.data != null) {
      return true;
    }
    return false;
  }
}
