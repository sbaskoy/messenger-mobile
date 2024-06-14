import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/extensions/list_extension.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/widgets/progress_indicator/centered_progress_indicator.dart';

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
  int _selectedTabIndex = 0;
  bool _loading = false;
  Map<String, List<ChatMessageAttachment>> images = {};
  Map<String, List<ChatMessageAttachment>> documents = {};
  List<ChatMessageAttachment> allDocuments = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadMessages();
    _searchController.addListener(() {
      var filtered = allDocuments.where((element) {
        var searchTerm = _searchController.text.toLowerCase();
        var name = element.file?.fileName?.toLowerCase() ?? "";
        var user = element.message?.user?.fullName?.toLowerCase() ?? "";
        return name.contains(searchTerm) || user.contains(searchTerm);
      }).toList();
      documents = ({...groupFiles(filtered)});
      setState(() {});
    });
  }

  Future<void> loadMessages() async {
    try {
      setState(() {
        _loading = true;
      });
      var response = await AppServices.chat.listChatDocuments(widget.chat.id.toString());
      if (response != null) {
        var allImages = response.where((element) => element.file?.isImage() ?? false).toList();
        images = ({...groupFiles(allImages)});
        allDocuments = response.where((element) => !(element.file?.isImage() ?? false)).toList();

        documents = ({...groupFiles(allDocuments)});
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      _loading = false;
      setState(() {});
    }
  }

  Map<String, List<ChatMessageAttachment>> groupFiles(List<ChatMessageAttachment> images) {
    var items = images.where((element) => element.file != null).toList();
    var groupedImages = items.groupBy((item) => item.file?.createdAt?.dateFormat("yyyy-MM-dd") ?? "no-date");

    var sortedKeys = groupedImages.keys.toList()
      ..sort(
        (a, b) {
          return b.tryParseDateTime()!.compareTo(a.tryParseDateTime()!);
        },
      );

    Map<String, List<ChatMessageAttachment>> sortedMap = {for (var key in sortedKeys) key: groupedImages[key]!};
    return sortedMap;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () => setState(() {
                          _selectedTabIndex = 0;
                        }),
                    child: _buildTabItem("Media", _selectedTabIndex == 0)),
                const SizedBox(width: 10),
                InkWell(
                    onTap: () => setState(() {
                          _selectedTabIndex = 1;
                        }),
                    child: _buildTabItem("Docs", _selectedTabIndex == 1)),
              ],
            ),
            Positioned(
                left: 0,
                child: IconButton(
                  onPressed: Get.back,
                  icon: Platform.isIOS ? const Icon(Icons.arrow_back_ios) : const Icon(Icons.arrow_back),
                ))
          ],
        ),
      ),
      body: _loading
          ? const CenteredProgressIndicator()
          : _selectedTabIndex == 0
              ? _buildImageGrid()
              : _buildDocumentView(),
    );
  }

  Widget _buildDocumentView() {
    if (documents.isEmpty) {
      return const Center(child: Text("No document have been shared in this chat yet."));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: _searchController,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final date = documents.keys.toList()[index];
              final docs = documents[date] ?? [];
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(date),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var file = docs[index];
                      return Card(
                        child: ListTile(
                          onTap: () => file.file?.open(),
                          title: Text(
                            file.file?.fileName ?? "",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          leading: (file.file?.fileExtension?.isNotEmpty ?? false)
                              ? Text(file.file?.fileExtension ?? "")
                              : const Icon(Icons.insert_drive_file),
                          trailing: file.file?.buildLoadingBar(),
                        ),
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    if (images.isEmpty) {
      return const Center(child: Text("No image have been shared in this chat yet."));
    }
    return ListView.builder(
      reverse: true,
      itemCount: images.length,
      itemBuilder: (context, index) {
        final date = images.keys.toList()[index];
        final im = images[date] ?? [];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.centerLeft,
              child: Text(date),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: im.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var item = im[index];
                return GestureDetector(
                  onTap: () {
                    openImage(context, index, im.map((e) => e.file!.getUrl()!).toList(),
                        im.map((e) => e.message?.message ?? "").toList(), {});
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
  }

  Widget _buildTabItem(String name, bool isActive) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: context.theme.disabledColor.withOpacity(0.1),
      ),
      child: Center(
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
      ),
    );
  }
}
