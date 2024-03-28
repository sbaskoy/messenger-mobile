import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/extensions/string_extension.dart';

import '../../models/chats/chat.dart';
import '../../utils/app_utils.dart';
import '../chat_message/message_view.dart';

class ChatListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final List<Chat> chats;
  const ChatListWidget({super.key, required this.chats, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: AppUtils.appListView(
        scrollController: scrollController,
        items: chats,
        builder: (context, index, item) {
          // var isPrivate = item.chatType == ChatType.private;
          var photoUrl = item.getPhotoUrl();
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Get.to(
                    () => MessageView(chat: item),
                    transition: Transition.rightToLeft,
                  );
                },
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(
                  item.getChatName(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: _buildSubTitle(context, item),
                trailing: Container(
                    constraints: const BoxConstraints(
                      minWidth: 0,
                      maxWidth: 150,
                    ),
                    child: _buildTrailing(context, item)),
              ),
              const Divider(indent: 72, height: 0)
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubTitle(BuildContext context, Chat chat) {
    var messages = chat.messages ?? [];
    if (messages.isEmpty) return const SizedBox();
    var message = messages.first;
    var startText = "";
    if (chat.chatType == ChatType.group) {
      startText = message.user?.fullName ?? "";
      if (startText.isNotEmpty) {
        startText += ": ";
      }
    } else {
      if (message.createdUserId == AppControllers.auth.user?.id) {
        startText = "You: ";
      }
    }
    return Text(
      "$startText${message.message}",
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildTrailing(BuildContext context, Chat chat) {
    var messages = chat.messages ?? [];
    if (messages.isEmpty) return const SizedBox();
    var message = messages.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          message.createdAt.relativeDate(),
          style: context.textTheme.labelSmall?.copyWith(
            color: chat.unSeenCount > 0 ? Theme.of(context).primaryColor : context.textTheme.labelSmall?.color,
            fontSize: 12,
          ),
        ),
        // const Spacer(),
        const SizedBox(height: 5),
        if (chat.unSeenCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),

            height: 18,
            constraints: const BoxConstraints(
              minWidth: 18,
              maxHeight: 50,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(18),
              //shape: BoxShape.circle,
            ),
            // alignment: Alignment.center,
            child: Text(
              "${chat.unSeenCount}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
      ],
    );
  }
}
