import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/extensions/list_extension.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/auth/user_activity.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/chats/chat_detail.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:s_state/s_state.dart';

class MessageListItem {
  String? date;
  Message? message;

  MessageListItem({this.date, this.message});
}

class MessageController {
  //final Chat chat;

  MessageController({required Chat chat}) {
    chatDetail = SState(ChatDetail(chat: chat));
    chatStream = chatDetail.transform((value) => value.chat);
    messageTextController.addListener(() {
      messageText.setState(messageTextController.text);
    });
    messagesByDate = messages.transform((values) {
      values.sort((a, b) => b.createdAt.tryParseDateTime()!.compareTo(a.createdAt.tryParseDateTime()!));
      Map<String, List<Message>> grouped = values.groupBy((item) => item.createdAt.dateFormat("yyyy-MM-dd"));
      for (var element in grouped.values) {
        element.sort((a, b) => a.createdAt.tryParseDateTime()!.compareTo(b.createdAt.tryParseDateTime()!));
      }
      // var resValues = <MessageListItem>[];
      // for (var element in grouped.keys) {
      //   resValues.add(MessageListItem(date: element));
      //   var items = grouped[element];
      //   resValues.addAll(items?.map((e) => MessageListItem(message: e)) ?? []);
      // }
      // resValues.sort((a, b)  {
      //   var aDate=a.date != null ?
      // });
      return grouped;
    });
    if (chat.pinnedMessage != null) {
      pinnedMessage.setState(chat.pinnedMessage!);
    }
    AppManagers.socket.joinChat(chat.id.toString());
    AppManagers.socket.client?.once("CHAT_DETAIL", (data) {
      var chatDetailData = ChatDetail.fromJson(data);
      var c = chatDetail.valueOrNull ?? ChatDetail(chat: chat);
      c.userActivity = chatDetailData.userActivity;
      c.chat.users = chatDetailData.chat.users;
      chatDetail.setState(c);
    });
    if (chat.chatType == ChatType.private) {
      AppManagers.socket.client?.on("USER_STATUS_CHANGED", (data) {
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
      if (message.chatId == chat.id) {
        addNewMessage(message);
      }
    });
    flutterListViewController.addListener(() {
      if (flutterListViewController.position.pixels == 0) {
        loadNextPage();
      }
    });
  }
  late final SState<ChatDetail> chatDetail;
  late final SReadOnlyState<Chat> chatStream;
  final messages = SState<List<Message>>();

  final favoritesMessage = SState<List<Message>>();
  final pinnedMessage = SState<Message>();
  final replyMessage = SState<Message?>();
  final attachments = SState<List<File>>([]);
  final messageText = SState<String>("");
  late final SReadOnlyState<Map<String, List<Message>>> messagesByDate;
  final TextEditingController messageTextController = TextEditingController();

  Chat get chat => chatStream.valueOrNull!;

  int page = 1;

  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final FlutterListViewController flutterListViewController = FlutterListViewController();
  Future<void> loadMessages({bool? refresh}) async {
    try {
      if (refresh != true) {
        // AppProgressController.show();
      }
      var response = await AppServices.message.listMessages(
        chat.id.toString(),
        page: page,
        refresh: refresh,
      );
      if (response != null) {
        if (refresh == true) {
          messages.setState(response);
        } else {
          var m = messages.valueOrNull ?? [];
          m.addAll(response);
          messages.setState(m);
        }

        await readAllMessage(response);
        if (refresh != true && response.isNotEmpty) {
          // flutterListViewController.sliverController.ensureVisible(response.length);
          // flutterListViewController.
        }
        refreshController.refreshCompleted();
      }
    } catch (ex) {
      messages.setError(AppUtils.getErrorText(ex));
    } finally {
      AppProgressController.hide();
    }
  }

  Future<void> loadNextPage() async {
    page += 1;
    loadMessages();
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
      AppServices.message
          .sendMessage(
        chat.id.toString(),
        message,
        replyId: replyId,
        attachments: attachments?.map((e) => e.file).toList(),
      )
          .then((response) {
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
    flutterListViewController.sliverController.ensureVisible(m.length - 1);
    //flutterListViewController.sliverController
    //    .animateToIndex(m.length - 2, duration: const Duration(seconds: 2), curve: Curves.linear);
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
      if (chat.id == null) return;
      var response = await AppServices.message.pinMessage(chat.id.toString(), message.id!);
      if (response != null) {
        chat.pinnedMessage = message;
        pinnedMessage.setState(message);
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
      detail.chat = updatedChat;
    }
    chatDetail.setState(detail);
  }

  void dispose() {
    AppManagers.socket.leaveChat(chat.id.toString());
    flutterListViewController.dispose();
  }
}
