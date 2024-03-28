import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/controllers/edit_chat_controller.dart';
import 'package:planner_messenger/dialogs/chat_detail/edit_chat_dialog.dart';
import 'package:planner_messenger/models/chats/chat.dart';

import 'package:planner_messenger/models/chats/chat_detail.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/chat_message/starred_messages.dart';
import 'package:planner_messenger/views/chats/chat_media_view.dart';
import 'package:s_state/s_state.dart';

class ChatDetailView extends StatelessWidget {
  final SState<ChatDetail> chatDetailStream;
  final void Function(Chat newChat)? onUpdated;
  const ChatDetailView({super.key, required this.chatDetailStream, this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat Detail"),
          centerTitle: true,
          actions: [
            chatDetailStream.builder(
              (loading, data, error, context) {
                if (data == null) return const SizedBox();
                var user =
                    data.chat.users?.firstWhereOrNull((element) => element.userId == AppControllers.auth.user?.id);
                var canEditChat = data.chat.chatType == ChatType.private ? false : user?.role == UserChatRole.admin;
                if (!canEditChat) return const SizedBox();
                return TextButton(
                  onPressed: () {
                    AppUtils.showFlexibleDialog(
                      context: context,
                      initHeight: 0.99,
                      builder: (c, scrollController, p2) {
                        return EditChatDialog(
                          editChatController: EditChatController(
                            onSaved: onUpdated,
                            chat: data.chat,
                          ),
                        );
                      },
                    );
                  },
                  child: const Text("Edit"),
                );
              },
            )
          ],
        ),
        body: chatDetailStream.builder((loading, chatDetail, error, context) {
          if (chatDetail == null) return const SizedBox();
          var photoUrl = chatDetail.chat.getPhotoUrl();
          var users = chatDetail.chat.users ?? [];
          const emptySize = SizedBox(height: 10);

          return Center(
            child: Column(
              children: [
                emptySize,
                CircleAvatar(
                  radius: 60,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
                emptySize,
                Text(
                  chatDetail.chat.getChatName(),
                  style: context.textTheme.titleLarge,
                ),
                emptySize,
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => StarredMessagesView(chat: chatDetail.chat)),
                    leading: const Icon(Icons.star),
                    title: const Text("Starred Message"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                  ),
                ),
                Card(
                  child: ListTile(
                    onTap: () => Get.to(() => ChatMediaView(chat: chatDetail.chat)),
                    leading: const Icon(Icons.image_outlined),
                    title: const Text("Media, Links, Documents"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                  ),
                ),
                if (users.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Users",
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                          if (users.isNotEmpty)
                            ...List.generate(users.length, (index) {
                              var user = users[index].user;
                              var userPhotoUrl = users[index].user?.photo;
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl) : null,
                                    child: userPhotoUrl == null ? const Icon(Icons.person) : null,
                                  ),
                                  title: Text(user?.fullName ?? ""),
                                ),
                              );
                            })
                        ],
                      ),
                    ),
                  )
              ],
            ),
          );
        }));
  }
}
