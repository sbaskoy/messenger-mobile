import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/utils/app_utils.dart';

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
  int? memberUserId;
  String? pinnedMessageId;
  int? isDeleted;
  //int? isArchived;
  List<Message>? messages;
  User? creatorUser;
  String? chatType;
  late int unSeenCount;
  User? memberUser;
  FileModel? photo;
  Message? pinnedMessage;
  List<ChatUser>? users;
  List<dynamic>? archived;
  Chat({
    this.id,
    this.createdAt,
    this.name,
    this.projectId,
    this.taskId,
    this.creatorUserId,
    this.pinnedMessageId,
    this.isDeleted,
    // this.isArchived,
    this.messages,
    this.unSeenCount = 0,
    this.pinnedMessage,
    this.users,
    this.memberUserId,
    this.chatType,
    this.creatorUser,
    this.memberUser,
    this.photo,
    this.archived,
  });

  Chat.fromJson(Map json) {
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    projectId = json['project_id'];
    taskId = json['task_id'];
    creatorUserId = json['creator_user_id'];
    memberUserId = json['member_user_id'];
    pinnedMessageId = json['pinned_message_id'].toString();
    isDeleted = json['is_deleted'];
    archived = json['archived'] is List ? json['archived'] : null;
    var jsonMessages = json["messages"];
    if (jsonMessages is List) {
      messages = jsonMessages.map((e) => Message.fromJson(e)).toList();
    }
    var jsonUsers = json["users"];
    if (jsonUsers is List) {
      users = jsonUsers.map((e) => ChatUser.fromJson(e)).toList();
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
    if (chatType == ChatType.group) {
      return AppUtils.getImageUrl(photo?.fileLink);
    }
    if (creatorUserId == user?.id) {
      return AppUtils.getImageUrl(memberUser?.photo);
    } else {
      return AppUtils.getImageUrl(creatorUser?.photo);
    }
  }

  int? getPrivateChatMemberId() {
    return creatorUserId == AppControllers.auth.user?.id ? memberUserId : creatorUserId;
  }

  String getChatName() {
    if (chatType == ChatType.group) return name ?? "";
    return creatorUserId == AppControllers.auth.user?.id ? (memberUser?.fullName ?? "") : (creatorUser?.fullName ?? "");
  }

  Chat copy(Chat? chat) {
    return Chat(
      id: chat?.id ?? id,
      createdAt: chat?.createdAt ?? createdAt,
      name: chat?.name ?? name,
      creatorUserId: chat?.creatorUserId ?? creatorUserId,
      archived: chat?.archived ?? archived,
      isDeleted: chat?.isDeleted ?? isDeleted,
      memberUserId: chat?.memberUserId ?? memberUserId,
      messages: (chat?.messages?.isNotEmpty ?? false) ? chat?.messages : messages,
      pinnedMessage: chat?.pinnedMessage ?? pinnedMessage,
      pinnedMessageId: chat?.pinnedMessageId ?? pinnedMessageId,
      projectId: chat?.projectId ?? projectId,
      taskId: chat?.taskId ?? taskId,
      unSeenCount: chat?.unSeenCount != null ? chat!.unSeenCount : unSeenCount,
      users: (chat?.users?.isNotEmpty ?? false) ? chat?.users : users,
      chatType: chat?.chatType ?? chatType,
      creatorUser: chat?.creatorUser ?? creatorUser,
      memberUser: chat?.memberUser ?? memberUser,
      photo: chat?.photo ?? photo,
    );
  }

  ChatUser? getCurrentChatUser() {
    return users?.firstWhereOrNull((element) => element.userId == AppControllers.auth.user?.id);
  }

  bool isNotificationsActive() {
    var chatUser = getCurrentChatUser();
    if (chatUser == null) return false;
    return chatUser.disableNotifications != 1;
  }

  bool get isArchived => archived?.isNotEmpty ?? false;
}
