import 'dart:async';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

class FlutterVideoPlayerController {
  final StreamController<VideoPlayerState> videoPlayerStream =
      StreamController<VideoPlayerState>.broadcast();
  VideoPlayerBloc videoPlayerBloc;

  bool isInitialized = false;

  void initialize(VideoPlayerBloc _videoPlayerBloc) {
    // this.videoPlayerStream.add(_videoPlayerState);
    this.videoPlayerBloc = _videoPlayerBloc;
    this.isInitialized = true;
  }

  void updateVideoPlayerStream(VideoPlayerState _videoPlayerState) {
    this.videoPlayerStream.add(_videoPlayerState);
  }

  void toggleControlsVisibily() {
    videoPlayerBloc.add(VideoPlayerControlsToggled());
  }

  void seekTo(double value) {
    videoPlayerBloc.add(VideoPlayerSeeked(value));
  }

  void playPauseToggle() {
    videoPlayerBloc.add(VideoPlayerToggled());
  }

  void toggleFullScreen() {
    videoPlayerBloc.add(VideoPlayerFullScreenToggled());
  }

  void fastForward() async {
    VideoPlayerState lastStreamData = await this.videoPlayerStream.stream.last;

    if (lastStreamData is VideoPlayerSuccess) {
      double newPosition =
          lastStreamData.controllerValue.position.inSeconds.toDouble() + 10;
      videoPlayerBloc.add(VideoPlayerSeeked(newPosition));
    }
  }

  void fastRewind() async {
    VideoPlayerState lastStreamData = await this.videoPlayerStream.stream.last;
    if (lastStreamData is VideoPlayerSuccess) {
      double newPosition =
          lastStreamData.controllerValue.position.inSeconds.toDouble() - 10;
      videoPlayerBloc.add(VideoPlayerSeeked(newPosition));
    }
  }
}
