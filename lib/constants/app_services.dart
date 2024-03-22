import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/services/auth_service.dart';
import 'package:planner_messenger/services/chat_service.dart';
import 'package:planner_messenger/services/message_service.dart';
import 'package:planner_messenger/services/messenger_service.dart';
import 'package:planner_messenger/services/users_service.dart';
import 'package:s_state/s_state.dart';

class AppServices {
  AppServices._();

  static MessengerService get baseService => SGlobalState.get<MessengerService>(
        "_service",
        orNull: () => MessengerService(AppControllers.auth),
      )!;

  static MessageService get message => SGlobalState.get<MessageService>(
        "_message",
        orNull: () => MessageService(service: AppServices.baseService),
      )!;

  static ChatService get chat => SGlobalState.get<ChatService>(
        "_chat",
        orNull: () => ChatService(service: AppServices.baseService),
      )!;

  static AuthService get auth => SGlobalState.get<AuthService>(
        "_auth",
        orNull: () => AuthService(service: AppServices.baseService),
      )!;
  static UsersService get users =>
      SGlobalState.get<UsersService>("_users", orNull: () => UsersService(service: AppServices.baseService))!;
}
