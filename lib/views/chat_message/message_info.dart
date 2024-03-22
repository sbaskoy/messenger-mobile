import 'package:flutter/material.dart';
import 'package:planner_messenger/extensions/string_extension.dart';

import 'package:planner_messenger/models/message/message.dart';
import 'package:planner_messenger/models/message/seen_by.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import 'message_buble.dart';

class MessageInfoView extends StatelessWidget {
  final Message message;
  const MessageInfoView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Info"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: ChatMessageBubble(
              message: message,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Seen by"),
          ),
          const Divider(),
          Expanded(
              child: AppUtils.appListView<SeenBy>(
            items: message.seenBy ?? [],
            builder: (context, index, item) {
              var photoUrl = item.user?.getPhotoUrl();
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(item.user?.fullName ?? ""),
                subtitle: Text(item.createdAt.dateFormat("yyyy-MM-dd HH:mm")),
              );
            },
          ))
        ],
      ),
    );
  }
}
