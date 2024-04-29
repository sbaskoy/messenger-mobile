import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import '../models/chats/chat.dart';
import '../widgets/progress_indicator/centered_progress_indicator.dart';

class SelectChatDialog extends StatefulWidget {
  final void Function(Chat selected)? onSelected;
  const SelectChatDialog({super.key, this.onSelected});

  @override
  State<SelectChatDialog> createState() => _SelectChatDialogState();
}

class _SelectChatDialogState extends State<SelectChatDialog> {
  List<Chat>? _list;

  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTermController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadChats();
    _scrollController.addListener(() {
      var currentPixels = _scrollController.position.pixels;
      if (currentPixels == _scrollController.position.maxScrollExtent) {
        _currentPage++;
        loadChats();
      }
    });
  }

  Future<void> loadChats({bool? refresh, bool? page}) async {
    try {
      var response = await AppServices.chat.listChat(page: _currentPage);
      if (response != null) {
        if (page == true) {
          _list ??= [];
          _list!.addAll(response);
        } else {
          _list = response;
        }
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
      Get.back();
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      "Send To",
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
              const SizedBox(height: 20),
              CupertinoSearchTextField(
                controller: _searchTermController,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(child: _list == null ? const CenteredProgressIndicator() : _buildChatResponseList(_list!))
      ],
    );
  }

  Widget _buildChatResponseList(List<Chat> chats) {
    return ListView.builder(
      itemCount: chats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var chat = chats[index];
        var photoUrl = chat.getPhotoUrl();
        return Column(
          children: [
            ListTile(
              onTap: () {
                widget.onSelected?.call(chat);
                Get.back();
              },
              leading: CircleAvatar(
                backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(
                chat.getChatName(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: _buildSubTitle(context, chat),
            ),
            const Divider(indent: 72, height: 0)
          ],
        );
      },
    );
  }

  Widget? _buildSubTitle(BuildContext context, Chat item) {
    if (item.chatType == ChatType.private) return null;
    var text = item.users?.map((e) => e.user?.fullName ?? "").join(",");
    if (text?.isEmpty ?? true) return null;
    return Text(text!);
  }
}
