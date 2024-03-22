import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/chats/chat.dart';

import 'package:planner_messenger/utils/app_utils.dart';
import 'package:planner_messenger/views/chat_message/message_buble.dart';

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
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Starred Messages"),
      ),
      body: starredMessages.builder(
        AppUtils.sStateBuilder(
          (data) => AppUtils.appListView(
            items: data,
            builder: (context, index, item) {
              var user = item.message?.user;
              var photoUrl = user?.getPhotoUrl();
              return Card(
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
                      if (item.message != null) ChatMessageBubble(message: item.message!)
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
