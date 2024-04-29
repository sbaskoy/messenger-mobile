import 'package:planner_messenger/models/call/chat_call_model.dart';
import 'package:planner_messenger/models/call/chat_call_participant.dart';

import 'package:planner_messenger/services/messenger_service.dart';

class CallService {
  final MessengerService service;

  CallService({required this.service});

  Future<List<ChatCallModel>?> listCalls() async {
    var response = await service.dio.get("/calls");
    var jsonResponse = response.data;
    if (jsonResponse is List) {
      return jsonResponse.map((e) => ChatCallModel.fromJson(e)).toList();
    }
    return null;
  }

  Future<ChatCallModel?> startCall(int chatId) async {
    var response = await service.dio.post("/calls/start-call/$chatId");
    var jsonResponse = response.data;
    if (jsonResponse is Map) {
      return ChatCallModel.fromJson(jsonResponse);
    }
    return null;
  }

  Future<ChatCallModel?> joinCall(int chatId) async {
    var response = await service.dio.post("/calls/join-call/$chatId");
    var jsonResponse = response.data;
    if (jsonResponse is Map) {
      return ChatCallModel.fromJson(jsonResponse);
    }
    return null;
  }

  Future<ChatCallParticipant?> leaveCall(int chatId) async {
    var response = await service.dio.post("/calls/leave-call/$chatId");
    var jsonResponse = response.data;
    if (jsonResponse is Map) {
      return ChatCallParticipant.fromJson(jsonResponse);
    }
    return null;
  }
}
