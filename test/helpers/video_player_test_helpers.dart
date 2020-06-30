import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/messages.dart';

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(VideoPlayerValue(duration: null));

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId;

  @override
  String get dataSource => '';
  @override
  DataSourceType get dataSourceType => DataSourceType.file;
  @override
  String get package => null;
  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> setLooping(bool looping) async {}

  @override
  VideoFormat get formatHint => null;

  @override
  Future<ClosedCaptionFile> get closedCaptionFile => _loadClosedCaption();
}

Future<ClosedCaptionFile> _loadClosedCaption() async =>
    _FakeClosedCaptionFile();

class _FakeClosedCaptionFile extends ClosedCaptionFile {
  @override
  List<Caption> get captions {
    return <Caption>[
      Caption(
        text: 'one',
        start: Duration(milliseconds: 100),
        end: Duration(milliseconds: 200),
      ),
      Caption(
        text: 'two',
        start: Duration(milliseconds: 300),
        end: Duration(milliseconds: 400),
      ),
      Caption(
        text: 'three',
        start: Duration(milliseconds: 500),
        end: Duration(milliseconds: 600),
      ),
    ];
  }
}

class FakeVideoPlayerPlatform extends VideoPlayerApiTest {
  FakeVideoPlayerPlatform() {
    VideoPlayerApiTestSetup(this);
  }

  Completer<bool> initialized = Completer<bool>();
  List<String> calls = <String>[];
  List<CreateMessage> dataSourceDescriptions = <CreateMessage>[];
  final Map<int, FakeVideoEventStream> streams = <int, FakeVideoEventStream>{};
  bool forceInitError = false;
  int nextTextureId = 0;
  final Map<int, Duration> _positions = <int, Duration>{};

  @override
  TextureMessage create(CreateMessage arg) {
    calls.add('create');
    streams[nextTextureId] = FakeVideoEventStream(
        nextTextureId, 100, 100, const Duration(seconds: 1), forceInitError);
    TextureMessage result = TextureMessage();
    result.textureId = nextTextureId++;
    dataSourceDescriptions.add(arg);
    return result;
  }

  @override
  void dispose(TextureMessage arg) {
    calls.add('dispose');
  }

  @override
  void initialize() {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  void pause(TextureMessage arg) {
    calls.add('pause');
  }

  @override
  void play(TextureMessage arg) {
    calls.add('play');
  }

  @override
  PositionMessage position(TextureMessage arg) {
    calls.add('position');
    final Duration position =
        _positions[arg.textureId] ?? const Duration(seconds: 0);
    return PositionMessage()..position = position.inMilliseconds;
  }

  @override
  void seekTo(PositionMessage arg) {
    calls.add('seekTo');
    _positions[arg.textureId] = Duration(milliseconds: arg.position);
  }

  @override
  void setLooping(LoopingMessage arg) {
    calls.add('setLooping');
  }

  @override
  void setVolume(VolumeMessage arg) {
    calls.add('setVolume');
  }
}

class FakeVideoEventStream {
  FakeVideoEventStream(this.textureId, this.width, this.height, this.duration,
      this.initWithError) {
    eventsChannel = FakeEventsChannel(
        'flutter.io/videoPlayer/videoEvents$textureId', onListen);
  }

  int textureId;
  int width;
  int height;
  Duration duration;
  bool initWithError;
  FakeEventsChannel eventsChannel;

  void onListen() {
    if (!initWithError) {
      eventsChannel.sendEvent(<String, dynamic>{
        'event': 'initialized',
        'duration': duration.inMilliseconds,
        'width': width,
        'height': height,
      });
    } else {
      eventsChannel.sendError('VideoError', 'Video player had error XYZ');
    }
  }
}

class FakeEventsChannel {
  FakeEventsChannel(String name, this.onListen) {
    eventsMethodChannel = MethodChannel(name);
    eventsMethodChannel.setMockMethodCallHandler(onMethodCall);
  }

  MethodChannel eventsMethodChannel;
  VoidCallback onListen;

  Future<dynamic> onMethodCall(MethodCall call) {
    switch (call.method) {
      case 'listen':
        onListen();
        break;
    }
    return Future<void>.sync(() {});
  }

  void sendEvent(dynamic event) {
    _sendMessage(const StandardMethodCodec().encodeSuccessEnvelope(event));
  }

  void sendError(String code, [String message, dynamic details]) {
    _sendMessage(const StandardMethodCodec().encodeErrorEnvelope(
      code: code,
      message: message,
      details: details,
    ));
  }

  void _sendMessage(ByteData data) {
    // TODO(jackson): This has been deprecated and should be replaced
    // with `ServicesBinding.instance.defaultBinaryMessenger` when it's
    // available on all the versions of Flutter that we test.
    // ignore: deprecated_member_use
    defaultBinaryMessenger.handlePlatformMessage(
        eventsMethodChannel.name, data, (ByteData data) {});
  }
}
