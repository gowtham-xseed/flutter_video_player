import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_video_player/components/video_player.dart';
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
    this.onRetry,
  })  : assert(videoPlayerController != null),
        super(VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          false,
          false,
        )) {
    _lastLoadedState = VideoPlayerSuccess(
      videoPlayerController,
      videoPlayerController.value,
      false,
      false,
    );

    if (!videoPlayerController.value.isInitialized) {
      videoPlayerController.initialize();
    }

    videoPlayerController.addListener(controllerCallBackListener);
  }

  Timer _timer;
  final VideoPlayerController videoPlayerController;
  final bool playOnlyInFullScreen;
  final OnPlayerStateChanged onPlayerStateChanged;
  final Function onRetry;
  VideoPlayerSuccess _lastLoadedState;

  bool previousPlayingState = false;

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
      print('VIDEO PLAYER ERROR => ' +
          videoPlayerController.value.errorDescription);
    } else {
      add(ProgresUpdated(videoPlayerController.value));

      if (playOnlyInFullScreen &&
          currentPlayingState == true &&
          previousPlayingState == false) {
        // Enable full screen if the player is playing

        add(
          VideoPlayerFullScreenToggled(enableFullScreen: true),
        );
      }
    }

    previousPlayingState = currentPlayingState;

    if (videoPlayerController.value.duration.inMilliseconds ==
        videoPlayerController.value.position.inMilliseconds) {
      onPlayerStateChanged(VideoPlayerStates.completed);
    }
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
        if (videoPlayerController.value.duration.inSeconds ==
            videoPlayerController.value.position.inSeconds) {
          videoPlayerController.seekTo(Duration(milliseconds: 0));
        }

        if (videoPlayerController.value.position.inSeconds == 0) {
          onPlayerStateChanged(VideoPlayerStates.started);
        } else {
          onPlayerStateChanged(VideoPlayerStates.resumed);
        }

        videoPlayerController.play();
      }

      _lastLoadedState = _lastLoadedState.copyWith(
        controllerValue: videoPlayerController.value,
      );

      yield _lastLoadedState;
    } else if (state is VideoPlayerInitial) {
      initialControlsTimer();
      videoPlayerController.play();
      onPlayerStateChanged(VideoPlayerStates.started);
      _lastLoadedState = _lastLoadedState.copyWith(
        controllerValue: videoPlayerController.value,
      );

      yield _lastLoadedState;
    } else if (state is VideoPlayerFailure) {
      if (onRetry != null) {
        onRetry();
      }
    }
  }

  Stream<VideoPlayerState> _mapProgresUpdatedToState(
      ProgresUpdated event) async* {
    if (state is VideoPlayerSuccess) {
      _lastLoadedState =
          _lastLoadedState.copyWith(controllerValue: event.position);

      yield _lastLoadedState;
    }
  }

  Stream<VideoPlayerState> _mapSeekedToState(VideoPlayerSeeked event) async* {
    if (state is VideoPlayerSuccess) {
      videoPlayerController.seekTo(Duration(seconds: event.position.toInt()));

      _lastLoadedState = _lastLoadedState.copyWith(
          controllerValue: videoPlayerController.value);
      yield _lastLoadedState;
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

      if (isFullScreen != _lastLoadedState.isFullScreen) {
        if (playOnlyInFullScreen && !isFullScreen) {
          _lastLoadedState.controller.pause();
        }

        _lastLoadedState = _lastLoadedState.copyWith(
          isFullScreen: isFullScreen,
          isFullScreenChanged: true,
        );

        yield _lastLoadedState;
      }
    }
  }

  Stream<VideoPlayerState> _mapControlsToggledToState() async* {
    if (state is VideoPlayerSuccess) {
      if (!_lastLoadedState.showControls) {
        if (_timer != null && _timer.isActive) {
          _timer.cancel();
        }
        _timer = Timer(Duration(seconds: 3), () {
          add(VideoPlayerControlsHidden());
        });
      }

      _lastLoadedState = _lastLoadedState.copyWith(
        showControls: !_lastLoadedState.showControls,
      );
      yield _lastLoadedState;
    }
  }

  Stream<VideoPlayerState> _mapControlsHiddenToState() async* {
    if (state is VideoPlayerSuccess) {
      _lastLoadedState = _lastLoadedState.copyWith(
          showControls: !_lastLoadedState.showControls);
      yield _lastLoadedState;
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
