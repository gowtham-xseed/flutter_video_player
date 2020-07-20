import 'dart:async';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

class FlutterVideoPlayerController {
  final StreamController<VideoPlayerSuccess> videoPlayerStream =
      StreamController<VideoPlayerSuccess>();
  VideoPlayerBloc videoPlayerBloc;

  bool isInitialized = false;

  void initialize(
      VideoPlayerSuccess _videoPlayerState, VideoPlayerBloc _videoPlayerBloc) {
    this.videoPlayerStream.add(_videoPlayerState);
    this.videoPlayerBloc = _videoPlayerBloc;
    this.isInitialized = true;
  }

  void updateVideoPlayerStream(VideoPlayerSuccess _videoPlayerState) {
    this.videoPlayerStream.add(_videoPlayerState);
  }

  void toggleControlsVisibily() {
    videoPlayerBloc.add(VideoPlayerControlsToggled());
  }

  void seekTo(double value) {
    videoPlayerBloc.add(VideoPlayerSeeked(value));
  }

  void toggle() {
    videoPlayerBloc.add(VideoPlayerToggled());
  }

  void toggleFullScreen() {
    videoPlayerBloc.add(VideoPlayerFullScreenToggled());
  }
}
