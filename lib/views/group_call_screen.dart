import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as RTC;

import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/models/auth/user.dart';


class GroupCallScreen extends StatefulWidget {
  final int chatId;
  final bool answer;
  const GroupCallScreen({super.key, required this.chatId, required this.answer});

  @override
  State<StatefulWidget> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  List<GroupCallUser> users = [];
  RTC.RTCPeerConnection? _peerConnection;
  RTC.MediaStream? _localStream;
  final RTC.RTCVideoRenderer _localRenderer = RTC.RTCVideoRenderer();

  bool _isFrontCamera = true;
  final socket = AppManagers.socket.client;
  @override
  void initState() {
    super.initState();
    _connectAndListen();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _peerConnection?.close();
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  _switchCamera() async {
    //isFrontCameraSelected = !isFrontCameraSelected;

    _localStream?.getVideoTracks().forEach((track) {
      RTC.Helper.switchCamera(track);
    });
    setState(() {});
    _isFrontCamera = !_isFrontCamera;
  }

  void _startCall() {
    socket?.emit("CREATE_GROUP_CALL", {"chatId": widget.chatId});
  }

  void _joinCall() {
    socket?.emit("ANSWER_GROUP_CALL", {"chatId": widget.chatId});
  }

  void _connectAndListen() async {}

  initRenderers() async {
    await _localRenderer.initialize();
  }

  void _parseUsers(dynamic data) {
    if (data is List) {
      setState(() {
        users = data.map((e) => GroupCallUser.fromJson(e)).toList();
      });
    }
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    RTC.MediaStream stream = await RTC.navigator.mediaDevices.getUserMedia(mediaConstraints);

    setState(() {
      _localRenderer.srcObject = stream;
    });

    return stream;
  }

  endCall() {
    _peerConnection?.close();
    _localStream?.dispose();
    _localRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var chatUser = users[index];
              return Container(
                color: Colors.red,
                child: Stack(
                  children: [
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Text(
                          chatUser.user?.fullName ?? "",
                        ))
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
