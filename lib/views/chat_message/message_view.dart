import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_managers.dart';

import 'package:planner_messenger/controllers/message_controller.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/dialogs/select_chat_dialog.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/views/chat_message/message_info.dart';
import 'package:planner_messenger/views/chat_message/reply_message_bubble.dart';
import 'package:planner_messenger/views/chats/chat_detail_view.dart';
import 'package:planner_messenger/views/calls/group_call_screen.dart';
import 'package:planner_messenger/views/home_view.dart';
import 'package:planner_messenger/widgets/buttons/custom_icon_button.dart';
import 'package:planner_messenger/widgets/buttons/custom_text_button.dart';
import 'package:planner_messenger/widgets/list_view/scrollable_list_view.dart';

import 'package:planner_messenger/widgets/progress_indicator/centered_progress_indicator.dart';
import 'package:planner_messenger/widgets/texts/centered_error_text.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';
import 'package:planner_messenger/widgets/utils/shimmer_container.dart';

import '../../models/chats/chat.dart';

import '../../models/chats/chat_detail.dart';
import 'message_bubble.dart';
import 'message_image_view.dart';

class MessageView extends StatefulWidget {
  final int chatId;
  final int? loadMessageId;
  const MessageView({super.key, required this.chatId, this.loadMessageId});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> with WidgetsBindingObserver {
  late final _controller = MessageController(chatId: widget.chatId)..getChatDetail(loadMessageId: widget.loadMessageId);

  Timer? timer;
  final FocusNode _messageTextFocusNode = FocusNode();

  bool _selectMode = false;

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

  void _onMessageInputChange(String val) {
    var chat = _controller.chatDetail.valueOrNull?.chat;
    if (chat == null || chat.chatType == ChatType.group) return;
    if (_controller.typingModel.valueOrNull?.typing == false) {
      AppManagers.socket.typing(widget.chatId.toString(), true);
    }
    timer?.cancel();
    Timer(const Duration(seconds: 1), () {
      AppManagers.socket.typing(widget.chatId.toString(), false);
    });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Get.offAll(() => const HomeView());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          _goBack();
        },
        child: _buildBody(context));
  }

  Scaffold _buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Platform.isIOS ? const Icon(Icons.arrow_back_ios) : const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: _controller.chatDetail.builder((loading, data, error, context) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _buildChatImage(data?.chat),
            title: data == null ? const ShimmerContainer(height: 20) : _buildChatTitle(data.chat),
            subtitle: data == null ? const ShimmerContainer(height: 10) : _buildChatSubTitle(data),
            trailing: data == null ? null : _buildCallButton(data),
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
    var firstWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          TextButton(
              onPressed: () {
                setState(() {
                  _selectMode = false;
                });
              },
              child: const Text("Cancel")),
          const Spacer(),
          CustomIconButton(
            icon: Icons.forward,
            onPressed: () {
              AppUtils.showFlexibleDialog(
                initHeight: 1,
                context: context,
                builder: (c, scrollController, p2) => SelectChatDialog(
                  onSelected: (selected) {
                    _controller.forwardMessages(selected.id!);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );

    var secondWidget = _controller.chatDetail.builder(
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
                            transition: Transition.downToUp,
                          );
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
                    focusNode: _messageTextFocusNode,
                    onSubmitted: (value) => _controller.sendMessage(),
                    controller: _controller.messageTextController,
                    onChanged: _onMessageInputChange,
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
    return AnimatedCrossFade(
      firstChild: firstWidget,
      secondChild: secondWidget,
      crossFadeState: _selectMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Durations.medium1,
    );
  }

  Widget _buildChatImage(Chat? chat) {
    var photoUrl = chat?.getPhotoUrl();
    return CircleAvatar(
      backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
      child: photoUrl == null ? const Icon(Icons.person) : null,
    );
  }

  Widget _buildCallButton(ChatDetail data) {
    var user = AppControllers.auth.user;
    if (user == null) return const SizedBox();
    return CustomIconButton(
      icon: Icons.call,
      color: data.hasActiveCall ? context.theme.primaryColor : null,
      onPressed: () {
        Get.to(
          () => GroupCallScreen(
            chatId: data.chat.id!,
            userId: user.id.toString(),
            displayName: user.fullName ?? "",
            isOwner: data.hasActiveCall == false,
          ),
        );
      },
    );
  }

  Widget _buildChatTitle(Chat? chat) {
    return InkWell(
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
  }

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
    final subTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 12,
          color: Colors.white,
        );
    return InkWell(
      onTap: () {
        Get.to(
          () => ChatDetailView(
            chatDetailStream: _controller.chatDetail,
            onUpdated: _controller.chatUpdated,
          ),
        );
      },
      child: _controller.typingModel.builder((loading, data, error, context) {
        if (data != null && data.typing == true) {
          return Text("typing ...", style: subTitleStyle);
        }
        return Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: subTitleStyle,
        );
      }),
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
                        data.message,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                  if (chatUser?.role == UserChatRole.admin)
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
            selectMode: _selectMode,
            canSwipe: true,
            message: item.message!,
            chat: _controller.activeChat,
            onPinned: _controller.pinMessage,
            onReply: (message) {
              _messageTextFocusNode.requestFocus();
              _controller.replyMessage.setState(message);
            },
            onAddFavorite: _controller.addFavorites,
            onInfo: (m) => Get.to(MessageInfoView(message: m)),
            onForward: (message) async {
              await Future.delayed(Durations.medium2);
              message.isSelected.setState(true);
              setState(() {
                _selectMode = true;
              });
            },
            onDeleted: (m) async {
              var res = await AppUtils.buildYesOrNoAlert(context, "Bu mesajı herkesten silinecek. Emin misiniz?");
              if (res) {
                _controller.deleteMessage(m);
              }
            },
          );
        },
      );
    });
  }
}
