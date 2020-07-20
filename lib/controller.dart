import 'dart:async';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

class FlutterVideoPlayerController {
  final StreamController<VideoPlayerSuccess> videoPlayerStream =
      StreamController<VideoPlayerSuccess>();

  bool isInitialized = false;

  void initialize(VideoPlayerSuccess _videoPlayerState) {
    this.videoPlayerStream.add(_videoPlayerState);
    this.isInitialized = true;
  }

  void updateVideoPlayerStream(VideoPlayerSuccess _videoPlayerState) {
    this.videoPlayerStream.add(_videoPlayerState);
  }
}
