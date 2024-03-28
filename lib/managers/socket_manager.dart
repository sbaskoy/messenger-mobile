import 'package:planner_messenger/constants/app_constants.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketManager {
  Socket? _socket;

  Socket? get client => _socket;

  initSocket(String? accessToken) {
    if (accessToken == null) return;
    _socket = io(AppConstants.baseApiUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'query': 'token=$accessToken',
    });

    _socket?.on("connect", (data) {
      print("Socket connect");
    });
    _socket?.on("disconnected", (data) {
      print("Socket disconnect");
    });
    _socket?.on("NEW_MESSAGE", (data) {
      var message = Message.fromJson(data);
      AppControllers.chatList.addNewMessage(message);
    });
    _socket?.on("NEW_CHAT", (data) {
      var chat = Chat.fromJson(data);
      AppControllers.chatList.addChat(chat);
    });
  }

  void joinChat(String chatId) {
    _socket?.emit("JOIN_CHAT", {"chat_id": chatId});
  }

  void leaveChat(String chatId) {
    _socket?.emit("LEAVE_CHAT", {"chat_id": chatId});
  }
}
