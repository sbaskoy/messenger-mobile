import '../file_model.dart';
import 'message.dart';

class ChatMessageAttachment {
  int? id;
  int? messageId;
  String? fileId;
  FileModel? file;
  Message? message;

  ChatMessageAttachment(
      {required this.id, required this.messageId, required this.fileId, required this.file, required this.message});
  ChatMessageAttachment.fromJson(json) {
    id = json["id"];
    messageId = json["message_id"];
    fileId = json["file_id"].toString();

    var fileJson = json["file"];
    if (fileJson is Map) {
      file = FileModel.fromJson(fileJson);
    }

    var messageJson = json["message"];
    if (messageJson is Map) {
      message = Message.fromJson(messageJson);
    }
  }
}
