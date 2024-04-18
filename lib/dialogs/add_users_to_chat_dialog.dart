import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';

import '../../controllers/users_controller.dart';
import '../../models/auth/user.dart';

import '../../widgets/progress_indicator/progress_indicator.dart';
import '../models/chats/chat.dart';
import '../utils/app_utils.dart';

class AddMemberToChatDialog extends StatefulWidget {
  final UsersController controller;
  final void Function(List<ChatUser> users)? onDone;
  final Chat chat;
  const AddMemberToChatDialog({super.key, required this.controller, this.onDone, required this.chat});

  @override
  State<AddMemberToChatDialog> createState() => _AddMemberToChatDialogState();
}

class _AddMemberToChatDialogState extends State<AddMemberToChatDialog> {
  // final UsersController _controller = UsersController()..listUsers();
  late Color containerColor = Theme.of(context).scaffoldBackgroundColor;
  final List<User> _selectedUsers = [];
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

  void _addMembers() async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.addMembersToChat(widget.chat.id!.toString(), _selectedUsers);
      if (response != null) {
        for (var chatUser in response) {
          var user = _selectedUsers.firstWhereOrNull((element) => element.id == chatUser.userId);
          var addedBy = _selectedUsers.firstWhereOrNull((element) => element.id == chatUser.addedBy);
          chatUser.user = user;
          chatUser.addedByUser = addedBy;
        }
        widget.onDone?.call(response);
        Get.back();
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  void _selectUser(User user) {
    if (_selectedUsers.any((element) => element.id == user.id)) {
      _selectedUsers.removeWhere((element) => element.id == user.id);
    } else {
      _selectedUsers.add(user);
    }
    setState(() {});
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
                      "Add Members",
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
                    Positioned(
                      right: 0,
                      child: TextButton(
                        onPressed: _addMembers,
                        child: const Text("Add"),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedContainer(
            height: _selectedUsers.isNotEmpty ? 70 : 0,
            duration: const Duration(milliseconds: 200),
            width: Get.width,
            child: AppUtils.appListView(
              items: _selectedUsers,
              axis: Axis.horizontal,
              builder: (context, index, user) {
                return InkWell(
                  onTap: () => _selectUser(user),
                  child: SizedBox(
                    height: 60,
                    width: 70,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: user.photo == null ? null : NetworkImage(user.photo!),
                            ),
                            Text(
                              user.fullName ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotificationListener<ScrollNotification>(
              onNotification: onScroll,
              child: ListView(
                children: [
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
                            var isUserSelected = _selectedUsers.any((i) => i.id == user.id);
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () => _selectUser(user),
                                  leading: CircleAvatar(
                                    backgroundImage: user.photo == null ? null : NetworkImage(user.photo!),
                                  ),
                                  trailing: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).disabledColor.withOpacity(0.2),
                                        ),
                                        color: isUserSelected ? Theme.of(context).primaryColorDark : null),
                                    child: isUserSelected ? const Icon(Icons.done) : null,
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
