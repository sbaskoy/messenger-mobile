import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';

import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/extensions/string_extension.dart';

import '../../models/chats/chat.dart';
import '../../utils/app_utils.dart';
import '../chat_message/message_view.dart';

class ChatListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final List<Chat> chats;

  const ChatListWidget({super.key, required this.chats, required this.scrollController});

  Future<bool> archive(BuildContext context, Chat item) async {
    var res = await AppUtils.buildYesOrNoAlert(context, "Bu sohbeti arşivlemek istediğinizden emin misiniz?");
    if (res) {
      return await AppControllers.chatList.archive(item);
    }
    return false;
  }

  Future<bool> unArchive(BuildContext context, Chat item) async {
    var res = await AppUtils.buildYesOrNoAlert(context, "Bu sohbeti arşivden kaldırmak istediğinizden emin misiniz?");
    if (res) {
      return await AppControllers.chatList.unArchive(item);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: AppUtils.appListView(
        scrollController: scrollController,
        items: chats,
        builder: (context, index, item) {
          // var isPrivate = item.chatType == ChatType.private;

          return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                //  color: context.theme.colorScheme.errorContainer,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CircleAvatar(
                  backgroundColor: context.theme.disabledColor.withOpacity(0.2),
                  child: Icon(
                    Icons.archive,
                    color: context.theme.primaryColor,
                  ),
                ),
              ),
              onDismissed: (direction) {},
              confirmDismiss: (direction) async {
                if (item.isArchived == 1) {
                  return await unArchive(context, item);
                }
                return await archive(context, item);
              },
              child: ChatItem(item: item));
        },
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final Chat item;
  const ChatItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var photoUrl = item.getPhotoUrl();
    return Column(
      children: [
        ListTile(
          onTap: () {
            Get.to(
              () => MessageView(chatId: item.id!),
              transition: Transition.rightToLeft,
            );
          },
          leading: CircleAvatar(
            backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
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
      "$startText${(message.message.isNotEmpty) ? message.message : 'File attachment'}",
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: (message.message.isNotEmpty) ? null : context.theme.disabledColor.withOpacity(0.4),
          ),
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
