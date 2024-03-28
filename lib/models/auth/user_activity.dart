class UserActivity {
  int? id;
  int? userId;
  String? lastSeen;

  UserActivity({required this.id, required this.userId, required this.lastSeen});
  UserActivity.fromJson(json) {
    id = json["id"];
    userId = json["user_id"];
    lastSeen = json["last_seen"];
  }
}
