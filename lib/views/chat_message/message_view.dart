import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/controllers/message_controller.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/utils/hex_color.dart';
import 'package:planner_messenger/views/chat_message/message_info.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:planner_messenger/views/chats/chat_detail_view.dart';

import '../../models/chats/chat.dart';
import 'message_buble.dart';

class MessageView extends StatefulWidget {
  final Chat chat;
  const MessageView({super.key, required this.chat});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  late final _controller = MessageController(chat: widget.chat)..loadMessages();

  @override
  Widget build(BuildContext context) {
    // _controller.readAllMessage();
    var photoUrl = widget.chat.getPhotoUrl();
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person) : null,
          ),
          title: InkWell(
            onTap: () => Get.to(() => ChatDetailView(chat: widget.chat)),
            child: Text(
              _controller.chat.name ?? "",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
            ),
          ),
          subtitle: Text(
            _controller.chat.name ?? "",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
          ),
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
          _buildMessageList(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: context.theme.appBarTheme.backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 35,
                  child: Center(
                    child: Icon(
                      Icons.attach_file,
                      size: 25,
                      color: Theme.of(context).disabledColor.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
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
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                    onTap: () => _controller.sendMessage(),
                    child: SizedBox(
                      height: 35,
                      child: Center(
                        child: Icon(
                          Icons.send,
                          size: 25,
                          color: Theme.of(context).disabledColor.withOpacity(0.5),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildMessageList() {
    return Expanded(
      child: _controller.messagesByDate.builder(
        AppUtils.sStateBuilder(
          (data) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: HexColor("#DCFCE7"),
              ),
              child: RefreshIndicator(
                onRefresh: _controller.loadMessages,
                child: ListView.builder(
                  reverse: true,
                  itemCount: data.keys.length,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
