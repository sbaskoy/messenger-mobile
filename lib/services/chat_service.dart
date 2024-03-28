import 'dart:io';

import 'package:dio/dio.dart';
import 'package:planner_messenger/models/api_info_mode.dart';
import 'package:planner_messenger/models/chats/chat_join_response.dart';
import 'package:planner_messenger/models/message/chat_message_attachment.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/chats/chat.dart';

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

  Future<Chat?> createChat(String chatName, List<String> users, String chatType, {File? file}) async {
    var response = await service.dio.post(
      "/chats",
      data: FormData.fromMap({
        "name": chatName,
        "users": users.join(","),
        "chat_type": chatType,
        "file": file != null ? await MultipartFile.fromFile(file.path) : null,
      }),
    );
    if (response.data != null) {
      return Chat.fromJson(response.data);
    }
    return response.data;
  }

  Future<Chat?> updateChat(String chatId, String chatName, {File? file}) async {
    var response = await service.dio.post(
      "/chats/update/$chatId",
      data: FormData.fromMap({
        "name": chatName,
        "file": file != null ? await MultipartFile.fromFile(file.path) : null,
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
    var response = await service.dio.post(
      "/chats/archive",
      data: {
        "chat_id": chatId,
      },
    );
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

  Future<ApiInfoModel?> leaveChat(String chatId) async {
    var response = await service.dio.post(
      "/chats/leave",
      data: {
        "chat_id": chatId,
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
}
