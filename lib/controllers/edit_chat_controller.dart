
import 'package:flutter/material.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:planner_messenger/dialogs/file_select/file_select_dialog_controller.dart';
import 'package:planner_messenger/widgets/progress_indicator/progress_indicator.dart';
import 'package:s_state/s_state.dart';

import '../constants/app_controllers.dart';
import '../dialogs/file_select/file_select_dialog.dart';
import '../models/chats/chat.dart';
import '../utils/app_utils.dart';

class EditChatController {
  final Chat chat;
  final Function(Chat newChat)? onSaved;
  EditChatController({required this.chat, this.onSaved}) {
    chatNameController.text = chat.getChatName();
    groupName.setState(chatNameController.text);
    chatNameController.addListener(() {
      groupName.setState(chatNameController.text);
    });
  }
  final selectedGroupImage = SState<IFilePickerItem>();
  final groupName = SState("");
  late final activeSaveButton = groupName.transform((value) => value.isNotEmpty);
  final TextEditingController chatNameController = TextEditingController();

  Future<void> updateChat() async {
    try {
      AppProgressController.show();
      var response = await AppServices.chat.updateChat(
        chat.id.toString(),
        chatNameController.text,
        file: selectedGroupImage.valueOrNull,
      );
      if (response != null) {
        AppControllers.chatList.updateChat(response);
        onSaved?.call(response);
      }
    } catch (ex) {
      AppUtils.showErrorSnackBar(ex);
    } finally {
      AppProgressController.hide();
    }
  }

  void selectImage(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      AppUtils.showFlexibleDialog(
          context: context,
          initHeight: 0.5,
          builder: (c, scrollController, p2) {
            return FileSelectDialog(
              canSelectFile: false,
              onSelected: (selected) {
                if (selected.isNotEmpty) {
                  selectedGroupImage.setState(selected.first);
                }
              },
            );
          });
    });
  }
}
