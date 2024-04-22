import 'package:flutter/material.dart';


import 'package:planner_messenger/constants/app_controllers.dart';

import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chats/chat_list_widget.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> with WidgetsBindingObserver {
  final _controller = AppControllers.chatList..loadChats(refresh: true);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        AppControllers.chatList.loadNextPage();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller.loadChats(refresh: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
