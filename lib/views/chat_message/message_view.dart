import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:multi_image_layout/multi_image_layout.dart';

import 'package:planner_messenger/controllers/message_controller.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chat_message/message_info.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:planner_messenger/views/chats/chat_detail_view.dart';
import 'package:planner_messenger/widgets/buttons/custom_icon_button.dart';
import 'package:planner_messenger/widgets/buttons/custom_text_button.dart';
import 'package:planner_messenger/widgets/list_view/scrollable_list_view.dart';

import 'package:planner_messenger/widgets/progress_indicator/centered_progress_indicator.dart';
import 'package:planner_messenger/widgets/texts/centered_error_text.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';

import '../../models/chats/chat.dart';

import '../../models/chats/chat_detail.dart';
import 'message_bubble.dart';
import 'message_image_view.dart';

class MessageView extends StatefulWidget {
  final Chat chat;
  final int? loadMessageId;
  const MessageView({super.key, required this.chat, this.loadMessageId});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> with WidgetsBindingObserver {
  late final _controller = MessageController(chat: widget.chat)..loadMessages(loadMessageId: widget.loadMessageId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller.loadMessages();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    // _controller.readAllMessage();

    return Scaffold(
      appBar: AppBar(
        title: _controller.chatDetail.builder((loading, data, error, context) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildChatImage(data?.chat),
            title: _buildChatTitle(data?.chat),
            subtitle: _buildChatSubTitle(data),
          );
        }),
      ),
      body: Column(
        children: [
          _controller.chatDetail.builder(
            (loading, data, error, context) {
              return _buildPinnedMessage(data);
            },
          ),
          Expanded(
            child: Stack(
              children: [
                _buildMessageListWithIndexedView(),
                Positioned(
                  bottom: 5,
                  right: 0,
                  child: _controller.showBottomButton.builder((loading, data, error, context) {
                    return AnimatedCrossFade(
                      firstChild: const SizedBox(width: 40, height: 40),
                      secondChild: CustomIconButton(
                        icon: Icons.arrow_downward,
                        onPressed: _controller.scrollToBottom,
                      ),
                      crossFadeState: data == true ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: Durations.medium2,
                    );
                  }),
                ),
              ],
            ),
          ),
          _controller.replyMessage.builder(
            (loading, data, error, context) {
              if (data != null) {
                return ReplyMessageBubble(
                  data: data,
                  hideStartBorder: true,
                  trailing: InkWell(
                    onTap: () => _controller.replyMessage.setState(null),
                    child: const Icon(Icons.close),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return _controller.chatDetail.builder(
      (loading, data, error, context) {
        var currentUser = data?.chatUser;
        if (currentUser?.role == UserChatRole.removed) {
          return const Card(child: Text("You can not send message this group"));
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: const BoxDecoration(
              //color: context.theme.appBarTheme.backgroundColor,
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  CloseKeyboardWidget.closeKeyboard(context);
                  AppUtils.showFlexibleDialog(
                    context: context,
                    builder: (c, scrollController, p2) {
                      return FileSelectDialog(
                        onSelected: (selected) {
                          Get.to(
                              () => MessageFilesView(
                                    files: selected,
                                    controller: _controller,
                                  ),
                              transition: Transition.downToUp);
                        },
                      );
                    },
                  );
                },
                child: SizedBox(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 25,
                      color: Theme.of(context).disabledColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 35,
                    maxHeight: 300,
                  ),
                  child: CupertinoTextField(
                    onSubmitted: (value) => _controller.sendMessage(),
                    controller: _controller.messageTextController,
                    placeholder: "Write a message ....",
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _controller.messageText.builder(
                (loading, data, error, context) {
                  return AnimatedCrossFade(
                    firstChild: InkWell(
                      onTap: () async {
                        CloseKeyboardWidget.closeKeyboard(context);
                        final photo = await FileSelectDialogController.selectPhotoFromCamera();
                        if (photo != null) {
                          Get.to(
                            () => MessageFilesView(
                              files: [photo],
                              controller: _controller,
                            ),
                            transition: Transition.downToUp,
                          );
                        }
                      },
                      child: SizedBox(
                        height: 35,
                        width: 35,
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_sharp,
                            size: 25,
                            color: Theme.of(context).disabledColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    secondChild: InkWell(
                      onTap: () => _controller.sendMessage(),
                      child: Container(
                        // padding: const EdgeInsets.all(8),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(color: context.theme.primaryColor, shape: BoxShape.circle),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: (data?.isEmpty ?? false) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatImage(Chat? chat) {
    var photoUrl = chat?.getPhotoUrl();
    return CircleAvatar(
      backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
      child: photoUrl == null ? const Icon(Icons.person) : null,
    );
  }

  Widget _buildChatTitle(Chat? chat) => InkWell(
        onTap: () {
          if (chat != null) {
            Get.to(
              () => ChatDetailView(
                chatDetailStream: _controller.chatDetail,
                onUpdated: _controller.chatUpdated,
              ),
            );
          }
        },
        child: Text(
          chat?.getChatName() ?? "",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
        ),
      );

  Widget _buildChatSubTitle(ChatDetail? data) {
    if (data == null) return const SizedBox();

    var users = data.chat.users
            ?.where((element) => element.role != UserChatRole.removed)
            .map((e) => e.user?.fullName)
            .toList()
            .join((", ")) ??
        "";
    var lastSeen = data.userActivity?.lastSeen ?? "";
    lastSeen = lastSeen == "online"
        ? lastSeen
        : lastSeen.isNotEmpty
            ? "Last seen ${lastSeen.dateFormat(CustomDateFormats.yyyyMMddHHmm)}"
            : "";
    var text = data.chat.chatType == ChatType.private ? lastSeen : users;
    return InkWell(
      onTap: () {
        Get.to(
          () => ChatDetailView(
            chatDetailStream: _controller.chatDetail,
            onUpdated: _controller.chatUpdated,
          ),
        );
      },
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _buildPinnedMessage(ChatDetail? data) {
    var chatUser = data?.chatUser;
    return _controller.pinnedMessage.builder(
      (loading, data, error, context) {
        if (data != null) {
          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(MessageInfoView(message: data));
                      },
                      child: Text(
                        data.message ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  if (chatUser?.role != UserChatRole.admin)
                    CustomTextButton(
                      text: "remove",
                      onTap: _controller.removePinMessage,
                    ),
                ],
              ));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildMessageListWithIndexedView() {
    return _controller.messagesWithDate.builder((loading, data, error, context) {
      if (data == null) return const CenteredProgressIndicator();
      if (error != null) return CenteredErrorText(error);
      return ScrollableListView(
        items: data,
        itemScrollController: _controller.itemScrollController,
        itemPositionsListener: _controller.itemPositionsListener,
        itemBuilder: (context, index) {
          var item = data[index];
          if (item.message == null) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: context.theme.primaryColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.date.relativeDate(showToday: true),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                ),
              ),
            );
          }
          return ChatMessageBubble(
            canSwipe: true,
            message: item.message!,
            chat: _controller.chat,
            onPinned: _controller.pinMessage,
            onReply: _controller.replyMessage.setState,
            onAddFavorite: _controller.addFavorites,
            onInfo: (m) => Get.to(MessageInfoView(message: m)),
          );
        },
      );
    });
  }
}
