import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';

import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/chat_message/message_bubble.dart';

import 'package:s_state/s_state.dart';

import '../../models/message/favorite_message.dart';

class StarredMessagesView extends StatefulWidget {
  final Chat chat;
  const StarredMessagesView({super.key, required this.chat});

  @override
  State<StarredMessagesView> createState() => _StarredMessageViewState();
}

class _StarredMessageViewState extends State<StarredMessagesView> {
  final starredMessages = SState<List<FavoriteMessage>>();
  final _searchTerm = SState("");
  late final SReadOnlyState<List<FavoriteMessage>> filteredMessages;
  final searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredMessages = starredMessages.combine(_searchTerm, (messages, search) {
      var searchTerm = search.toLowerCase();
      return messages.where((starredItem) {
        var message = starredItem.message;
        return (message?.message.toLowerCase().contains(searchTerm) ?? false) ||
            (message?.user?.fullName?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    });
    searchTextController.addListener(() {
      _searchTerm.setState(searchTextController.text);
    });
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      var response = await AppServices.message.listFavorites(widget.chat.id.toString());
      if (response != null) {
        starredMessages.setState(response);
      }
    } catch (ex) {
      starredMessages.setError(ex);
    }
  }

  Future<bool> deleteStarred(String messageId) async {
    try {
      var response = await AppServices.message.deleteFavorites(widget.chat.id.toString(), messageId);
      if (response != null) {
        var messages = starredMessages.valueOrNull;
        if (messages != null) {
          messages.removeWhere((element) => element.id.toString() == messageId);
        }
        return true;
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Starred Messages"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: searchTextController,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredMessages.builder(
              AppUtils.sStateBuilder(
                (data) => AppUtils.appListView(
                  items: data,
                  builder: (context, index, item) {
                    var user = item.message?.user;
                    var photoUrl = user?.getPhotoUrl();
                    return Dismissible(
                      key: Key(item.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: context.theme.colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: CircleAvatar(
                          child: Icon(
                            Icons.delete,
                            color: context.theme.colorScheme.errorContainer,
                          ),
                        ),
                      ),
                      onDismissed: (direction) {},
                      confirmDismiss: (direction) async {
                        var res = await AppUtils.buildYesOrNoAlert(
                            context, "Mesajın yıldızlı mesajlardan kaldırmak istediğinizden emin misiniz?");
                        if (res) {
                          return await deleteStarred(item.id.toString());
                        }
                        return false;
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                    child: photoUrl == null ? const Icon(Icons.person) : null,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(item.message?.user?.fullName ?? "", style: context.textTheme.bodyLarge),
                                  const Spacer(),
                                  Text(item.message?.createdAt.dateFormat() ?? "", style: context.textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (item.message != null)
                                ChatMessageBubble(
                                  message: item.message!,
                                  canSwipe: false,
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                emptyMessage: "you have no starred message",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
