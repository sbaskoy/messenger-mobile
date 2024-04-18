import '../auth/user.dart';

class UserChatRole {
  UserChatRole._();
  static String get admin => "admin";
  static String get moderator => "moderator";
  static String get user => "user";
  static String get removed => "removed";
}

class ChatUser {
  int? id;
  int? userId;
  int? chatId;
  int? addedBy;
  String? role;
  String? createdAt;
  User? user;
  User? addedByUser;
  int? disableNotifications;

  ChatUser({
    this.id,
    this.userId,
    this.chatId,
    this.addedBy,
    this.role,
    this.createdAt,
    this.user,
    this.addedByUser,
    this.disableNotifications,
  });
  ChatUser.fromJson(json) {
    id = json["id"];
    userId = json["user_id"];
    chatId = json["chat_id"];
    addedBy = json["added_by"];
    role = json["role"];
    createdAt = json["created_at"];
    disableNotifications = json["disable_notifications"];
    var userJson = json["user"];
    if (userJson is Map) {
      user = User.fromJson(userJson);
    }
    var addedByUserJson = json["added_by_user"];
    if (addedByUser is Map) {
      addedByUser = User.fromJson(addedByUserJson);
    }
  }
}
