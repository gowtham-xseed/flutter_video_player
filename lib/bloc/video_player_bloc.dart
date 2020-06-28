import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({@required VideoPlayerController controller})
      : assert(controller != null),
        _controller = controller {
    if (!_controller.value.initialized) {
      _controller.initialize();
    }
    _controller.addListener(controllerCallBackListener);
  }

  void controllerCallBackListener() {
    if (_controller.value.hasError) {
      add(VideoPlayerErrorOccured());
    } else {
      add(ProgresUpdated(_controller.value));
    }
  }

  final VideoPlayerController _controller;

  @override
  VideoPlayerState get initialState => VideoPlayerInitial();

  @override
  Stream<VideoPlayerState> mapEventToState(
    VideoPlayerEvent event,
  ) async* {
    if (event is VideoPlayerToggled) {
      yield* _mapVideoPlayerToggledToState(event);
    } else if (event is ProgresUpdated) {
      yield* _mapProgresUpdatedToState(event);
    } else if (event is VideoPlayerSeeked) {
      yield* _mapSeekedToState(event);
    } else if (event is VideoPlayerErrorOccured) {
      yield* _mapVideoPlayerErrorOccuredToState(event);
    } else if (event is VideoPlayerFullScreenToggled) {
      yield* _mapVideoPlayerFullScreenToggledToState(event);
    }
  }

  Stream<VideoPlayerState> _mapVideoPlayerToggledToState(
      VideoPlayerEvent event) async* {
    if (state is VideoPlayerSuccess) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }

      yield VideoPlayerSuccess(_controller, _controller.value,
          (state as VideoPlayerSuccess).isFullScreen);
    } else if (state is VideoPlayerInitial) {
      _controller.play();
      yield VideoPlayerSuccess(_controller, _controller.value, false);
    }
  }

  Stream<VideoPlayerState> _mapProgresUpdatedToState(
      ProgresUpdated event) async* {
    if (state is VideoPlayerSuccess) {
      yield VideoPlayerSuccess(_controller, event.position,
          (state as VideoPlayerSuccess).isFullScreen);
    }
  }

  Stream<VideoPlayerState> _mapSeekedToState(VideoPlayerSeeked event) async* {
    if (state is VideoPlayerSuccess) {
      _controller.seekTo(Duration(seconds: event.position.toInt()));

      yield VideoPlayerSuccess(_controller, _controller.value,
          (state as VideoPlayerSuccess).isFullScreen);
    }
  }

  Stream<VideoPlayerState> _mapVideoPlayerErrorOccuredToState(
      VideoPlayerErrorOccured event) async* {
    yield VideoPlayerFailure();
  }

  Stream<VideoPlayerState> _mapVideoPlayerFullScreenToggledToState(
      VideoPlayerFullScreenToggled event) async* {
    if (state is VideoPlayerSuccess) {
      yield VideoPlayerSuccess(_controller, _controller.value,
          !(state as VideoPlayerSuccess).isFullScreen,
          isFullScreenChanged: true);
    }
  }

  @override
  Future<void> close() {
    _controller.removeListener(controllerCallBackListener);
    return super.close();
  }
}
