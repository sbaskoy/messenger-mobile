import 'auth/user.dart';

class TypingModel {
  User? user;
  bool? typing;
  TypingModel(this.user, this.typing);
  TypingModel.fromJson(mapData) {
    var userJson = mapData["user"];
    if (userJson is Map) {
      user = User.fromJson(userJson);
    }
    typing = mapData["typing"];
  }
}
