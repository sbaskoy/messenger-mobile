import 'package:flutter/material.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/list_extension.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

class MessageController {
  final Chat chat;

  MessageController({required this.chat}) {
    messagesByDate = messages.transform((values) {
      values.sort((a, b) => b.createdAt.tryParseDateTime()!.compareTo(a.createdAt.tryParseDateTime()!));
      Map<String, List<Message>> grouped = values.groupBy((item) => item.createdAt.dateFormat("yyyy-MM-dd"));
      for (var element in grouped.values) {
        element.sort((a, b) => a.createdAt.tryParseDateTime()!.compareTo(b.createdAt.tryParseDateTime()!));
      }
      return grouped;
    });
    if (chat.pinnedMessage != null) {
      pinnedMessage.setState(chat.pinnedMessage!);
    }
  }

  final messages = SState<List<Message>>();
  final favoritesMessage = SState<List<Message>>();
  final pinnedMessage = SState<Message>();
  final replyMessage = SState<Message?>();
  late final SReadOnlyState<Map<String, List<Message>>> messagesByDate;
  final TextEditingController messageTextController = TextEditingController();

  Future<void> loadMessages() async {
    try {
      AppProgressController.show();
      var response = await AppServices.message.listMessages(chat.id.toString());
      if (response != null) {
        messages.setState(response);

        await readAllMessage();
      }
    } catch (ex) {
      messages.setError(AppUtils.getErrorText(ex));
    } finally {
      AppProgressController.hide();
    }
  }

  Future<void> readAllMessage() async {
    var m = (messages.valueOrNull ?? [])
        .where((element) => !(element.seenBy?.any((seenBy) => seenBy.userId == AppControllers.auth.user?.id) ?? false))
        .toList();
    //if (m.isEmpty || chat.id == null) return;
    var response = await AppServices.message.seenMessages(chat.id.toString(), m);
    if (response) {
      chat.unSeenCount = 0;
      AppControllers.chatList.updateChat(chat);
    }
  }

  Future<void> sendMessage() async {
    try {
      var message = messageTextController.text.trimLeft();
      if (message.isEmpty || chat.id == null) return;
      var replyId = replyMessage.valueOrNull?.id;
      var response = await AppServices.message.sendMessage(chat.id.toString(), message, replyId: replyId);
      if (response != null) {
        response.user ??= AppControllers.auth.user;
        var m = messages.valueOrNull ?? [];
        m.add(response);
        messages.setState(m);
        replyMessage.setState(null);
        messageTextController.text = "";
        chat.messages ??= [];

        if (chat.messages!.isEmpty) {
          chat.messages!.add(response);
        } else {
          chat.messages![0] = response;
        }
        AppControllers.chatList.updateChat(chat);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
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
}
