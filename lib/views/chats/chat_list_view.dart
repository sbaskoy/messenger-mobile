import 'package:flutter/material.dart';

import 'package:planner_messenger/constants/app_controllers.dart';

import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chats/chat_list_widget.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final _controller = AppControllers.chatList..loadChats();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.orderedChats.builder(
        AppUtils.sStateBuilder((data) {
          return ChatListWidget(chats: data);
        }),
      ),
    );
  }
}
