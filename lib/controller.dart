import 'dart:async';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

class FlutterVideoPlayerController {
  final StreamController<VideoPlayerSuccess> videoPlayerStream =
      StreamController<VideoPlayerSuccess>.broadcast();
  VideoPlayerBloc videoPlayerBloc;

  bool isInitialized = false;

  void initialize(VideoPlayerBloc _videoPlayerBloc) {
    // this.videoPlayerStream.add(_videoPlayerState);
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

  void fastForward() async {
    VideoPlayerSuccess lastStreamData =
        await this.videoPlayerStream.stream.last;

    double newPosition =
        lastStreamData.controllerValue.position.inSeconds.toDouble() + 10;
    videoPlayerBloc.add(VideoPlayerSeeked(newPosition));
  }

  void fastRewind() async {
    print('fastRewind');
    VideoPlayerSuccess lastStreamData =
        await this.videoPlayerStream.stream.last;
    print('fastRewind 1');
    double newPosition =
        lastStreamData.controllerValue.position.inSeconds.toDouble() - 10;
    videoPlayerBloc.add(VideoPlayerSeeked(newPosition));
    print('fastRewind 2');
  }
}
