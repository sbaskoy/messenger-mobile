import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:planner_messenger/controllers/users_controller.dart';
import 'package:planner_messenger/dialogs/create_chat/create_group_chat.dart';
import 'package:planner_messenger/dialogs/create_chat/create_private_chat.dart';
import 'package:planner_messenger/widgets/utils/close_keyboard.dart';

import 'create_group_chat_controller.dart';
import 'create_group_chat_select_user.dart';

class CreateChatDialog extends StatefulWidget {
  final ScrollController? scrollController;
  const CreateChatDialog({super.key, this.scrollController});

  @override
  State<CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends State<CreateChatDialog> {
  final UsersController _controller = UsersController()..listUsers();
  final PageController pageController = PageController();
  final CreateGroupChatController createGroupChatController = CreateGroupChatController();

  @override
  Widget build(BuildContext context) {
    const pageDuration = Duration(milliseconds: 200);
    const pageCurve = Curves.linear;
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CreatePrivateChatWidget(
          controller: _controller,
          createGroupChat: () {
            pageController.nextPage(duration: pageDuration, curve: pageCurve);
            CloseKeyboardWidget.closeKeyboard(context);
          },
        ),
        CreateGroupSelectUser(
          controller: _controller,
          createGroupChatController: createGroupChatController,
          onCancel: () {
            pageController.previousPage(duration: pageDuration, curve: pageCurve);
            CloseKeyboardWidget.closeKeyboard(context);
          },
          onNext: () {
            pageController.nextPage(duration: pageDuration, curve: pageCurve);
          },
        ),
        CreateGroupChatWidget(
          createGroupChatController: createGroupChatController,
          controller: _controller,
          onCancel: () {
            pageController.previousPage(duration: pageDuration, curve: pageCurve);
            CloseKeyboardWidget.closeKeyboard(context);
          },
        )
      ],
    );
  }
}
