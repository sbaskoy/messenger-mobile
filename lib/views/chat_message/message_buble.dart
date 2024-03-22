import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:super_context_menu/super_context_menu.dart';

import '../../models/chats/chat.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final Chat? chat;
  final void Function(Message message)? onPinned;
  final void Function(Message message)? onReply;
  final void Function(Message message)? onInfo;
  final void Function(Message message)? onAddFavorite;
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.chat,
    this.onPinned,
    this.onReply,
    this.onInfo,
    this.onAddFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthorCurrentUser = message.createdUserId == AppControllers.auth.user?.id;
    const bubbleRadius = Radius.circular(16);

    return Align(
      alignment: isAuthorCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ContextMenuWidget(
        hitTestBehavior: HitTestBehavior.opaque,
        menuProvider: (_) {
          return Menu(
            children: [
              MenuAction(title: 'Yanıtla', callback: () => onReply?.call(message)),
              MenuAction(title: 'Sabitle', callback: () => onPinned?.call(message)),
              if (isAuthorCurrentUser) MenuAction(title: 'Mesaj Bilgisi', callback: () => onInfo?.call(message)),
              MenuAction(title: 'Favorilere Ekle', callback: () => onAddFavorite?.call(message)),
              MenuSeparator(),
              MenuAction(title: 'Kapat', callback: () {}),
            ],
          );
        },
        previewBuilder: (context, child) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: Get.width * 0.85,
          ),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.theme.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: bubbleRadius,
              topRight: bubbleRadius,
              bottomLeft: !isAuthorCurrentUser ? Radius.zero : bubbleRadius,
              bottomRight: isAuthorCurrentUser ? Radius.zero : bubbleRadius,
            ),
          ),
          // width: Get.width * 0.9,
          child: Column(
            crossAxisAlignment: isAuthorCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.reply != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ReplyMessageBubble(
                    data: message.reply!,
                    hideStartBorder: true,
                  ),
                ),
              if (!isAuthorCurrentUser && chat?.chatType == ChatType.group)
                Text(
                  message.user?.fullName ?? "",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                ),
              Wrap(
                spacing: 5,
                alignment: isAuthorCurrentUser ? WrapAlignment.end : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    message.message ?? "",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    message.createdAt.dateFormat("HH:mm"),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
