import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

import '../auth/user.dart';

class Peer {
  final Consumer? audio;
  final Consumer? video;
  final User user;
  final String displayName;
  final String id;
  final RTCVideoRenderer? renderer;

  const Peer({
    this.audio,
    this.video,
    this.renderer,
    required this.user,
    required this.displayName,
    required this.id,
  });

  Peer copyWith({
    Consumer? audio,
    Consumer? video,
    RTCVideoRenderer? renderer,
    User? user,
    String? displayName,
    String? id,
  }) {
    return Peer(
      audio: audio ?? this.audio,
      video: video ?? this.video,
      renderer: renderer ?? this.renderer,
      displayName: displayName ?? this.displayName,
      user: user ?? this.user,
      id: id ?? this.id,
    );
  }

  Peer removeAudio({
    Consumer? video,
    RTCVideoRenderer? renderer,
    User? user,
    String? displayName,
    String? id,
  }) {
    return Peer(
      audio: null,
      video: video ?? this.video,
      renderer: renderer ?? this.renderer,
      displayName: displayName ?? this.displayName,
      user: user ?? this.user,
      id: id ?? this.id,
    );
  }

  Peer removeVideo({
    Consumer? audio,
    RTCVideoRenderer? renderer,
    User? user,
    String? displayName,
    String? id,
  }) {
    return Peer(
      audio: audio ?? this.audio,
      video: null,
      renderer: renderer ?? this.renderer,
      displayName: displayName ?? this.displayName,
      user: user ?? this.user,
      id: id ?? this.id,
    );
  }

  Peer removeAudioAndRenderer({
    Consumer? video,
    User? user,
    String? displayName,
    String? id,
  }) {
    return Peer(
      audio: null,
      video: video ?? this.video,
      renderer: null,
      displayName: displayName ?? this.displayName,
      user: user ?? this.user,
      id: id ?? this.id,
    );
  }

  Peer removeVideoAndRenderer({
    Consumer? audio,
    User? user,
    String? displayName,
    String? id,
  }) {
    return Peer(
      audio: audio ?? this.audio,
      video: null,
      renderer: null,
      displayName: displayName ?? this.displayName,
      user: user ?? this.user,
      id: id ?? this.id,
    );
  }
}
