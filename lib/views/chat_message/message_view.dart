import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:multi_image_layout/multi_image_layout.dart';

import 'package:planner_messenger/controllers/message_controller.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chat_message/message_info.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:planner_messenger/views/chats/chat_detail_view.dart';
import 'package:planner_messenger/widgets/texts/centered_error_text.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';

import '../../models/chats/chat.dart';
import 'message_buble.dart';
import 'message_image_view.dart';

class MessageView extends StatefulWidget {
  final Chat chat;
  const MessageView({super.key, required this.chat});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  late final _controller = MessageController(chat: widget.chat)..loadMessages();

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _controller.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _controller.readAllMessage();

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _controller.chatStream.builder((loading, data, error, context) {
            var photoUrl = data?.getPhotoUrl();
            return CircleAvatar(
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person) : null,
            );
          }),
          title: _controller.chatStream.builder((loading, data, error, context) {
            return InkWell(
              onTap: () {
                if (data != null) {
                  Get.to(
                    () => ChatDetailView(
                      chatDetailStream: _controller.chatDetail,
                      onUpdated: _controller.chatUpdated,
                    ),
                  );
                }
              },
              child: Text(
                data?.getChatName() ?? "",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
              ),
            );
          }),
          subtitle: _controller.chatDetail.builder((loading, data, error, context) {
            if (data == null) return const SizedBox();

            var users = data.chat.users?.map((e) => e.user?.fullName).toList().join((", ")) ?? "";
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
          }),
        ),
      ),
      body: Column(
        children: [
          _controller.pinnedMessage.builder(
            (loading, data, error, context) {
              if (data != null) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(data.message ?? ""),
                );
              }
              return const SizedBox();
            },
          ),
          Expanded(child: _buildMessageListWithIndexedView()),
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
                  //onTap: () => _controller.sendMessage(),
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
  }

  Widget _buildMessageListWithIndexedView() {
    return _controller.messagesByDate.builder((loading, data, error, context) {
      if (data == null) return const SizedBox();
      if (error != null) return CenteredErrorText(error);
      return Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final date = data.keys.toList()[index];
                final messages = data[date] ?? [];

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: context.theme.primaryColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        messages.first.createdAt.relativeDate(showToday: true),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        return ChatMessageBubble(
                          canSwipe: true,
                          message: message,
                          chat: _controller.chat,
                          onPinned: _controller.pinMessage,
                          onReply: _controller.replyMessage.setState,
                          onAddFavorite: _controller.addFavorites,
                          onInfo: (m) => Get.to(MessageInfoView(message: m)),
                        );
                      },
                    )
                  ],
                );
              },
            )),
      );
    });
  }

  Widget _itemBuilder(MessageListItem item) {
    if (item.date != null) {
      return Align(
        alignment: Alignment.topCenter,
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
  }
}
