import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/models/message/message.dart';

import '../file_model.dart';

class ChatType {
  ChatType._();
  static String get private => "private";
  static String get group => "group";
}

class Chat {
  int? id;
  String? createdAt;
  String? name;
  String? projectId;
  String? taskId;
  int? creatorUserId;
  String? pinnedMessageId;
  int? isDeleted;
  int? isArchived;
  List<Message>? messages;
  User? creatorUser;
  String? chatType;
  late int unSeenCount;
  User? memberUser;
  FileModel? photo;
  Message? pinnedMessage;

  Chat({
    this.id,
    this.createdAt,
    this.name,
    this.projectId,
    this.taskId,
    this.creatorUserId,
    this.pinnedMessageId,
    this.isDeleted,
    this.isArchived,
    this.messages,
    this.unSeenCount = 0,
    this.pinnedMessage,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    creatorUserId = json['creator_user_id'];
    pinnedMessageId = json['pinned_message_id'].toString();
    isDeleted = json['is_deleted'];
    isArchived = json['is_archived'];
    var jsonMessages = json["messages"];
    if (jsonMessages is List) {
      messages = jsonMessages.map((e) => Message.fromJson(e)).toList();
    }
    var jsonCreatorUser = json["creator_user"];
    if (jsonCreatorUser != null) {
      creatorUser = User.fromJson(jsonCreatorUser);
    }
    var jsonMemberUser = json["member_user"];
    if (jsonMemberUser != null) {
      memberUser = User.fromJson(jsonMemberUser);
    }
    var jsonFile = json["photo"];
    if (jsonFile != null) {
      photo = FileModel.fromJson(jsonFile);
    }
    pinnedMessage = json["pinned_message"] != null ? Message.fromJson(json["pinned_message"]) : null;
    unSeenCount = json["un_seen_count"] ?? 0;
    chatType = json["chat_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['project_id'] = projectId;
    data['task_id'] = taskId;
    data['creator_user_id'] = creatorUserId;
    data['pinned_message_id'] = pinnedMessageId;
    data['is_deleted'] = isDeleted;
    data['is_archived'] = isArchived;
    return data;
  }

  String? getPhotoUrl() {
    var user = AppControllers.auth.user;
    if (photo?.fileLink != null) {
      return photo!.fileLink?.replaceAll(("viewFile/user_token"), "viewImage/${user?.id}-${user?.tenantId}");
    }
    if (memberUser?.photo != null) {
      return memberUser?.photo?.replaceAll("viewFile/user_token", "viewImage/${user?.id}-${user?.tenantId}");
    }
    return null;
  }
}
