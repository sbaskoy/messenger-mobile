import 'package:planner_messenger/models/api_info_mode.dart';

import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/message/favorite_message.dart';

class MessageService {
  final MessengerService service;

  MessageService({required this.service});

  Future<List<Message>?> listMessages(String chatId) async {
    var response = await service.dio.get("/messages/$chatId");
    if (response.data != null) {
      var jsonResponse = response.data;
      if (jsonResponse is List) {
        return jsonResponse.map((e) => Message.fromJson(e)).toList();
      }
    }
    return null;
  }

  Future<Message?> sendMessage(String chatId, String message, {int? replyId}) async {
    var response = await service.dio.post(
      "/messages/$chatId",
      data: {
        "message": message,
        "reply_id": replyId,
      },
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
    var response = await service.dio.get("/messages/$chatId/favorites/$favoriteItemId");
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
