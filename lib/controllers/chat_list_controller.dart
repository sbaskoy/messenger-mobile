import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

int _sortChat(Chat a, Chat b) {
  var aDateString = a.lastMessage == null ? a.createdAt : a.lastMessage!.createdAt;
  var bDateString = b.lastMessage == null ? b.createdAt : b.lastMessage!.createdAt;
  return bDateString.tryParseDateTime()!.compareTo(aDateString.tryParseDateTime()!);
}

class ChatListController {
  final chats = SState<List<Chat>>();
  final archivedChats = SState<List<Chat>>();

  late final SReadOnlyState<List<Chat>> orderedChats;

  late final SReadOnlyState<List<Chat>> orderedArchiveChats;

  int archivePage = 1;
  int activePage = 1;
  int? activeChatId;
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
      // AppProgressController.show();
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
        _setUnreadNotificationCount();
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
    chat.lastMessage = message;
    if (message.chatId != activeChatId) {
      chat.unSeenCount += 1;
    }
    updateChat(chat);
  }

  void updateChat(Chat chat) {
    if (chat.isArchived == 1) {
      var c = archivedChats.valueOrNull ?? [];
      var index = c.indexWhere((element) => element.id == chat.id);
      c[index] = c[index].copy(chat);
      archivedChats.setState(c);
    } else {
      var c = chats.valueOrNull ?? [];
      var index = c.indexWhere((element) => element.id == chat.id);
      c[index] = c[index].copy(chat);
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

  Future<bool> archive(Chat chat) async {
    try {
      var response = await AppServices.chat.archiveChat(chat.id.toString());
      if (response == null) {
        return false;
      }
      var activeChats = chats.valueOrNull;
      var archived = archivedChats.valueOrNull ?? [];
      chat.archived = [1];
      activeChats?.removeWhere((element) => element.id == chat.id);
      archived.insert(0, chat);
      if (activeChats != null) {
        chats.setState(activeChats);
      }
      archivedChats.setState(archived);
      return true;
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
      return false;
    }
  }

  Future<bool> unArchive(Chat chat) async {
    try {
      var response = await AppServices.chat.unArchiveChat(chat.id.toString());
      if (response == null) {
        return false;
      }
      var activeChats = chats.valueOrNull ?? [];
      var archived = archivedChats.valueOrNull ?? [];
      chat.archived = [];
      activeChats.insert(0, chat);

      archived.removeWhere((e) => e.id == chat.id);

      chats.setState(activeChats);

      archivedChats.setState(archived);
      return true;
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
      return false;
    }
  }

  Future<bool> delete(Chat chat) async {
    try {
      var response = await AppServices.chat.deleteChat(chat.id.toString());
      if (response == null) {
        return false;
      }
      if (chat.isArchived) {
        var chats = archivedChats.valueOrNull ?? [];
        chats.removeWhere((element) => element.id == chat.id);
        archivedChats.setState(chats);
      } else {
        var activeChats = chats.valueOrNull ?? [];
        activeChats.removeWhere((element) => element.id == chat.id);
        chats.setState(activeChats);
      }

      return true;
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
      return false;
    }
  }

  void _setUnreadNotificationCount() {
    var totalUnreadCount =
        chats.valueOrNull?.fold(0, (previousValue, element) => previousValue + element.unSeenCount) ?? 0;
    if (totalUnreadCount > 0) {
      FlutterAppBadger.updateBadgeCount(totalUnreadCount);
    } else {
      FlutterAppBadger.removeBadge();
    }
  }
}
