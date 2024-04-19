import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import '../../controllers/users_controller.dart';
import 'create_group_chat_controller.dart';

class CreateGroupChatWidget extends StatefulWidget {
  final UsersController controller;
  final VoidCallback? onCancel;
  final VoidCallback? onNext;
  final CreateGroupChatController createGroupChatController;
  const CreateGroupChatWidget(
      {super.key, required this.controller, this.onCancel, this.onNext, required this.createGroupChatController});

  @override
  State<CreateGroupChatWidget> createState() => _CreateGroupChatWidgetState();
}

class _CreateGroupChatWidgetState extends State<CreateGroupChatWidget> {
  @override
  Widget build(BuildContext context) {
    const emptySize = SizedBox(height: 10);
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                height: 50,
                child: widget.createGroupChatController.activeCreateButton.builder(
                  AppUtils.sStateBuilder(
                    (data) => Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 8,
                          child: TextButton(
                            onPressed: widget.onCancel,
                            child: const Text("Cancel"),
                          ),
                        ),
                        Text(
                          "New Group",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20,
                              ),
                        ),
                        Positioned(
                            right: 8,
                            child: TextButton(
                              child: Text(
                                "Create",
                                style: TextStyle(
                                  color: !data ? Theme.of(context).disabledColor : null,
                                ),
                              ),
                              onPressed: () {
                                if (data == true) {
                                  widget.createGroupChatController.create();
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              emptySize,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  onTap: () => widget.createGroupChatController.selectImage(context),
                  child: widget.createGroupChatController.selectedGroupImage.builder((loading, data, error, context) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
                      backgroundImage: data == null ? null : MemoryImage(data.bytes),
                      child: data == null ? const Icon(Icons.image) : null,
                    );
                  }),
                ),
              ),
              emptySize,
              Text(
                "Enter group name",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              emptySize,
              SizedBox(
                height: 40,
                child: CupertinoTextField(
                  autofocus: true,
                  controller: widget.createGroupChatController.groupNameField,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                  ),
                  placeholder: "Group Name",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              emptySize,
              Text(
                "Members",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              emptySize,
              widget.createGroupChatController.buildMemberList(),
            ],
          ),
        ),
      ],
    );
  }
}
