
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

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final Chat? chat;
  final bool canSwipe;
  final bool showAllText;
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
    required this.canSwipe,
    this.showAllText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthorCurrentUser = message.createdUserId == AppControllers.auth.user?.id;
    const bubbleRadius = Radius.circular(16);
    var memberUser = chat?.getPrivateChatMemberId();

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
            margin: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
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
                      if (isAuthorCurrentUser)
                        MenuAction(title: 'Mesaj Bilgisi', callback: () => onInfo?.call(message)),
                      MenuAction(title: 'Favorilere Ekle', callback: () => onAddFavorite?.call(message)),
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
                child: Container(
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
                  child: Column(
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
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              height: 205,
                              child: CenteredProgressIndicator(),
                            )),
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
                            message.message ?? "",
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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
