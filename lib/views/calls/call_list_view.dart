import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_image_layout/multi_image_layout.dart';
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/controllers/calls_controller.dart';
import 'package:planner_messenger/extensions/string_extension.dart';
import 'package:planner_messenger/models/call/chat_call_participant.dart';
import 'package:planner_messenger/utils/app_utils.dart';

import '../../models/call/chat_call_model.dart';

class CallListView extends StatefulWidget {
  const CallListView({super.key});

  @override
  State<CallListView> createState() => _CallListViewState();
}

class _CallListViewState extends State<CallListView> with AutomaticKeepAliveClientMixin {
  final _controller = CallsController();

  @override
  void initState() {
    super.initState();
    _controller.loadCalls();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(body: _controller.calls.builder(AppUtils.sStateBuilder((data) {
      return RefreshIndicator(
        onRefresh: _controller.loadCalls,
        child: AppUtils.appListView(
          items: data,
          builder: (context, index, item) {
            var photoUrl = item.chat?.getPhotoUrl();
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(
                item.chat?.getChatName() ?? "",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: item.getCurrentParticipant()?.status == ChatParticipantStatus.calling
                          ? context.theme.colorScheme.error
                          : null,
                    ),
              ),
              subtitle: _buildSubTitle(item),
              trailing: Container(
                  constraints: const BoxConstraints(
                    minWidth: 0,
                    maxWidth: 150,
                  ),
                  child: _buildTrailing(item)),
            );
          },
        ),
      );
    })));
  }

  Widget _buildSubTitle(ChatCallModel data) {
    var user = AppControllers.auth.user;
    IconData iconData = data.creatorUserId == user?.id ? Icons.phone_forwarded : Icons.phone_callback;
    String text = data.creatorUserId == user?.id ? "Outgoing" : "Incoming";
    return Row(
      children: [
        Icon(iconData, size: 16, color: context.theme.disabledColor.withOpacity(0.5)),
        const SizedBox(width: 10),
        Text(text,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 14,
            )),
      ],
    );
  }

  Widget _buildTrailing(ChatCallModel data) {
    return Column(
      children: [
        Text(
          data.startDate.relativeDate(),
          style: context.textTheme.labelSmall?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
