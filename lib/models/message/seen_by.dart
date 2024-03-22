import '../auth/user.dart';

class SeenBy {
  int? id;
  int? messageId;
  int? userId;
  String? createdAt;
  User? user;

  SeenBy({this.id, this.messageId, this.userId, this.createdAt, this.user});

  SeenBy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageId = json['message_id'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message_id'] = messageId;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
