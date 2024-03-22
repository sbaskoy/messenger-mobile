import 'package:flutter/material.dart';

import 'package:planner_messenger/constants/app_controllers.dart';

import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chats/chat_list_widget.dart';

class ArchiveListView extends StatefulWidget {
  const ArchiveListView({super.key});

  @override
  State<ArchiveListView> createState() => _ArchiveListViewState();
}

class _ArchiveListViewState extends State<ArchiveListView> {
  final _controller = AppControllers.chatList..loadChats(archive: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.orderedArchiveChats.builder(
        AppUtils.sStateBuilder((data) {
          return ChatListWidget(chats: data);
        }),
      ),
    );
  }
}
