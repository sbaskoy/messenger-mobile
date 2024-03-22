import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/models/auth/user.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

import '../../constants/app_controllers.dart';
import '../../utils/app_utils.dart';
import '../../views/chat_message/message_view.dart';
import '../file_select/file_select_dialog.dart';

class CreateGroupChatController {
  final groupMembers = SState<List<User>>([]);
  final selectedGroupImage = SState<File>();
  final TextEditingController groupNameField = TextEditingController();
  void selectUser(User user) {
    var users = groupMembers.valueOrNull ?? [];
    if (users.any((element) => element.id == user.id)) {
      users.removeWhere((e) => e.id == user.id);
    } else {
      users.add(user);
    }
    groupMembers.setState(users);
  }

  bool isSelected(User user) => groupMembers.valueOrNull!.any((element) => element.id == user.id);

  void create() async {
    try {
      AppProgressController.show();
      var chatResponse = await AppServices.chat.createChat(
        groupNameField.text,
        groupMembers.valueOrNull!.map((e) => e.id.toString()).toList(),
        ChatType.group,
        file: selectedGroupImage.valueOrNull,
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

  void selectImage(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      AppUtils.showFlexibleDialog(
          context: context,
          initHeight: 0.5,
          builder: (c, scrollController, p2) {
            return FileSelectDialog(
              canSelectFile: false,
              onSelected: (selected) {
                if (selected.isNotEmpty) {
                  selectedGroupImage.setState(selected.first);
                }
              },
            );
          });
    });
  }

  Widget buildMemberList() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: groupMembers.builder(AppUtils.sStateBuilder((data) {
          return AnimatedContainer(
            height: data.isNotEmpty ? 70 : 0,
            duration: const Duration(milliseconds: 200),
            width: Get.width,
            child: AppUtils.appListView(
              items: data,
              axis: Axis.horizontal,
              builder: (context, index, user) {
                return InkWell(
                  onTap: () => selectUser(user),
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
          );
        })));
  }
}
