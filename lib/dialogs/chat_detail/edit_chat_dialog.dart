import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:planner_messenger/controllers/edit_chat_controller.dart';

class EditChatDialog extends StatefulWidget {
  final EditChatController editChatController;
  final ScrollController? scrollController;

  const EditChatDialog({super.key, required this.editChatController, this.scrollController});

  @override
  State<EditChatDialog> createState() => _EditChatDialogState();
}

class _EditChatDialogState extends State<EditChatDialog> {
  late final _controller = widget.editChatController;
  @override
  Widget build(BuildContext context) {
    const emptySize = SizedBox(height: 10);
    return ListView(
      controller: widget.scrollController,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        left: 8,
                        child: TextButton(
                          onPressed: Get.back,
                          child: const Text("Cancel"),
                        )),
                    Text(
                      "Edit Group",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    Positioned(
                        right: 8,
                        child: TextButton(
                          onPressed: _controller.updateChat,
                          child: _controller.activeSaveButton.builder((loading, data, error, context) {
                            return Text(
                              "Save",
                              style: TextStyle(
                                color: data == true ? null : context.theme.disabledColor,
                              ),
                            );
                          }),
                        )),
                  ],
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
                  onTap: () => _controller.selectImage(context),
                  child: _controller.selectedGroupImage.builder((loading, data, error, context) {
                    if (data == null) {
                      var photoUrl = _controller.chat.getPhotoUrl();
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
                        backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl),
                        child: photoUrl == null ? const Icon(Icons.image) : null,
                      );
                    }
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).disabledColor.withOpacity(0.2),
                      backgroundImage: MemoryImage(data.bytes),
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
                  autofocus: false,
                  controller: _controller.chatNameController,
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                  ),
                  placeholder: "Group Name",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              emptySize,
            ],
          ),
        ),
      ],
    );
  }
}
