import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/extensions/list_extension.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/auth/user_activity.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/chats/chat_detail.dart';
import 'package:planner_messenger/models/chats/chat_user.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/models/message/seen_by.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';

import 'package:s_state/s_state.dart';
import 'package:scrollable_positioned_list_extended/scrollable_positioned_list_extended.dart';

// int _messagesSortCompate(Message a, Message b){
//   return b.createdAt.tryParseDateTime()!.compareTo(a.createdAt.tryParseDateTime()!);
// }

void _wait(VoidCallback callback) {
  Future.delayed(Durations.medium3).then((value) => callback());
}

class MessageListItem {
  String? date;
  Message? message;

  MessageListItem({this.date, this.message});

  // String get formattedDate=> date.dateFormat()
}

class MessageController {
  //final Chat chat;

  MessageController({required Chat chat}) {
    chatDetail = SState(ChatDetail(chat: chat));
    chatStream = chatDetail.transform((value) => value.chat);
    messageTextController.addListener(() {
      messageText.setState(messageTextController.text);
    });
    sortedMessages = messages.transform((values) {
      values.sort((a, b) => b.createdAt.tryParseDateTime()!.compareTo(a.createdAt.tryParseDateTime()!));
      return values;
    });

    messagesWithDate = sortedMessages.transform((values) {
      //values.sort((a, b) => );

      Map<String, List<Message>> grouped = values.groupBy((item) => item.createdAt.dateFormat("yyyy-MM-dd"));
      List<MessageListItem> response = [];
      for (var key in grouped.keys) {
        var keyValues = grouped[key] ?? [];
        if (keyValues.isEmpty) continue;
        var date = keyValues.first.createdAt;
        response.add(MessageListItem(date: date));
        List<MessageListItem> subItems = [];
        for (var messageItem in keyValues) {
          subItems.add(MessageListItem(message: messageItem, date: date));
        }
        response.insertAll(response.length - 1, subItems);
      }
      //response.sort((a, b) => b.date.tryParseDateTime()!.compareTo(a.date.tryParseDateTime()!));
      return response;
    });
    if (chat.pinnedMessage != null) {
      pinnedMessage.setState(chat.pinnedMessage!);
    }
    AppManagers.socket.joinChat(chat.id.toString());
    AppManagers.socket.client?.once("CHAT_DETAIL", (data) {
      if (AppControllers.chatList.activeChatId != chat.id) return;
      var chatDetailData = ChatDetail.fromJson(data);
      var c = chatDetail.valueOrNull ?? ChatDetail(chat: chat);
      c.userActivity = chatDetailData.userActivity;
      c.chatUser = chatDetailData.chatUser;
      c.chat.users = chatDetailData.chat.users;
      c.hasActiveCall = chatDetailData.hasActiveCall;
      chatDetail.setState(c);
    });
    if (chat.chatType == ChatType.private) {
      AppManagers.socket.client?.on("USER_STATUS_CHANGED", (data) {
        if (AppControllers.chatList.activeChatId != chat.id) return;
        var userActivity = UserActivity.fromJson(data);
        if (userActivity.userId == chat.getPrivateChatMemberId()) {
          var detail = chatDetail.valueOrNull ?? ChatDetail(chat: chat);
          detail.userActivity = userActivity;
          chatDetail.setState(detail);
        }
      });
    }
    AppManagers.socket.client?.on("NEW_MESSAGE", (data) {
      var message = Message.fromJson(data);
      if (message.chatId == chat.id && AppControllers.chatList.activeChatId == chat.id) {
        addNewMessage(message);
        readAllMessage([message]);
      }
    });
    AppManagers.socket.client?.on("SEEN_MESSAGES", (data) {
      //print("SEEN_MESSAGES EVENT $data");
      if (data is List) {
        var seenUsers = data.map((e) => SeenBy.fromJson(e)).toList();
        var chatMessages = messages.valueOrNull ?? [];
        for (var element in seenUsers) {
          var message = chatMessages.firstWhereOrNull((m) => m.id == element.messageId);
          if (message != null &&
              !(message.seenBy?.any((s) => s.messageId == element.messageId && s.userId == element.userId) ?? true)) {
            message.seenBy ??= [];
            message.seenBy!.add(element);
          }
        }
        messages.setState(chatMessages);
      }
    });
    AppManagers.socket.client?.on("CHAT_USER_ROLE", (data) {
      if (data is Map) {
        var chatUser = ChatUser.fromJson(data);
        var detail = chatDetail.valueOrNull;
        if (detail != null) {
          var chatUsers = chat.users ?? [];
          var index = chatUsers.indexWhere((element) => element.id == chatUser.id);
          if (index > -1) {
            chatUsers[index].role = chatUser.role;
            detail.chat.users![index] = chatUser;
            chatDetail.setState(detail);
          }
        }
      }
    });
    AppControllers.chatList.activeChatId = chat.id;
  }
  late final SState<ChatDetail> chatDetail;
  late final SReadOnlyState<Chat> chatStream;
  final messages = SState<List<Message>>();

