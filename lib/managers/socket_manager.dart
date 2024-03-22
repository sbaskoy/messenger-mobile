import 'package:planner_messenger/constants/app_constants.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketManager {
  Socket? _socket;

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
  }
}
