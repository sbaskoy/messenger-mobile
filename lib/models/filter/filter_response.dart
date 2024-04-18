import '../chats/chat.dart';
import '../message/message.dart';

class FilterResponse {
  late List<Chat> chats = [];
  late List<Message> messages = [];
  FilterResponse({required this.chats, required this.messages});
  FilterResponse.fromJson(json) {
    var chatsJsonResponse = json["chats"];
    if (chatsJsonResponse is List) {
      chats = chatsJsonResponse.map((e) => Chat.fromJson(e)).toList();
    }
    var messagesJsonResponse = json["messages"];
    if (messagesJsonResponse is List) {
      messages = messagesJsonResponse.map((e) => Message.fromJson(e)).toList();
    }
  }
}
