import 'dart:io';

import 'package:dio/dio.dart';
import 'package:planner_messenger/models/api_info_mode.dart';

import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/message/favorite_message.dart';

class MessageService {
  final MessengerService service;

  MessageService({required this.service});

  Future<List<Message>?> listMessages(String chatId, {int page = 1, bool? refresh}) async {
    var response = await service.dio.get("/messages/$chatId", queryParameters: {
      "page": page,
      "refresh": refresh,
    });
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => Message.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<Message?> sendMessage(String chatId, String message, {int? replyId, List<File>? attachments}) async {
    var dataMap = <String, dynamic>{"message": message};
    if (replyId != null) {
      dataMap["reply_id"] = replyId;
    }

    var response = await service.dio.post(
      "/messages/$chatId",
      data: FormData.fromMap(
        {
          ...dataMap,
          "files": await Future.wait(attachments?.map((e) => MultipartFile.fromFile(e.path)).toList() ?? [])
        },
      ),
    );
    if (response.data != null) {
      return Message.fromJson(response.data);
    }
    return null;
  }

  Future<bool> seenMessages(String chatId, List<Message> messages) async {
    var response = await service.dio.post(
      "/messages/$chatId/seen",
      data: {
        "messages": messages.map((e) => e.id).toList(),
      },
    );
    if (response.data != null) {
      var result = ApiInfoModel.fromJson(response.data);
      return result.status == "OK";
    }
    return false;
  }

  Future<ApiInfoModel?> saveFavorite(String chatId, List<Message> messages) async {
    var response = await service.dio.post(
      "/messages/$chatId/favorites",
      data: {
        "messages": messages.map((e) => e.id).toList(),
      },
    );
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<List<FavoriteMessage>?> listFavorites(String chatId) async {
    var response = await service.dio.get("/messages/$chatId/favorites");
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => FavoriteMessage.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<ApiInfoModel?> deleteFavorites(String chatId, String favoriteItemId) async {
    var response = await service.dio.delete("/messages/$chatId/favorites/$favoriteItemId");
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<ApiInfoModel?> pinMessage(String chatId, int messageId) async {
    var response = await service.dio.post("/messages/$chatId/pin-message", data: {
      "message_id": messageId,
    });
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }
}
