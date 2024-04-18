import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/services/messenger_service.dart';

class CallService {
  final MessengerService service;

  CallService({required this.service});

  Future<Chat?> startCall(int chatId) async {
    var response = await service.dio.post(
      "/call/start-call",
      data: {
        "chat_id": chatId,
      },
    );
    var jsonResponse = response.data;
    if (jsonResponse is Map) {
      return Chat.fromJson(jsonResponse);
    }
    return null;
  }
}
