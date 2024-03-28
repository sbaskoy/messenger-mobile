import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/extensions/list_extension.dart';
import 'package:planner_messenger/extensions/string_extension.dart';

import 'package:s_state/s_state.dart';

import '../../constants/app_services.dart';
import '../../models/chats/chat.dart';
import '../../models/message/chat_message_attachment.dart';
import '../../utils/app_utils.dart';

class ChatMediaView extends StatefulWidget {
  final Chat chat;
  const ChatMediaView({super.key, required this.chat});

  @override
  State<ChatMediaView> createState() => _ChatMediaViewState();
}

class _ChatMediaViewState extends State<ChatMediaView> {
  final _selectedTabIndex = SState(0);
  final images = SState<Map<String, List<ChatMessageAttachment>>>();
  final documents = SState<List<ChatMessageAttachment>>();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      var response = await AppServices.chat.listChatDocuments(widget.chat.id.toString());
      if (response != null) {
        var allImages = response.where((element) => element.file?.isImage() ?? false).toList();
        // allImages
        //     .sort((a, b) => a.file!.createdAt.tryParseDateTime()!.compareTo(b.file!.createdAt.tryParseDateTime()!));
        var groupedImages = allImages.groupBy((item) => item.file!.createdAt!.dateFormat("yyyy-MM-dd"));

        var sortedKeys = groupedImages.keys.toList()
          ..sort(
            (a, b) {
              return b.tryParseDateTime()!.compareTo(a.tryParseDateTime()!);
            },
          );

        Map<String, List<ChatMessageAttachment>> sortedMap = {for (var key in sortedKeys) key: groupedImages[key]!};

        images.setState(sortedMap);
        documents.setState(response.where((element) => !(element.file?.isImage() ?? false)).toList());
      }
    } catch (ex) {
      images.setError(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            _selectedTabIndex.builder(
              (loading, data, error, context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(onTap: () => _selectedTabIndex.setState(0), child: _buildTabItem("Images", data == 0)),
                    const SizedBox(width: 10),
                    InkWell(onTap: () => _selectedTabIndex.setState(1), child: _buildTabItem("Documents", data == 1)),
                  ],
                );
              },
            ),
            Positioned(
                left: 0,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back),
                ))
          ],
        ),
      ),
      body: _selectedTabIndex.builder(
        AppUtils.sStateBuilder(
          (data) {
            if (data == 1) {
              return _buildDocumentList();
            }
            return _buildImageGrid();
          },
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      child: images.builder(
        AppUtils.sStateBuilder((data) {
          return ListView.builder(
            reverse: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final date = data.keys.toList()[index];
              final images = data[date] ?? [];
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(date),
                  ),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: images.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = images[index];
                      return GestureDetector(
                        onTap: () {
                          openImage(context, index, images.map((e) => e.file!.getUrl()!).toList(),
                              images.map((e) => e.message?.message ?? "").toList(), {});
                        },
                        child: Container(
                          width: 40,
                          // height: 10,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: Image(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(item.file?.getUrl() ?? ""),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDocumentList() {
    return Container();
  }

  Widget _buildTabItem(String name, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: context.theme.disabledColor.withOpacity(0.1),
      ),
      child: AnimatedCrossFade(
        firstChild: Text(
          name,
          style: context.textTheme.titleMedium?.copyWith(
            color: context.theme.primaryColor,
          ),
        ),
        secondChild: Text(
          name,
          style: context.textTheme.titleMedium?.copyWith(
            color: null,
          ),
        ),
        crossFadeState: isActive ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: Durations.medium3,
      ),
    );
  }
}
