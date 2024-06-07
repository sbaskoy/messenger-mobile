import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  Future<bool> delete(BuildContext context, Chat item) async {
    var res = await AppUtils.buildYesOrNoAlert(context, "Bu sohbeti silmek istediğinizden emin misiniz?");
    if (res) {
      return await AppControllers.chatList.delete(item);
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

          return Slidable(
              key: UniqueKey(),
              endActionPane: ActionPane(motion: const ScrollMotion(), children: [
                SlidableAction(
                  onPressed: (c) {
                    delete(context, item);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
                SlidableAction(
                  onPressed: (c) async {
                    if (item.isArchived) {
                      unArchive(context, item);
                      return;
                    }
                    archive(context, item);
                  },
                  backgroundColor: context.theme.disabledColor.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  icon: Icons.archive,
                ),
              ]),
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
            maxLines: 2,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
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
    var message = chat.lastMessage;
    if (message == null) {
      return const SizedBox();
    }
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
    var message = chat.lastMessage;
    if (message == null) {
      return const SizedBox();
    }
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
