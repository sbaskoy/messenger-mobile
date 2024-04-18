import 'package:planner_messenger/models/auth/user_activity.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';

import 'chat.dart';

class ChatDetail {
  late Chat chat;
  UserActivity? userActivity;
  ChatUser? chatUser;
  late bool hasActiveCall;
  ChatDetail({required this.chat, this.userActivity, this.hasActiveCall = false});
  ChatDetail.fromJson(mapData) {
    chat = Chat.fromJson(mapData["chat"]);
    userActivity = mapData["user_activity"] != null ? UserActivity.fromJson(mapData["user_activity"]) : null;
    chatUser = mapData["chat_user"] != null ? ChatUser.fromJson(mapData["chat_user"]) : null;
    hasActiveCall = mapData["has_active_call"] ?? false;
  }
}
