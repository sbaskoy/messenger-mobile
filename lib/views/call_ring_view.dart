import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_managers.dart';
import '../models/call/incoming_call_data_model.dart';
import '../widgets/buttons/custom_icon_button.dart';
import 'chats/chat_list_widget.dart';
import 'group_call_screen.dart';

class CallRingView extends StatefulWidget {
  final Widget child;
  const CallRingView({super.key, required this.child});

  @override
  State<CallRingView> createState() => _CallRingViewState();
}

class _CallRingViewState extends State<CallRingView> {
  IncomingCallData? incomingCallData;
  bool _showIncomingDialog = false;
  @override
  void initState() {
    super.initState();
    AppManagers.socket.isConnected.listen((value) {
      if (value == true) {
        AppManagers.socket.client?.on("NEW_GROUP_CALL", (data) {
          if (data is Map) {
            var callData = IncomingCallData.fromJson(data);
            setState(() {
              incomingCallData = callData;
              _showIncomingDialog = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          AnimatedPositioned(
            duration: Durations.medium2,
            top: _showIncomingDialog ? 0 : -150,
            left: 0,
            right: 0,
            child: incomingCallData == null
                ? const SizedBox()
                : Card(
                    child: Column(
                      children: [
                        Text("New call from", style: context.textTheme.titleMedium),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: ChatItem(item: incomingCallData!.chat)),
                            Wrap(
                              children: [
                                CustomIconButton(
                                  icon: Icons.close,
                                  onPressed: () {
                                    setState(() {
                                      _showIncomingDialog = false;
                                    });
                                    Future.delayed(Durations.medium4).then((val) {
                                      incomingCallData = null;
                                    });
                                  },
                                ),
                                CustomIconButton(
                                  icon: Icons.call,
                                  onPressed: () {
                                    if (incomingCallData == null) return;
                                    Get.to(
                                      () => GroupCallScreen(
                                        chatId: incomingCallData!.chat.id!,
                                        answer: true,
                                      ),
                                    );
                                    setState(() {
                                      _showIncomingDialog = false;
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
