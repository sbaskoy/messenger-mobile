import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:planner_messenger/widgets/progress_indicator/centered_progress_indicator.dart';

import 'package:super_context_menu/super_context_menu.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../models/chats/chat.dart';
import '../../models/chats/chat_user.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final Chat? chat;
  final bool canSwipe;
  final bool showAllText;
  final bool? selectMode;
  final void Function(Message message)? onPinned;
  final void Function(Message message)? onReply;
  final void Function(Message message)? onInfo;
  final void Function(Message message)? onAddFavorite;
  final void Function(Message message)? onDeleted;
  final void Function(Message message)? onForward;
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.chat,
    this.onPinned,
    this.onReply,
    this.onInfo,
    this.onAddFavorite,
    required this.canSwipe,
    this.showAllText = false,
    this.onDeleted,
    this.onForward,
    this.selectMode,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthorCurrentUser = message.createdUserId == AppControllers.auth.user?.id;
    const bubbleRadius = Radius.circular(16);
    var memberUser = chat?.getPrivateChatMemberId();

    return message.isDeleted
        ? Container(
            width: Get.width,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Align(
              alignment: isAuthorCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.85,
                ),
                decoration: BoxDecoration(
                  color: context.theme.disabledColor.withOpacity(0.01),
                ),
                child: Text(
                  "This message has been deleted by ${message.deletedBy?.fullName}",
                  style: TextStyle(
                    color: context.theme.disabledColor.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              if (selectMode == true) {
                message.isSelected.setState(!(message.isSelected.valueOrNull ?? false));
              }
            },
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Durations.medium1,
                  width: selectMode == true ? 20 : 0,
                  height: 20,
                  child: message.isSelected.builder((loading, data, error, context) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: context.theme.primaryColor.withOpacity(0.5)),
                        color: data == true ? context.theme.primaryColor : null,
                      ),
                      child: selectMode != true
                          ? null
                          : data == true
                              ? const Icon(Icons.done, size: 14)
                              : const SizedBox(),
                    );
                  }),
                ),
                Expanded(
                  child: IgnorePointer(
                    ignoring: selectMode == true,
                    child: _buildMessage(isAuthorCurrentUser, context, bubbleRadius, memberUser),
                  ),
                )
              ],
            ),
          );
  }

  SwipeTo _buildMessage(bool isAuthorCurrentUser, BuildContext context, Radius bubbleRadius, int? memberUser) {
    var canDeleteMessage = chat?.chatType == ChatType.private
        ? isAuthorCurrentUser
        : (isAuthorCurrentUser || chat?.getCurrentChatUser()?.role == UserChatRole.admin);
    return SwipeTo(
      key: UniqueKey(),
      onLeftSwipe: !canSwipe
          ? null
          : !isAuthorCurrentUser
              ? null
              : (details) {
                  onInfo?.call(message);
                },
      onRightSwipe: !canSwipe
          ? null
          : (details) {
              onReply?.call(message);
            },
      iconOnRightSwipe: Icons.reply,
      iconOnLeftSwipe: Icons.info,
      iconColor: context.theme.primaryColor,
      animationDuration: const Duration(milliseconds: 150),
      swipeSensitivity: 5,
      child: message.isSended.builder(
        (loading, isSended, error, context) {
          return Container(
            width: Get.width,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            //color: Colors.red,
            child: Align(
              alignment: isAuthorCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ContextMenuWidget(
                hitTestBehavior: HitTestBehavior.opaque,
                menuProvider: (_) {
                  return Menu(
                    children: [
                      MenuAction(title: 'Yanıtla', callback: () => onReply?.call(message)),
                      MenuAction(title: 'Sabitle', callback: () => onPinned?.call(message)),
                      MenuAction(title: 'Yönlendir', callback: () => onForward?.call(message)),
                      if (isAuthorCurrentUser)
                        MenuAction(title: 'Mesaj Bilgisi', callback: () => onInfo?.call(message)),
                      MenuAction(title: 'Favorilere Ekle', callback: () => onAddFavorite?.call(message)),
                      if (canDeleteMessage)
                        MenuAction(
                          title: "Mesajı Sil",
                          callback: () => onDeleted?.call(message),
                          attributes: const MenuActionAttributes(destructive: true),
                        ),
                      MenuSeparator(),
                      MenuAction(title: 'Kapat', callback: () {}),
                    ],
                  );
                },
                liftBuilder: (context, child) {
                  return Card(
                    child: child,
                  );
                },
                child: _buildMessageBodyContainer(context, bubbleRadius, isAuthorCurrentUser, isSended, memberUser),
              ),
            ),
          );
        },
      ),
    );
  }

  Container _buildMessageBodyContainer(
      BuildContext context, Radius bubbleRadius, bool isAuthorCurrentUser, bool? isSended, int? memberUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.85,
      ),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: bubbleRadius,
          topRight: bubbleRadius,
          bottomLeft: !isAuthorCurrentUser ? Radius.zero : bubbleRadius,
          bottomRight: isAuthorCurrentUser ? Radius.zero : bubbleRadius,
        ),
      ),
      // width: Get.width * 0.9,
      child: _buildMessageBody(isAuthorCurrentUser, context, isSended, memberUser),
    );
  }

  Column _buildMessageBody(bool isAuthorCurrentUser, BuildContext context, bool? isSended, int? memberUser) {
    return Column(
      crossAxisAlignment: isAuthorCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isAuthorCurrentUser && chat?.chatType == ChatType.group)
          Text(
            message.user?.fullName ?? "",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: context.theme.primaryColor,
                ),
          ),
        if (message.attachments?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: (message.attachments!.first.file?.isImage() ?? false)
                ? MultiImageViewer(
                    images: message.attachments!
                        .map((e) => ImageModel(
                              imageUrl: e.file!.getUrl()!,
                              caption: e.file?.fileName ?? "",
                            ))
                        .toList())
                : Container(
                    //height: 20,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.theme.disabledColor.withOpacity(0.1),
                    ),
                    child: Column(
                      children: List.generate(message.attachments!.length, (index) {
                        var attachment = message.attachments![index];
                        if (attachment.file == null) return const SizedBox();
                        return InkWell(
                          onTap: () => attachment.file!.open(),
                          child: SizedBox(
                            height: 30,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.insert_drive_file),
                                const SizedBox(width: 5),
                                Expanded(child: Text(attachment.file?.fileName ?? "")),
                                attachment.file!.buildLoadingBar(),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
          ),
        if (message.sendingAttachments?.isNotEmpty ?? false)
          message.sendProgress.builder((loading, data, error, context) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 205,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CenteredProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("% $data"),
                    ),
                  ],
                ),
              ),
            );
          }),
        if (message.reply != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ReplyMessageBubble(
              data: message.reply!,
              hideStartBorder: true,
            ),
          ),
        Wrap(
          spacing: 5,
          alignment: isAuthorCurrentUser ? WrapAlignment.end : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            ReadMoreText(
              message.message,
              trimLines: 3,
              trimMode: showAllText ? TrimMode.Length : TrimMode.Line,
              colorClickableText: Colors.pink,
              trimCollapsedText: 'Show more',
              trimExpandedText: 'Show less',
              moreStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.theme.primaryColor,
                  ),
              lessStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.error,
                  ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            Text(
              message.createdAt.dateFormat("HH:mm"),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
            if (isAuthorCurrentUser)
              Icon(
                isSended == true ? Icons.done_all : Icons.timer,
                size: 15,
                color: chat?.chatType == ChatType.private && isAuthorCurrentUser
                    ? ((message.seenBy?.any((s) => s.userId == memberUser) ?? false)
                        ? context.theme.primaryColor
                        : null)
                    : null,
              )
          ],
        ),
      ],
    );
  }
}
