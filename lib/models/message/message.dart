

import 'package:flutter/cupertino.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/models/message/chat_message_attachment.dart';
import 'package:planner_messenger/models/message/message_type.dart';
import 'package:s_state/s_state.dart';

import '../auth/user.dart';
import '../chats/chat.dart';
import 'seen_by.dart';

class Message {
  int? chatId;
  String? _message;
  int? id;
  int? messageTypeId;
  String? createdAt;
  int? createdUserId;
  List<SeenBy>? seenBy;
  MessageType? messageType;
  User? user;
  Message? reply;
  List<ChatMessageAttachment>? attachments;
  List<IFilePickerItem>? sendingAttachments;
  Chat? chat;
  late bool isDeleted;
  late bool isForwarded;
  User? deletedBy;
  Message({
    this.chatId,
    this.id,
    this.messageTypeId,
    String? message,
    this.createdAt,
    this.createdUserId,
    this.seenBy,
    this.messageType,
    this.user,
    this.reply,
    this.attachments,
    this.sendingAttachments,
    this.isDeleted = false,
    this.isForwarded = false,
    this.deletedBy,
  }) {
    _message = message;
  }

  final isSelected = SState(false);

  GlobalKey widgetKey = GlobalKey();

  bool isSystemMessage() => false;

  String get message => isDeleted ? "This message has been deleted by ${deletedBy?.fullName}" : _message ?? "";

  Message.fromJson(Map json) {
    chatId = json['chat_id'];
    _message = json['message'];
    id = json['id'];
    messageTypeId = json['message_type_id'];
    createdAt = json['created_at'];
    createdUserId = json['created_user_id'];
    if (json['seen_by'] != null) {
      seenBy = <SeenBy>[];
      json['seen_by'].forEach((v) {
        seenBy!.add(SeenBy.fromJson(v));
      });
    }
    messageType = json['message_type'] != null ? MessageType.fromJson(json["message_type"]) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    reply = json['reply'] != null ? Message.fromJson(json['reply']) : null;
    var attachmentsJson = json["attachments"];
    if (attachmentsJson is List) {
      attachments = attachmentsJson.map((e) => ChatMessageAttachment.fromJson(e)).toList();
    }
    var chatJsonResponse = json["chat"];
    if (chatJsonResponse is Map) {
      chat = Chat.fromJson(chatJsonResponse);
    }
    isDeleted = json["is_deleted"] ?? false;
    isForwarded = json["is_forwarded"] ?? false;
    deletedBy = json['deleted_by'] != null ? User.fromJson(json['deleted_by']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['message'] = _message;
    data['id'] = id;
    data['message_type_id'] = messageTypeId;
    data['created_at'] = createdAt;
    data['created_user_id'] = createdUserId;
    if (seenBy != null) {
      data['seen_by'] = seenBy!.map((v) => v.toJson()).toList();
    }
    data['message_type'] = messageType;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }

  final isSended = SState(true);
  final sendProgress = SState(0);
}
