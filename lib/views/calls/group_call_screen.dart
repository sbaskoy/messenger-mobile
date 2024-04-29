import 'package:flutter/material.dart';
import 'package:planner_messenger/constants/app_constants.dart';
import 'package:planner_messenger/constants/app_services.dart';
import 'package:video_call/main.dart';

class GroupCallScreen extends StatefulWidget {
  final int chatId;
  final String userId;
  final String displayName;
  final bool isOwner;
  const GroupCallScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.displayName,
    required this.isOwner,
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isOwner) {
      AppServices.call.startCall(widget.chatId);
    } else {
      AppServices.call.joinCall(widget.chatId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    AppServices.call.leaveCall(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return VideoCallRoom(
      roomId: "${widget.chatId}_chat_call",
      userId: widget.userId,
      displayName: widget.displayName,
      serverUrl: AppConstants.callApiUrl,
    );
  }
}
