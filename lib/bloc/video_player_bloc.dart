import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc(
      {@required this.videoPlayerController, this.playOnlyInFullScreen})
      : assert(videoPlayerController != null) {
    if (!videoPlayerController.value.initialized) {
      videoPlayerController.initialize();
    }

    videoPlayerController.addListener(controllerCallBackListener);
  }

  Timer _timer;
  final VideoPlayerController videoPlayerController;
  final bool playOnlyInFullScreen;

  void initialControlsTimer() {
    Timer(const Duration(seconds: 3), () {
      add(VideoPlayerControlsToggled());
    });
  }

  void controllerCallBackListener() {
    if (videoPlayerController.value.hasError) {
      add(VideoPlayerErrorOccured());
    } else {
      add(ProgresUpdated(videoPlayerController.value));
    }
  }

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
    bool _isFullScreenChanged = playOnlyInFullScreen;

    if (state is VideoPlayerSuccess) {
      bool isPlaying = videoPlayerController.value.isPlaying;
      if (isPlaying) {
        videoPlayerController.pause();
      } else {
        videoPlayerController.play();
      }

      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          playOnlyInFullScreen ? !isPlaying : currentState.isFullScreen,
          currentState.showControls,
          isFullScreenChanged: _isFullScreenChanged);
    } else if (state is VideoPlayerInitial) {
      initialControlsTimer();
      videoPlayerController.play();
      yield VideoPlayerSuccess(videoPlayerController,
          videoPlayerController.value, _isFullScreenChanged, true,
          isFullScreenChanged: _isFullScreenChanged);
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
      yield VideoPlayerSuccess(
          videoPlayerController,
          videoPlayerController.value,
          !currentState.isFullScreen,
          currentState.showControls,
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
