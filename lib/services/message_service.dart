import 'package:dio/dio.dart';

import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/models/api_info_mode.dart';

import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/services/messenger_service.dart';

import '../models/message/favorite_message.dart';
import 'package:path/path.dart' as path;

class MessageService {
  final MessengerService service;

  MessageService({required this.service});

  List<Message>? _parseMessageList<T>(T? data) {
    if (data != null && data is List) {
      return data.map((e) => Message.fromJson(e)).toList();
    }
    return null;
  }

  Future<List<Message>?> listMessages(
    String chatId, {
    int? startMessageId,
  }) async {
    var response = await service.dio.get(
      "/messages/$chatId",
      queryParameters: {
        "startMessageId": startMessageId,
      },
    );
    return _parseMessageList(response.data);
  }

  Future<List<Message>?> previousMessages(String chatId, int messageId) async {
    var response = await service.dio.get(
      "/messages/$chatId/previous",
      queryParameters: {
        "messageId": messageId,
      },
    );
    return _parseMessageList(response.data);
  }

  Future<List<Message>?> nextMessages(String chatId, int messageId) async {
    var response = await service.dio.get(
      "/messages/$chatId/next",
      queryParameters: {
        "messageId": messageId,
      },
    );
    return _parseMessageList(response.data);
  }

  Future<Message?> sendMessage(String chatId, String message,
      {int? replyId, List<IFilePickerItem>? attachments, void Function(int count, int total)? onSendProgress}) async {
    var dataMap = <String, dynamic>{"message": message};
    if (replyId != null) {
      dataMap["reply_id"] = replyId;
    }

    var response = await service.dio.post(
      "/messages/$chatId",
      data: FormData.fromMap(
        {
          ...dataMap,
          "files": attachments
                  ?.map(
                    (e) => MultipartFile.fromBytes(
                      e.bytes,
                      filename: e.name ?? path.basename(e.originalPath),
                    ),
                  )
                  .toList() ??
              []
        },
      ),
      onSendProgress: onSendProgress,
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

  Future<ApiInfoModel?> deleteMessage(String chatId, String messageId) async {
    var response = await service.dio.delete("/messages/$chatId/delete/$messageId");
    if (response.data != null) {
      return ApiInfoModel.fromJson(response.data);
    }
    return null;
  }

  Future<Message?> forwardMessage(String forwardChatId, String messageId) async {
    var response = await service.dio.delete("/messages/$forwardChatId/forward/$messageId");
    if (response.data != null) {
      return Message.fromJson(response.data);
    }
    return null;
  }

  Future<List<Message>?> forwardMessages(String forwardChatId, List<int> messages) async {
    var response = await service.dio.post(
      "/messages/$forwardChatId/forward-messages",
      data: {
        "messages": messages,
      },
    );
    var jsonResponse = response.data;
    if (jsonResponse != null && jsonResponse is List) {
      return jsonResponse.map((e) => Message.fromJson(e)).toList();
    }
    return null;
  }
}
