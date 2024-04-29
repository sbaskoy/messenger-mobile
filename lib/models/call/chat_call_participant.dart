import 'package:planner_messenger/models/auth/user.dart';

class ChatParticipantStatus {
  ChatParticipantStatus._();
  static String get active => "active";
  static String get inactive => "inactive";
  static String get calling => "calling";
}

class ChatCallParticipant {
  int? id;
  int? userId;
  int? callId;
  User? user;
  String? joinDate;
  String? leaveDate;
  String? status;

  ChatCallParticipant({
    this.id,
    this.userId,
    this.callId,
    this.user,
    this.joinDate,
    this.leaveDate,
    this.status,
  });
  ChatCallParticipant.fromJson(mapData) {
    id = mapData["id"];
    userId = mapData["user_id"];
    callId = mapData["call_id"];
    user = mapData["user"] is Map ? User.fromJson(mapData["user"]) : null;
    joinDate = mapData["join_date"];
    leaveDate = mapData["leave_date"];
    status = mapData["status"];
  }
}
