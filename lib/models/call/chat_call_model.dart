import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:get/get.dart';
import '../auth/user.dart';
import '../chats/chat.dart';
import 'chat_call_participant.dart';

class ChatCallModel {
  int? id;
  int? chatId;
  Chat? chat;
  int? creatorUserId;
  User? creatorUser;
  String? startDate;
  String? endDate;
  List<ChatCallParticipant>? participants;

  ChatCallModel({
    required this.id,
    required this.chatId,
    required this.chat,
    required this.creatorUserId,
    required this.creatorUser,
    required this.startDate,
    required this.endDate,
    required this.participants,
  });
  ChatCallModel.fromJson(mapData) {
    id = mapData["id"];
    chatId = mapData["chat_id"];
    chat = mapData["chat"] is Map ? Chat.fromJson(mapData["chat"]) : null;
    creatorUserId = mapData["creator_user_id"];
    creatorUser = mapData["creator_user"] is Map ? User.fromJson(mapData["creator_user"]) : null;
    startDate = mapData["start_date"];
    endDate = mapData["end_date"];
    var participantsJson = mapData["participants"];
    participants =
        participantsJson is List ? participantsJson.map((e) => ChatCallParticipant.fromJson(e)).toList() : [];
  }
  ChatCallParticipant? getCurrentParticipant() {
    return participants?.firstWhereOrNull((element) => element.userId == AppControllers.auth.user?.id);
  }
}
