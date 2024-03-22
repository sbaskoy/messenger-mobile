import 'package:flutter/material.dart';
import 'package:planner_messenger/dialogs/create_chat/create_chat_dialog.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chats/archive_list_view.dart';
import 'package:planner_messenger/views/call_list_view.dart';

import 'chats/chat_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController tabController;
  var fabIcon = Icons.message;

  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 3)
      ..addListener(() {
        setState(() {
          switch (tabController.index) {
            case 0:
              fabIcon = Icons.camera_alt_outlined;
              break;
            case 1:
              fabIcon = Icons.chat;
              break;
            case 2:
              fabIcon = Icons.camera_alt_outlined;
              break;
            case 2:
              fabIcon = Icons.message;
              break;
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Planner",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.search),
          ),
          InkWell(
            onTap: () {
              AppUtils.showFlexibleDialog(
                context: context,
                builder: (c, scrollController, p2) {
                  return CreateChatDialog(
                    scrollController: scrollController,
                  );
                },
                initHeight: 1,
              );
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.add),
              ),
            ),
          ),
          PopupMenuButton(
              enabled: true,
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text(
                        "New Group",
                      ),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text("Linked devices"),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: InkWell(
                          onTap: () {
                            // Navigator.pop(context);
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen()));
                          },
                          child: const Text("Setting")),
                    )
                  ]),
        ],
        bottom: TabBar(
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(child: Text("Chats")),
            Tab(child: Text("Archive")),
            Tab(child: Text("Calls")),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          ChatListView(),
          ArchiveListView(),
          CallListView(),
        ],
      ),
    );
  }
}
