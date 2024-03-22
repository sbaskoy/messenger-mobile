import 'package:planner_messenger/managers/local_manager.dart';
import 'package:planner_messenger/managers/socket_manager.dart';
import 'package:s_state/s_global_state.dart';

class AppManagers {
  AppManagers._();

  static SocketManager get socket => SGlobalState.get("socket", orNull: () => SocketManager())!;
  static LocalManager get local => SGlobalState.get("local", orNull: () => LocalManager())!;
}
