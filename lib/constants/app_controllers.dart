import 'package:planner_messenger/controllers/chat_list_controller.dart';

import 'package:s_state/s_global_state.dart';

import '../controllers/auth_controller.dart';

class AppControllers {
  AppControllers._();

  static AuthController get auth => SGlobalState.get("auth", orNull: () => AuthController())!;

  static ChatListController get chatList => SGlobalState.get("chatList", orNull: () => ChatListController())!;
}
