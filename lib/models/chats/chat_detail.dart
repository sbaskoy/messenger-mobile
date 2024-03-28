import 'package:planner_messenger/models/auth/user_activity.dart';

import 'chat.dart';

class ChatDetail {
  late Chat chat;
  UserActivity? userActivity;

  ChatDetail({required this.chat, this.userActivity});
  ChatDetail.fromJson(mapData) {
    chat = Chat.fromJson(mapData["chat"]);
    userActivity = mapData["user_activity"] != null ? UserActivity.fromJson(mapData["user_activity"]) : null;
  }
}
