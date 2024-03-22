class ChatJoinResponse {
  int? id;
  String? role;
  int? userId;
  int? chatId;
  int? teamId;
  int? addedBy;

  ChatJoinResponse({this.id, this.role, this.userId, this.chatId, this.teamId, this.addedBy});

  ChatJoinResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    userId = json['user_id'];
    chatId = json['chat_id'];
    teamId = json['team_id'];
    addedBy = json['added_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['role'] = role;
    data['user_id'] = userId;
    data['chat_id'] = chatId;
    data['team_id'] = teamId;
    data['added_by'] = addedBy;
    return data;
  }
}
