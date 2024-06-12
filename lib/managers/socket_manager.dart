import 'dart:developer';

import 'package:planner_messenger/constants/app_constants.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:s_state/s_state.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketManager {
  Socket? _socket;

  Socket? get client => _socket;
  final isConnected = SState(false);
  initSocket(String? accessToken) {
    if (accessToken == null) return;
    _socket = io(AppConstants.baseApiUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'query': 'token=$accessToken',
    });

    _socket?.on("connect", (data) {
      log("Socket connect");
      isConnected.setState(true);
    });
    _socket?.on("disconnected", (data) {
      log("Socket disconnect");
      isConnected.setState(false);
    });
    _socket?.on("NEW_MESSAGE", (data) {
      var message = Message.fromJson(data);
      AppControllers.chatList.addNewMessage(message);
    });
    _socket?.on("NEW_CHAT", (data) {
      var chat = Chat.fromJson(data);
      AppControllers.chatList.addChat(chat);
    });
    _socket?.connect();
  }

  void joinChat(String chatId) {
    _socket?.emit("JOIN_CHAT", {"chat_id": chatId});
  }

  void leaveChat(String chatId) {
    _socket?.emit("LEAVE_CHAT", {"chat_id": chatId});
  }

  void typing(String chatId, bool typing) {
    _socket?.emit("TYPING", {"chat_id": chatId, "typing": typing});
  }

  Future<dynamic> request(String event, Map data) {
    return Future(() {
      _socket?.emitWithAck(event, data);
      _socket?.once("RESPONSE", (data) {
        if (data is Map && data["error"] != null) {
          throw Exception(data["error"]);
        }
        return data;
      });
    });
  }
}
