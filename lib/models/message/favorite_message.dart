import 'package:planner_messenger/models/message/message.dart';

class FavoriteMessage {
  int? id;
  int? messageId;
  int? chatId;
  int? userId;
  Message? message;

  FavoriteMessage({this.id, this.messageId, this.chatId, this.userId, this.message});

  FavoriteMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageId = json['message_id'];
    chatId = json['chat_id'];
    userId = json['user_id'];
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message_id'] = messageId;
    data['chat_id'] = chatId;
    data['user_id'] = userId;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}
