import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/controllers/edit_chat_controller.dart';
import 'package:planner_messenger/controllers/users_controller.dart';
import 'package:planner_messenger/dialogs/chat_detail/edit_chat_dialog.dart';
import 'package:planner_messenger/dialogs/add_users_to_chat_dialog.dart';
import 'package:planner_messenger/dialogs/chat_user_info_dialog.dart';
import 'package:planner_messenger/models/chats/chat.dart';

import 'package:planner_messenger/models/chats/chat_detail.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/chat_message/starred_messages.dart';
import 'package:planner_messenger/views/chats/chat_media_view.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

class ChatDetailView extends StatefulWidget {
  final SState<ChatDetail> chatDetailStream;
  final void Function(Chat newChat)? onUpdated;
  const ChatDetailView({super.key, required this.chatDetailStream, this.onUpdated});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  void _enableNotification(ChatDetail chatDetail) async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.enableChatNotification(chatDetail.chat.id.toString());
      if (response) {
        if (chatDetail.chatUser != null) {
          chatDetail.chatUser!.disableNotifications = 0;
        }
        widget.chatDetailStream.setState(chatDetail);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  void _disableNotification(ChatDetail chatDetail) async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.disableChatNotification(chatDetail.chat.id.toString());
      if (response) {
        if (chatDetail.chatUser != null) {
          chatDetail.chatUser!.disableNotifications = 1;
        }
        widget.chatDetailStream.setState(chatDetail);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  void _leaveChat(ChatDetail chatDetail) async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.leaveChat(chatDetail.chat.id.toString());
      if (response != null) {
        if (chatDetail.chatUser != null) {
          chatDetail.chatUser!.role = UserChatRole.removed;
        }
        chatDetail.chat.users?.removeWhere((element) => element.id == chatDetail.chatUser?.userId);
        widget.chatDetailStream.setState(chatDetail);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Chat Detail"),
          centerTitle: true,
          actions: [
            widget.chatDetailStream.builder(
              (loading, data, error, context) {
                if (data == null) return const SizedBox();
                var user = data.chatUser;
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
                            onSaved: widget.onUpdated,
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
        body: widget.chatDetailStream.builder((loading, chatDetail, error, context) {
          if (chatDetail == null) return const SizedBox();
          var photoUrl = chatDetail.chat.getPhotoUrl();
          var users = chatDetail.chat.users?.where((element) => element.role != UserChatRole.removed).toList() ?? [];
          const emptySize = SizedBox(height: 10);
          var user = chatDetail.chatUser;
          var canEditChat = chatDetail.chat.chatType == ChatType.private ? false : user?.role == UserChatRole.admin;

          var isNotificationActive = chatDetail.chatUser?.disableNotifications != 1;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  emptySize,
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
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
                      title: const Text("Media and Docs"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                    ),
                  ),
                  if (chatDetail.chatUser?.role != UserChatRole.removed)
                    Card(
                      child: ListTile(
                        onTap: () {
                          if (isNotificationActive) {
                            _disableNotification(chatDetail);
                          } else {
                            _enableNotification(chatDetail);
                          }
                        },
                        title: isNotificationActive
                            ? Text(
                                "Disable Notifications",
                                style: TextStyle(color: context.theme.colorScheme.error),
                              )
                            : Text(
                                "Enable Notifications",
                                style: TextStyle(color: context.theme.colorScheme.primary),
                              ),
                      ),
                    ),
                  if (chatDetail.chat.chatType == ChatType.group && chatDetail.chatUser?.role != UserChatRole.removed)
                    Card(
                      child: ListTile(
                          onTap: () async {
                            var res = await AppUtils.buildYesOrNoAlert(
                                context, "Bu sohbetten ayrılmak istediğinize emin misiniz?");
                            if (res == true) {
                              _leaveChat(chatDetail);
                            }
                          },
                          title: Text(
                            "Leave Group",
                            style: TextStyle(color: context.theme.colorScheme.error),
                          )),
                    ),
                  if (users.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${users.length} Members",
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        if (canEditChat)
                          Card(
                            child: ListTile(
                              onTap: () {
                                if (!canEditChat) return;
                                AppUtils.showFlexibleDialog(
                                  context: context,
                                  initHeight: 1,
                                  builder: (c, scrollController, p2) {
                                    return AddMemberToChatDialog(
                                      controller: UsersController()..listUsers(),
                                      chat: chatDetail.chat,
                                      onDone: (users) {
                                        chatDetail.chat.users!.addAll(users);
                                        widget.chatDetailStream.setState(chatDetail);
                                        widget.onUpdated?.call(chatDetail.chat);
                                      },
                                    );
                                  },
                                );
                              },
                              leading: const Icon(Icons.add),
                              title: const Text("Add Members"),
                            ),
                          ),
                        ...List.generate(users.length, (index) {
                          var user = users[index].user;
                          var userPhotoUrl = users[index].user?.photo;
                          return Card(
                            child: IgnorePointer(
                              ignoring: chatDetail.chat.chatType == ChatType.private,
                              child: ListTile(
                                onTap: () {
                                  AppUtils.showFlexibleDialog(
                                    context: context,
                                    builder: (c, scrollController, p2) {
                                      return ChatUserInfoDialog(
                                        chatUser: users[index],
                                        chatDetail: chatDetail,
                                        onRemovedUser: (chatUser) {
                                          var chatUsers = chatDetail.chat.users ?? [];
                                          chatUsers.removeWhere((element) => element.id == chatUser.id);
                                          chatDetail.chat.users = chatUsers;
                                          widget.chatDetailStream.setState(chatDetail);
                                          widget.onUpdated?.call(chatDetail.chat);
                                        },
                                        onUpdateUser: (chatUser) {
                                          var chatUsers = chatDetail.chat.users ?? [];
                                          var index = chatUsers.indexWhere((element) => element.id == chatUser.id);
                                          chatDetail.chat.users![index] = chatUser;
                                          widget.chatDetailStream.setState(chatDetail);
                                          widget.onUpdated?.call(chatDetail.chat);
                                        },
                                      );
                                    },
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl) : null,
                                  child: userPhotoUrl == null ? const Icon(Icons.person) : null,
                                ),
                                title: Text(user?.fullName ?? ""),
                              ),
                            ),
                          );
                        })
                      ],
                    )
                ],
              ),
            ),
          );
        }));
  }
}
