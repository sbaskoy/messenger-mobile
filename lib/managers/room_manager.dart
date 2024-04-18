import 'package:planner_messenger/constants/app_managers.dart';

import 'package:mediasoup_client_flutter/mediasoup_client_flutter.dart';

class MediaType {
  MediaType._();
  static String get audio => 'audioType';
  static String get video => 'videoType';
  static String get screen => 'screenType';
}

class RoomManager {
  late final socket = AppManagers.socket;
  Transport? producerTransport;
  Transport? consumerTransport;
  Device? device;
  Map<String, Consumer> consumers = {};
  Map<String, Producer> producers = {};
  Map<String, String> producerLabel = {};

  Future<void> createRoom(String roomId) async {
    await socket.request('createRoom', {"room_id": roomId});
    _initSockets();
  }

  Future<void> joinRoom(String roomId) async {
    await socket.request("joinRoom", {"room_id": roomId});
    var response = await socket.request("getRouterRtpCapabilities", {});
    final rtpCapabilities = RtpCapabilities.fromMap(response);
    rtpCapabilities.headerExtensions.removeWhere((he) => he.uri == 'urn:3gpp:video-orientation');
    device = await loadDevice(rtpCapabilities);
    await initTransports(device!);
    socket.client?.emit('getProducers');
  }

  Future<Device> loadDevice(RtpCapabilities routerRtpCapabilities) async {
    Device device = Device();
    await device.load(routerRtpCapabilities: routerRtpCapabilities);
    return device;
  }

  void _consumerCallback(Consumer consumer) async {
    consumers[consumer.id] = consumer;
    consumer.on("trackended", () {
      removeConsumer(consumer.id);
    });
    consumer.on("transportclose", () {
      removeConsumer(consumer.id);
    });
  }

  void _producerCallback(Producer producer) async {
    producers[producer.id] = producer;
    producer.on('trackended', () {
      closeProducer(producer.kind);
    });
    producer.on("transportclose", () {
      producers.remove(producer.id);
    });
    producer.on("close", () {
      producers.remove(producer.id);
    });
    producerLabel[producer.kind] = producer.id;
  }

  void removeConsumer(String consumerId) {
    consumers.remove(consumerId);
  }

  void closeProducer(String type) {
    if (producerLabel[type] == null) {
      return;
    }

    String producerId = producerLabel[type]!;

    socket.request('producerClosed', {"producerId": producerId});

    producers[producerId]?.close();
    producers.remove(producerId);
    producerLabel.remove(type);

    if (type != MediaType.audio) {}
  }

  Future<void> initProducerTransport(Device device) async {
    var data = await socket.request("createWebRtcTransport", {
      "forceTcp": false,
      "rtpCapabilities": device.rtpCapabilities.toMap(),
    });
    producerTransport = device.createSendTransportFromMap(data, producerCallback: _producerCallback);
    producerTransport?.on("connect", (Map data) {
      socket.request("connectTransport", {
        "dtlsParameters": data['dtlsParameters'].toMap(),
        "transport_id": producerTransport?.id,
      });
    });
    producerTransport?.on("produce", (Map data) async {
      var response = await socket.request("produce", {
        "producerTransportId": producerTransport?.id,
        "kind": data["kind"],
        'rtpParameters': data['rtpParameters'].toMap(),
      });
      data["callback"](response["producer_id"]);
    });

    producerTransport?.on("connectionstatechange", (Map data) {
      if (data["state"] == "failed") {
        producerTransport?.close();
      }
    });
  }

  Future<void> initConsumerTransport(Device device) async {
    var data = await socket.request("createWebRtcTransport", {
      "forceTcp": false,
    });
    consumerTransport = device.createRecvTransportFromMap(
      data,
      consumerCallback: _consumerCallback,
    );
    consumerTransport?.on("connect", (Map data) {
      socket.request("connectTransport", {
        "transport_id": consumerTransport?.id,
        "dtlsParameters": data["dtlsParameters"].toMap(),
      });
    });
    consumerTransport?.on("connectionstatechange", (Map data) {
      if (data["state"] == "failed") {
        consumerTransport?.close();
      }
    });
  }

