import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/config/push_notifications.dart';
import 'package:planner_messenger/dialogs/search/search_dialog.dart';

import '../constants/app_controllers.dart';
import '../dialogs/create_chat/create_chat_dialog.dart';
import '../utils/app_utils.dart';
import 'calls/call_list_view.dart';
import 'chats/archive_list_view.dart';
import 'chats/chat_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController tabController;
  var fabIcon = Icons.message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
          }
        });
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    flutterLocalNotificationsPlugin.cancelAll();
    var photoUrl = AppControllers.auth.user?.photo;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Passenger",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              AppUtils.showFlexibleDialog(
                context: context,
                builder: (c, scrollController, p2) {
                  return const SearchDialog();
                },
                initHeight: 1,
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.search),
            ),
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
          PopupMenuButton<int>(
              enabled: true,
              icon: const Icon(Icons.more_vert_outlined),
              position: PopupMenuPosition.under,
              splashRadius: 50,
              itemBuilder: (context) => [
                    // PopupMenuItem(
                    //   value: 1,
                    //   enabled: false,
                    //   child: Row(
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 15,
                    //         backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                    //         child: photoUrl == null ? const Icon(Icons.person) : null,
                    //       ),
                    //       const SizedBox(width: 10),
                    //       Text(
                    //         AppControllers.auth.user?.fullName ?? "",
                    //        // style: context.textTheme.bodyLarge,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    //const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 23,
                      onTap: () async {
                        var res =
                            await AppUtils.buildYesOrNoAlert(context, "Çıkış yapmak istediğinizden emin misiniz?");
                        if (res) {
                          AppControllers.auth.logout();
                        }
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: context.theme.colorScheme.error,
                        ),
                      ),
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
