import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/models/message/chat_message_attachment.dart';
import 'package:planner_messenger/models/message/message_type.dart';
import 'package:s_state/s_state.dart';

import '../../constants/app_services.dart';
import '../auth/user.dart';
import 'seen_by.dart';

class Message {
  int? chatId;
  String? message;
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

  Message({
    this.chatId,
    this.message,
    this.id,
    this.messageTypeId,
    this.createdAt,
    this.createdUserId,
    this.seenBy,
    this.messageType,
    this.user,
    this.reply,
    this.attachments,
    this.sendingAttachments,
  });

  bool isSystemMessage() => false;

  Message.fromJson(Map json) {
    chatId = json['chat_id'];
    message = json['message'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['message'] = message;
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
}
