import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_controllers.dart';
import '../../constants/app_services.dart';
import '../../controllers/users_controller.dart';
import '../../models/auth/user.dart';
import '../../models/chats/chat.dart';
import '../../utils/app_utils.dart';
import '../../views/chat_message/message_view.dart';
import '../../widgets/progress_indicator/progress_indicator.dart';

class CreatePrivateChatWidget extends StatefulWidget {
  final UsersController controller;
  final VoidCallback? createGroupChat;
  const CreatePrivateChatWidget({super.key, required this.controller, this.createGroupChat});

  @override
  State<CreatePrivateChatWidget> createState() => _CreatePrivateChatWidgetState();
}

class _CreatePrivateChatWidgetState extends State<CreatePrivateChatWidget> {
  // final UsersController _controller = UsersController()..listUsers();
  late Color containerColor = Theme.of(context).scaffoldBackgroundColor;

  bool onScroll(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollUpdateNotification) {
      if (scrollInfo.metrics.pixels > 0 && scrollInfo.metrics.pixels < scrollInfo.metrics.maxScrollExtent) {
        setState(() {
          containerColor = Theme.of(context).disabledColor.withOpacity(0.01);
        });
      } else {
        setState(() {
          containerColor = Theme.of(context).scaffoldBackgroundColor;
        });
      }
    }
    return true;
  }

  void _createPrivateChat(User user) async {
    try {
      AppProgressController.show();
      var chatResponse = await AppServices.chat.createChat(
        user.fullName ?? "",
        [user.id.toString()],
        ChatType.private,
      );
      if (chatResponse != null) {
        Get.back();
        Get.to(() => MessageView(chat: chatResponse));
        AppControllers.chatList.addChat(chatResponse);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    const emptySize = SizedBox(height: 10);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: containerColor,
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "Create Chat",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    Positioned(
                      left: 0,
                      child: TextButton(
                        onPressed: Get.back,
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
              emptySize,
              CupertinoSearchTextField(
                controller: widget.controller.searchTextField,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        emptySize,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotificationListener<ScrollNotification>(
              onNotification: onScroll,
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).disabledColor.withOpacity(0.1),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: widget.createGroupChat,
                          leading: const Icon(Icons.group),
                          title: const Text("Create Group"),
                        ),
                        const Divider(
                          height: 0,
                          indent: 72,
                        ),
                      ],
                    ),
                  ),
                  emptySize,
                  const Text("Users"),
                  emptySize,
                  widget.controller.filteredUsers.builder(AppUtils.sStateBuilder((data) {
                    return Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).disabledColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)),
                        child: AppUtils.appListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          items: data,
                          builder: (context, index, user) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () => _createPrivateChat(user),
                                  leading: CircleAvatar(
                                    backgroundImage: user.photo == null ? null : NetworkImage(user.photo!),
                                  ),
                                  title: Text(user.fullName ?? ""),
                                ),
                                const Divider(indent: 72, height: 2)
                              ],
                            );
                          },
                        ));
                  }))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