  Future<void> initTransports(Device device) async {
    await initProducerTransport(device);
    await initConsumerTransport(device);
  }

  void _initSockets() {
    socket.client?.on("consumerClosed", (data) {
      removeConsumer(data["consumer_id"]);
    });
    socket.client?.on('newProducers', (data) async {
      if (data is List) {
        for (var item in data) {
          await consume(item["producer_id"]);
        }
      }
    });
  }

  Future<void> consume(String producerId) async {
    await getConsumeStream(producerId);
  }

  Future<void> produce(String producerId) async {
    var stream = await createVideoStream();
    var track = stream.getVideoTracks().first;
    producerTransport?.produce(
      track: track,
      codecOptions: ProducerCodecOptions(
        videoGoogleStartBitrate: 1000,
      ),
      encodings: [],
      stream: stream,
      appData: {
        'source': 'webcam',
      },
      source: 'webcam',
    );
  }

  Future<void> getConsumeStream(String producerId) async {
    var rtpCapabilities = device!.rtpCapabilities;

    var data = await socket.request('consume', {
      "rtpCapabilities": rtpCapabilities.toMap(),
      "consumerTransportId": consumerTransport?.id,
      "producerId": producerId,
    });
    var id = data["id"];
    var kind = data["kind"];
    var rtpParametersMap = data["rtpParameters"];

    RtpParameters rtpParameters = RtpParameters.fromMap(rtpParametersMap);

    consumerTransport!.consume(
      id: id,
      producerId: producerId,
      peerId: data["peerId"],
      kind: RTCRtpMediaTypeExtension.fromString(kind),
      rtpParameters: rtpParameters,
    );
  }

  Future<MediaStream> createAudioStream() async {
    //audioInputDeviceId = mediaDevicesBloc.state.selectedAudioInput!.deviceId;
    Map<String, dynamic> mediaConstraints = {
      'audio': {
        'optional': [],
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  Future<MediaStream> createVideoStream() async {
    Map<String, dynamic> mediaConstraints = <String, dynamic>{
      'audio': false,
      'video': {
        'mandatory': {
          'minWidth': '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'optional': [],
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  void enableWebcam() async {
    if (device!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeVideo) == false) {
      return;
    }
    MediaStream? videoStream;
    MediaStreamTrack? track;
    try {
      // NOTE: prefer using h264

      RtpCodecCapability? codec = device!.rtpCapabilities.codecs.firstWhere(
          (RtpCodecCapability c) => c.mimeType.toLowerCase() == 'video/vp8',
          orElse: () => throw 'desired vp8 codec+configuration is not supported');
      videoStream = await createVideoStream();
      track = videoStream.getVideoTracks().first;

      producerTransport!.produce(
        track: track,
        codecOptions: ProducerCodecOptions(
          videoGoogleStartBitrate: 1000,
        ),
        encodings: [],
        stream: videoStream,
        appData: {
          'source': 'webcam',
        },
        source: 'webcam',
        codec: codec,
      );
    } catch (error) {
      if (videoStream != null) {
        await videoStream.dispose();
      }
    }
  }

  void enableMic() async {
    if (device!.canProduce(RTCRtpMediaType.RTCRtpMediaTypeAudio) == false) {
      return;
    }

    MediaStream? audioStream;
    MediaStreamTrack? track;
    try {
      audioStream = await createAudioStream();
      track = audioStream.getAudioTracks().first;
      producerTransport!.produce(
        track: track,
        codecOptions: ProducerCodecOptions(opusStereo: 1, opusDtx: 1),
        stream: audioStream,
        appData: {
          'source': 'mic',
        },
        source: 'mic',
      );
    } catch (error) {
      if (audioStream != null) {
        await audioStream.dispose();
      }
    }
  }
}
