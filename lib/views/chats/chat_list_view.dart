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
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        AppControllers.chatList.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _controller.loadChats(refresh: true),
        child: _controller.orderedChats.builder(
          AppUtils.sStateBuilder((data) {
            return ChatListWidget(chats: data, scrollController: _scrollController);
          }),
        ),
      ),
    );
  }
}
