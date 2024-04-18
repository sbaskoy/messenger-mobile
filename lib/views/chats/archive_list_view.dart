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
  final _controller = AppControllers.chatList..loadChats(archive: true, refresh: true);

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        AppControllers.chatList.loadNextPage(archive: true);
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
        onRefresh: () => _controller.loadChats(archive: true, refresh: true),
        child: _controller.orderedArchiveChats.builder(
          AppUtils.sStateBuilder((data) {
            return ChatListWidget(
              chats: data,
              scrollController: _scrollController,
            );
          }),
        ),
      ),
    );
  }
}