  final favoritesMessage = SState<List<Message>>();
  final pinnedMessage = SState<Message?>();
  final replyMessage = SState<Message?>();
  final attachments = SState<List<File>>([]);
  final messageText = SState<String>("");
  final showBottomButton = SState(false);

  late final SReadOnlyState<List<MessageListItem>> messagesWithDate;
  late final SReadOnlyState<List<Message>> sortedMessages;

  final TextEditingController messageTextController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  Chat get chat => chatStream.valueOrNull!;

  bool canLoadNextMessage = false;
  bool canLoadPreviousMessage = true;

  Future<void> loadMessages({int? loadMessageId}) async {
    try {
      if (loadMessageId != null) {
        canLoadNextMessage = true;
      }

      var response = await AppServices.message.listMessages(
        chat.id.toString(),
        startMessageId: loadMessageId,
      );
      if (response != null) {
        messages.setState(response);

        await readAllMessage(response);
        _wait(() {
          if (loadMessageId != null) {
            scrollToMessage(loadMessageId);
          }
          itemScrollController.scrollListener((notification) {
            var currentPixels = notification.position.pixels;
            if (currentPixels == notification.position.maxScrollExtent) {
              loadPreviousMessages();
            }
            if (currentPixels == notification.position.minScrollExtent) {
              loadNextMessages();
            }
            if (currentPixels > 300) {
              showBottomButton.setState(true);
            } else {
              showBottomButton.setState(false);
            }
          });
        });
      }
    } catch (ex) {
      messages.setError(AppUtils.getErrorText(ex));
    } finally {
      AppProgressController.hide();
    }
  }

  Future<void> loadPreviousMessages() async {
    if (!canLoadPreviousMessage) return;
    var m = messages.valueOrNull ?? [];
    var lastMessage = m.lastOrNull;
    if (lastMessage == null) return;
    var response = await AppServices.message.previousMessages(
      chat.id.toString(),
      lastMessage.id!,
    );
    if (response == null) {
      AppUtils.showErrorSnackBar("Mesajlar yüklenemedi");
      return;
    }
    if (response.isNotEmpty) {
      m.addAll(response);
      messages.setState(m);
      return;
    }
    canLoadPreviousMessage = false;
  }

  Future<void> loadNextMessages() async {
    if (!canLoadNextMessage) return;
    var m = messages.valueOrNull ?? [];
    var firstMessage = m.firstOrNull;
    if (firstMessage == null) return;
    var response = await AppServices.message.nextMessages(
      chat.id.toString(),
      firstMessage.id!,
    );
    if (response == null) {
      AppUtils.showErrorSnackBar("Mesajlar yüklenemedi");
      return;
    }
    if (response.isNotEmpty) {
      var lastIndex = messages.valueOrNull?.length ?? 0;
      m.addAll(response);
      messages.setState(m);
      lastIndex = m.length - lastIndex;
      _wait(() {
        scrollToIndex(lastIndex, duration: Durations.short1);
      });
      return;
    }
    canLoadNextMessage = false;
  }

