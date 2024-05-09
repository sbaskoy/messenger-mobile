import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/filter/filter_response.dart';
import 'package:planner_messenger/views/chats/chat_list_widget.dart';
import 'package:planner_messenger/widgets/progress_indicator/centered_progress_indicator.dart';

import '../../constants/app_controllers.dart';
import '../../models/chats/chat.dart';
import '../../views/chat_message/message_view.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchTermController = TextEditingController();
  FilterResponse? _searchResponse;
  String _lastSearchTerm = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchTermController.addListener(() {
      Timer(const Duration(seconds: 1), _search);
    });
  }

  Future<void> _search() async {
    var searchTerm = _searchTermController.text;
    if (searchTerm.length < 3 || _lastSearchTerm == searchTerm) {
      return;
    }
    try {
      setState(() {
        _loading = true;
      });
      // print(searchTerm);
      var response = await AppServices.filter.search(searchTerm);
      if (response != null) {
        _searchResponse = response;
        _lastSearchTerm = searchTerm;
        setState(() {
          _loading = false;
        });
      }
    } catch (ex) {
      if (ex is DioException && ex.type != DioExceptionType.cancel) {
        setState(() {
          _loading = false;
        });
      }
      //AppUtils.showErrorSnackBar(ex);
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    const emptySize = SizedBox(height: 10);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              SizedBox(
                width: Get.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "Search",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    Positioned(
                      left: 0,
                      child: TextButton(
                        onPressed: Get.back,
                        child: const Text("Cancel"),
                      ),
                    ),
                  ],
                ),
              ),
              emptySize,
              CupertinoSearchTextField(
                autofocus: true,
                controller: _searchTermController,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(child: _loading ? const CenteredProgressIndicator() : _buildResponse())
      ],
    );
  }

  Widget _buildResponse() {
    var chats = _searchResponse?.chats ?? [];
    var messages = _searchResponse?.messages ?? [];
    if (chats.isEmpty && messages.isEmpty) {
      return const SizedBox(
        child: Text("No result"),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildChatsList(),
          _buildMessagesList(),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    var chats = _searchResponse?.chats ?? [];
    if (chats.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
          ),
          child: Text("Chats", style: Theme.of(context).textTheme.bodyLarge),
        ),
        const Divider(),
        ListView.builder(
          itemCount: chats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var chat = chats[index];
            return ChatItem(item: chat);
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    var messages = _searchResponse?.messages ?? [];
    if (messages.isEmpty) {
      return const SizedBox();
    }
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
          ),
          child: Text("Messages", style: Theme.of(context).textTheme.bodyLarge),
        ),
        const Divider(),
        ListView.builder(
          itemCount: messages.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var message = messages[index];
            var chat = message.chat;
            if (chat == null) return const SizedBox();
            var photoUrl = message.chat?.getPhotoUrl();
            var startText = "";
            if (chat.chatType == ChatType.group) {
              startText = message.user?.fullName ?? "";
              if (startText.isNotEmpty) {
                startText += ": ";
              }
            } else {
              if (message.createdUserId == AppControllers.auth.user?.id) {
                startText = "You: ";
              }
            }
            return ListTile(
              onTap: () {
                Get.to(
                    () => MessageView(
                          chatId: message.chat!.id!,
                          loadMessageId: message.id,
                        ),
                    transition: Transition.rightToLeft);
              },
              leading: CircleAvatar(
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(message.chat?.getChatName() ?? ""),
              subtitle: Text(
                "$startText ${message.message}",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              trailing: Column(
                children: [
                  Text(
                    message.createdAt.relativeDate(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.textTheme.labelSmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
