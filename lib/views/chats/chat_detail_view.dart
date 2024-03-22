import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:planner_messenger/models/chats/chat.dart';
import 'package:planner_messenger/views/chat_message/starred_messages.dart';

class ChatDetailView extends StatelessWidget {
  final Chat chat;
  const ChatDetailView({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    var photoUrl = chat.getPhotoUrl();
    const emptySize = SizedBox(height: 10);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Detail"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            emptySize,
            CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person) : null,
            ),
            emptySize,
            Text(
              chat.name ?? "",
              style: context.textTheme.titleLarge,
            ),
            emptySize,
            Card(
              child: ListTile(
                onTap: () => Get.to(() => StarredMessagesView(chat: chat)),
                leading: const Icon(Icons.star),
                title: const Text("Starred Message"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.image_outlined),
                title: Text("Media, Links, Documents"),
                trailing: Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