  Future<void> readAllMessage(List<Message> messages) async {
    var m = messages
        .where((element) => !(element.seenBy?.any((seenBy) => seenBy.userId == AppControllers.auth.user?.id) ?? false))
        .toList();
    //if (m.isEmpty || chat.id == null) return;
    var response = await AppServices.message.seenMessages(chat.id.toString(), m);
    if (response) {
      chat.unSeenCount = 0;
      AppControllers.chatList.updateChat(chat);
    }
  }

  Future<void> sendMessage({List<IFilePickerItem>? attachments}) async {
    try {
      var message = messageTextController.text.trimLeft();
      if ((message.isEmpty && (attachments?.isEmpty ?? true)) || chat.id == null) return;
      var replyId = replyMessage.valueOrNull?.id;

      var messageItem = Message(
        chatId: chat.id,
        message: message,
        user: AppControllers.auth.user,
        sendingAttachments: attachments,
        reply: replyMessage.valueOrNull,
        seenBy: [],
        attachments: [],
        createdAt: DateTime.now().toIso8601String(),
        createdUserId: AppControllers.auth.user?.id,
        messageTypeId: 1,
      );
      messageItem.isSended.setState(false);
      addNewMessage(messageItem);
      replyMessage.setState(null);

      messageTextController.text = "";

      AppControllers.chatList.addNewMessage(messageItem);
      AppServices.message.sendMessage(
        chat.id.toString(),
        message,
        replyId: replyId,
        attachments: attachments,
        onSendProgress: (count, total) {
          var progress = (count * 100) / total;
          messageItem.sendProgress.setState(progress.toInt());
        },
      ).then((response) {
        if (response != null) {
          messageItem.id = response.id;
          messageItem.attachments = response.attachments;
          // messageItem.createdAt = response.createdAt;
          messageItem.createdUserId = response.createdUserId;
          messageItem.messageType = response.messageType;
          messageItem.messageTypeId = response.messageTypeId;
          messageItem.reply = response.reply;
          messageItem.sendingAttachments = [];
          messageItem.seenBy = [];
          messageItem.user = response.user;
          messageItem.isSended.setState(true);
        }
      });
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
  }

  void addNewMessage(Message message) {
    var m = messages.valueOrNull ?? [];
    m.add(message);
    messages.setState(m);
  }

  Future<void> addFavorites(Message message) async {
    try {
      if (chat.id == null) return;
      var response = await AppServices.message.saveFavorite(chat.id.toString(), [message]);
      if (response != null) {
        var f = favoritesMessage.valueOrNull ?? [];
        f.add(message);
        favoritesMessage.setState(f);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
  }

  Future<void> pinMessage(Message message) async {
    try {
      if (chat.id == null || message.id == null) return;
      var response = await AppServices.chat.pinMessage(chat.id.toString(), message.id!);
      if (response != null) {
        chat.pinnedMessage = message;
        pinnedMessage.setState(message);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
  }

  Future<void> removePinMessage() async {
    try {
      if (chat.id == null) return;
      var response = await AppServices.chat.removePinMessage(chat.id.toString());
      if (response != null) {
        chat.pinnedMessage = null;
        pinnedMessage.setState(null);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
  }

  void chatUpdated(Chat updatedChat) {
    var detail = chatDetail.valueOrNull;
    if (detail == null) {
      detail = ChatDetail(chat: updatedChat);
    } else {
      detail.chat = detail.chat.copy(updatedChat);
    }
    chatDetail.setState(detail);
  }

  void scrollToMessage(int messageId) {
    var m = messages.valueOrNull ?? [];

    var messageIndex = m.indexWhere((element) => element.id == messageId);

    scrollToIndex(messageIndex);
  }

  void scrollToIndex(int index, {Duration? duration}) {
    if (index < 0) return;
    itemScrollController.scrollTo(index: index, duration: duration ?? Durations.medium3);
  }

  void scrollToBottom() {
    itemScrollController.scrollToMax(duration: Durations.medium3);
  }

  void dispose() {
    itemScrollController.getAutoScrollController?.dispose();
    AppManagers.socket.leaveChat(chat.id.toString());
    AppControllers.chatList.activeChatId = null;
  }
}
