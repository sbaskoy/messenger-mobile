import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/chats/chat_detail.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';

import '../constants/app_controllers.dart';
import '../views/chat_message/message_view.dart';

class ChatUserInfoDialog extends StatefulWidget {
  final ChatUser chatUser;
  final ChatDetail chatDetail;
  final void Function(ChatUser chatUser)? onRemovedUser;
  final void Function(ChatUser chatUser)? onUpdateUser;
  const ChatUserInfoDialog(
      {super.key, required this.chatUser, required this.chatDetail, this.onRemovedUser, this.onUpdateUser});

  @override
  State<ChatUserInfoDialog> createState() => _ChatUserInfoDialogState();
}

class _ChatUserInfoDialogState extends State<ChatUserInfoDialog> {
  late final chatUser = widget.chatUser;
  late final user = chatUser.user;
  late final chat = widget.chatDetail.chat;
  late final currentChatUser = widget.chatDetail.chatUser;
  void _removeUserFromChat() async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.leaveChat(chat.id.toString(), userId: user?.id);
      if (response != null) {
        widget.onRemovedUser?.call(chatUser);
        Get.back();
      }
    } catch (error) {
      AppUtils.showErrorSnackBar(error);
    } finally {
      AppProgressController.hide();
    }
  }

  void _updateUserRolToChat(String role) async {
    try {
      if (user == null) return;
      AppProgressController.show();
      var response = await AppServices.chat.updateChatUserRole(
        chatId: chat.id.toString(),
        userId: user!.id!,
        role: role,
      );
      if (response != null) {
        chatUser.role = role;
        widget.onUpdateUser?.call(chatUser);
        Get.back();
      }
    } catch (error) {
      AppUtils.showErrorSnackBar(error);
    } finally {
      AppProgressController.hide();
    }
  }

  void _createChat() async {
    try {
      AppProgressController.show();
      var chatResponse = await AppServices.chat.createChat(
        user?.fullName ?? "",
        [user!.id!.toString()],
        ChatType.private,
      );
      if (chatResponse != null) {
        Get.back();
        Get.to(() => MessageView(chatId: chatResponse.id!));
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
    final userPhoto = user?.photo;
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: userPhoto != null ? NetworkImage(userPhoto) : null,
            child: userPhoto == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user?.fullName ?? ""),
        ),
        const Divider(),
        ListTile(
          onTap: _createChat,
          leading: const Icon(Icons.chat),
          title: const Text("Start Chat"),
        ),
        if (currentChatUser?.role == UserChatRole.admin)
          chatUser.role != UserChatRole.admin
              ? ListTile(
                  onTap: () => _updateUserRolToChat(UserChatRole.admin),
                  leading: const Icon(Icons.person_3),
                  title: const Text("Make Group Admin"),
                )
              : ListTile(
                  onTap: () => _updateUserRolToChat(UserChatRole.user),
                  leading: const Icon(Icons.person_3),
                  title: const Text("Remove Admin Permission"),
                ),
        const Divider(),
        if (currentChatUser?.role == UserChatRole.admin)
          ListTile(
            onTap: _removeUserFromChat,
            leading: Icon(Icons.remove_circle_sharp, color: context.theme.colorScheme.error),
            title: Text(
              "Remove From Group",
              style: TextStyle(
                color: context.theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
