import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getx;
import 'package:planner_messenger/constants/app_controllers.dart';
import 'package:planner_messenger/constants/app_managers.dart';
import 'package:planner_messenger/widgets/buttons/custom_icon_button.dart';



class CallScreen extends StatefulWidget {
  final dynamic offer;
  final int chatId;
  const CallScreen({
    super.key,
    this.offer,
    required this.chatId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final socket = AppManagers.socket.client;

  final _localRTCVideoRenderer = RTCVideoRenderer();

  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  MediaStream? _localStream;

  RTCPeerConnection? _rtcPeerConnection;

  List<RTCIceCandidate> rtcIceCadidates = [];

  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  @override
  void initState() {
    super.initState();
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    _setupPeerConnection();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _answerCall() async {
    socket!.on("IceCandidate", (data) {
      String candidate = data["iceCandidate"]["candidate"];
      String sdpMid = data["iceCandidate"]["id"];
      int sdpMLineIndex = data["iceCandidate"]["label"];

      _rtcPeerConnection!.addCandidate(RTCIceCandidate(
        candidate,
        sdpMid,
        sdpMLineIndex,
      ));
    });

    await _rtcPeerConnection!.setRemoteDescription(
      RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
    );

    RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

    _rtcPeerConnection!.setLocalDescription(answer);

    socket!.emit("ANSWER_CALL", {
      "sdpAnswer": answer.toMap(),
      "chatId": widget.chatId,
    });
  }

  void _makeCall() async {
    _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

    socket!.on("CALL_ANSWERED", (data) async {
      log("CALL ANSWERED");

      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data["sdpAnswer"]["sdp"],
          data["sdpAnswer"]["type"],
        ),
      );

      for (RTCIceCandidate candidate in rtcIceCadidates) {
        socket!.emit("IceCandidate", {
          "chatId": widget.chatId,
          "iceCandidate": {"id": candidate.sdpMid, "label": candidate.sdpMLineIndex, "candidate": candidate.candidate}
        });
      }
    });

    RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

    await _rtcPeerConnection!.setLocalDescription(offer);

    socket!.emit('MAKE_CALL', {
      "chatId": widget.chatId,
      "sdpOffer": offer.toMap(),
    });
  }

  _setupPeerConnection() async {
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'}
      ]
    });

    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'} : false,
    });

    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    if (widget.offer != null) {
      _answerCall();
    } else {
      _makeCall();
    }
  }

  _leaveCall() {
    Navigator.pop(context);
  }

  _toggleMic() {
    isAudioOn = !isAudioOn;

    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    isVideoOn = !isVideoOn;

    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;

    _localStream?.getVideoTracks().forEach((track) {
      Helper.switchCamera(track);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("P2P Call App"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(children: [
                RTCVideoView(
                  _remoteRTCVideoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) {
                    return const Center(child: Text("Users waiting"));
                  },
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Container(
                    height: 150,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        RTCVideoView(
                          _localRTCVideoRenderer,
                          mirror: isFrontCameraSelected,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.theme.disabledColor.withOpacity(0.2),
                            ),
                            child: Text(AppControllers.auth.user?.fullName ?? ""),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomIconButton(
                    icon: (isAudioOn ? Icons.mic : Icons.mic_off),
                    onPressed: _toggleMic,
                  ),
                  CustomIconButton(
                    icon: (Icons.call_end),
                    onPressed: _leaveCall,
                  ),
                  CustomIconButton(
                    icon: Icons.cameraswitch,
                    onPressed: _switchCamera,
                  ),
                  CustomIconButton(
                    icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    super.dispose();
  }
}
