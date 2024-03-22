import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';
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

  Future<void> loadChats({bool? archive}) async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.listChat(archive: archive);
      if (response != null) {
        if (archive == true) {
          archivedChats.setState(response);
        } else {
          chats.setState(response);
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

  void updateChat(Chat chat) {
    if (chat.isArchived == 1) {
      var c = archivedChats.valueOrNull ?? [];
      archivedChats.setState(c);
    } else {
      var c = chats.valueOrNull ?? [];
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
