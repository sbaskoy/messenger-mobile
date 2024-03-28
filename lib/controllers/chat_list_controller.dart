import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

int _sortChat(Chat a, Chat b) {
  var aDateString = a.messages?.isEmpty ?? true ? a.createdAt : a.messages!.first.createdAt;
  var bDateString = b.messages?.isEmpty ?? true ? b.createdAt : b.messages!.first.createdAt;
  return bDateString.tryParseDateTime()!.compareTo(aDateString.tryParseDateTime()!);
}

class ChatListController {
  final chats = SState<List<Chat>>();
  final archivedChats = SState<List<Chat>>();

  late final SReadOnlyState<List<Chat>> orderedChats;

  late final SReadOnlyState<List<Chat>> orderedArchiveChats;

  int archivePage = 1;
  int activePage = 1;

  ChatListController() {
    orderedChats = chats.transform((value) {
      value.sort(_sortChat);
      return value;
    });
    orderedArchiveChats = archivedChats.transform((value) {
      value.sort(_sortChat);
      return value;
    });
  }

  Future<void> loadChats({bool? archive, bool? refresh}) async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.listChat(
        archive: archive,
        page: archive == true ? archivePage : activePage,
        refresh: refresh,
      );
      if (response != null) {
        if (archive == true) {
          if (refresh == true) {
            archivedChats.setState(response);
          } else {
            var c = archivedChats.valueOrNull ?? [];
            c.addAll(response);
            archivedChats.setState(c);
          }
        } else {
          if (refresh == true) {
            chats.setState(response);
          } else {
            var c = chats.valueOrNull ?? [];
            c.addAll(response);
            chats.setState(c);
          }
        }
      }
    } catch (ex) {
      if (archive == true) {
        archivedChats.setError(AppUtils.getErrorText(ex));
      } else {
        chats.setError(AppUtils.getErrorText(ex));
      }
    } finally {
      AppProgressController.hide();
    }
  }

  Future<void> loadNextPage({bool? archive}) async {
    if (archive == true) {
      activePage += 1;
    } else {
      activePage += 1;
    }
    await loadChats(archive: archive);
  }

  void addNewMessage(Message message) {
    var activeChats = chats.valueOrNull ?? [];
    var archived = archivedChats.valueOrNull ?? [];
    var allChats = [...activeChats, ...archived];
    var chat = allChats.firstWhereOrNull((element) => element.id == message.chatId);
    if (chat == null) return;
    chat.messages ??= [];
    if (chat.messages?.isEmpty ?? false) {
      chat.messages!.add(message);
    } else {
      chat.messages![0] = message;
    }
    updateChat(chat);
  }

  void updateChat(Chat chat) {
    if (chat.isArchived == 1) {
      var c = archivedChats.valueOrNull ?? [];
      var index = c.indexWhere((element) => element.id == chat.id);
      c[index] = chat;
      archivedChats.setState(c);
    } else {
      var c = chats.valueOrNull ?? [];
      var index = c.indexWhere((element) => element.id == chat.id);
      c[index] = chat;
      chats.setState(c);
    }
  }

  void addChat(Chat chat) {
    if (chat.isArchived == 1) {
      var c = archivedChats.valueOrNull ?? [];
      if (!c.any((element) => element.id == chat.id)) {
        c.add(chat);
        archivedChats.setState(c);
      }
    } else {
      var c = chats.valueOrNull ?? [];
      if (!c.any((element) => element.id == chat.id)) {
        c.add(chat);
        chats.setState(c);
      }
    }
  }
}
