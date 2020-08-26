import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_video_player/video_player_state.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({
    @required this.videoPlayerController,
    this.playOnlyInFullScreen,
    this.onPlayerStateChanged,
  })  : assert(videoPlayerController != null),
        super(VideoPlayerInitial()) {
    if (!videoPlayerController.value.initialized) {
      videoPlayerController.initialize();
    }

    videoPlayerController.addListener(controllerCallBackListener);
  }

  Timer _timer;
  final VideoPlayerController videoPlayerController;
  final bool playOnlyInFullScreen;
  final Function onPlayerStateChanged;
  bool previousPlayingState;

  void initialControlsTimer() {
    Timer(const Duration(seconds: 3), () {
      add(VideoPlayerControlsToggled());
    });
  }

  void controllerCallBackListener() {
    bool currentPlayingState = videoPlayerController.value.isPlaying;

    if (videoPlayerController.value.hasError) {
      add(VideoPlayerErrorOccured());
      onPlayerStateChanged(VideoPlayerStates.error);
    } else {
      add(ProgresUpdated(videoPlayerController.value));

      if (playOnlyInFullScreen && currentPlayingState != previousPlayingState) {
        // Enable full screen if the player is playing
        add(
          VideoPlayerFullScreenToggled(enableFullScreen: currentPlayingState),
        );
      }
    }

    if (videoPlayerController.value.duration ==
        videoPlayerController.value.position) {
      onPlayerStateChanged(VideoPlayerStates.completed);
    }

    previousPlayingState = currentPlayingState;
  }

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
    } else if (event is VideoPlayerControlsToggled) {
      yield* _mapControlsToggledToState();
    } else if (event is VideoPlayerPanned) {
      yield* _mapControlsPannedToState(event);
    } else if (event is VideoPlayerControlsHidden) {
      yield* _mapControlsHiddenToState();
    }
  }

  Stream<VideoPlayerState> _mapVideoPlayerToggledToState(
      VideoPlayerEvent event) async* {
    if (state is VideoPlayerSuccess) {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
        onPlayerStateChanged(VideoPlayerStates.paused);
      } else {
        videoPlayerController.play();
        onPlayerStateChanged(VideoPlayerStates.resumed);
      }

      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          currentState.isFullScreen,
          currentState.showControls,
          isFullScreenChanged: false);
    } else if (state is VideoPlayerInitial) {
      initialControlsTimer();
      videoPlayerController.play();
      onPlayerStateChanged(VideoPlayerStates.started);
      yield VideoPlayerSuccess(
          videoPlayerController, videoPlayerController.value, true, true,
          isFullScreenChanged: false);
    }
  }

  Stream<VideoPlayerState> _mapProgresUpdatedToState(
      ProgresUpdated event) async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(videoPlayerController, event.position,
          currentState.isFullScreen, currentState.showControls,
          isFullScreenChanged: false);
    }
  }

  Stream<VideoPlayerState> _mapSeekedToState(VideoPlayerSeeked event) async* {
    if (state is VideoPlayerSuccess) {
      videoPlayerController.seekTo(Duration(seconds: event.position.toInt()));
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          currentState.isFullScreen,
          currentState.showControls,
          isFullScreenChanged: false);
    }
  }

  Stream<VideoPlayerState> _mapVideoPlayerErrorOccuredToState(
      VideoPlayerErrorOccured event) async* {
    yield VideoPlayerFailure();
  }

  Stream<VideoPlayerState> _mapVideoPlayerFullScreenToggledToState(
      VideoPlayerFullScreenToggled event) async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      bool isFullScreen = event.enableFullScreen
          ? event.enableFullScreen
          : !currentState.isFullScreen;

      yield VideoPlayerSuccess(videoPlayerController,
          videoPlayerController.value, isFullScreen, currentState.showControls,
          isFullScreenChanged: true);
    }
  }

  Stream<VideoPlayerState> _mapControlsToggledToState() async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      if (!currentState.showControls) {
        if (_timer != null && _timer.isActive) {
          _timer.cancel();
        }
        _timer = Timer(Duration(seconds: 3), () {
          add(VideoPlayerControlsHidden());
        });
      }
      yield VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          currentState.isFullScreen,
          !currentState.showControls,
          isFullScreenChanged: false);
    }
  }

  Stream<VideoPlayerState> _mapControlsHiddenToState() async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(videoPlayerController,
          videoPlayerController.value, currentState.isFullScreen, false,
          isFullScreenChanged: false);
    }
  }

  Stream<VideoPlayerState> _mapControlsPannedToState(
      VideoPlayerPanned event) async* {
    if (state is VideoPlayerSuccess) {
      final end = videoPlayerController.value.duration.inMilliseconds;
      final skip = (videoPlayerController.value.position +
              Duration(seconds: event.isForwardPan ? .5.round() : -5.round()))
          .inMilliseconds;
      videoPlayerController.seekTo(Duration(milliseconds: math.min(skip, end)));
    }
  }

  @override
  Future<void> close() {
    videoPlayerController.removeListener(controllerCallBackListener);
    return super.close();
  }
}
