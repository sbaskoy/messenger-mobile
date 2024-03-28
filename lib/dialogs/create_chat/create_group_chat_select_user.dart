import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/dialogs/create_chat/create_group_chat_controller.dart';

import '../../controllers/users_controller.dart';
import '../../models/auth/user.dart';
import '../../utils/app_utils.dart';

class CreateGroupSelectUser extends StatefulWidget {
  final UsersController controller;
  final CreateGroupChatController createGroupChatController;
  final VoidCallback? onCancel;
  final Function()? onNext;

  const CreateGroupSelectUser(
      {super.key, required this.controller, this.onCancel, this.onNext, required this.createGroupChatController});

  @override
  State<CreateGroupSelectUser> createState() => _CreateGroupSelectUserState();
}

class _CreateGroupSelectUserState extends State<CreateGroupSelectUser> {
  void _selectUser(User user) {
    widget.createGroupChatController.selectUser(user);
  }

  @override
  Widget build(BuildContext context) {
    const emptySize = SizedBox(height: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                height: 50,
                child: widget.createGroupChatController.groupMembers.builder(
                  AppUtils.sStateBuilder(
                    (data) => Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 8,
                          child: TextButton(
                              onPressed: widget.onCancel,
                              child: const Text(
                                "Cancel",
                              )),
                        ),
                        Text(
                          "Add Members",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                              ),
                        ),
                        Positioned(
                          right: 8,
                          child: TextButton(
                            onPressed: () {
                              if (data.isNotEmpty) {
                                widget.onNext?.call();
                              }
                            },
                            child: Text(
                              "Next",
                              style: TextStyle(
                                color: data.isEmpty ? Theme.of(context).disabledColor : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
        widget.createGroupChatController.buildMemberList(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.controller.filteredUsers.builder(
              AppUtils.sStateBuilder((data) {
                return widget.createGroupChatController.groupMembers.builder(
                  AppUtils.sStateBuilder((members) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: AppUtils.appListView(
                        items: data,
                        builder: (context, index, user) {
                          var userSelected = widget.createGroupChatController.isSelected(user);
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
                                      color: userSelected ? Theme.of(context).primaryColorDark : null),
                                  child: userSelected ? const Icon(Icons.done) : null,
                                ),
                                title: Text(
                                  user.fullName ?? "",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const Divider(indent: 72, height: 2)
                            ],
                          );
                        },
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        )
      ],
    );
  }
}
