import 'package:planner_messenger/models/auth/user.dart';

import '../chats/chat.dart';

class IncomingCallData {
  late User callerUser;
  late Chat chat;
  

  IncomingCallData({required this.callerUser, required this.chat});
  IncomingCallData.fromJson(Map json) {
    callerUser = User.fromJson(json["caller_user"]);
    chat = Chat.fromJson(json["chat"]);
    
  }
}
