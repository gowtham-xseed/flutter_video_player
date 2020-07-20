import 'dart:async';
import 'dart:math' as math;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:video_player/video_player.dart';

import '../controller.dart';

part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc({@required FlutterVideoPlayerController controller})
      : assert(controller != null),
        _flutterVideoPlayerController = controller {
    if (!_flutterVideoPlayerController
        .videoPlayerController.value.initialized) {
      _flutterVideoPlayerController.videoPlayerController.initialize();
    }
    _flutterVideoPlayerController.videoPlayerController
        .addListener(controllerCallBackListener);
  }
  Timer _timer;
  final FlutterVideoPlayerController _flutterVideoPlayerController;

  void initialControlsTimer() {
    Timer(const Duration(seconds: 3), () {
      add(VideoPlayerControlsToggled());
    });
  }

  void controllerCallBackListener() {
    if (_flutterVideoPlayerController.videoPlayerController.value.hasError) {
      add(VideoPlayerErrorOccured());
    } else {
      add(ProgresUpdated(
          _flutterVideoPlayerController.videoPlayerController.value));
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
    if (state is VideoPlayerSuccess) {
      if (_flutterVideoPlayerController.videoPlayerController.value.isPlaying) {
        _flutterVideoPlayerController.videoPlayerController.pause();
      } else {
        _flutterVideoPlayerController.videoPlayerController.play();
      }
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
          _flutterVideoPlayerController,
          _flutterVideoPlayerController.videoPlayerController.value,
          currentState.isFullScreen,
          currentState.showControls);
    } else if (state is VideoPlayerInitial) {
      initialControlsTimer();
      _flutterVideoPlayerController.videoPlayerController.play();
      yield VideoPlayerSuccess(
          _flutterVideoPlayerController,
          _flutterVideoPlayerController.videoPlayerController.value,
          false,
          true);
    }
  }

  Stream<VideoPlayerState> _mapProgresUpdatedToState(
      ProgresUpdated event) async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(_flutterVideoPlayerController, event.position,
          currentState.isFullScreen, currentState.showControls);
    }
  }

  Stream<VideoPlayerState> _mapSeekedToState(VideoPlayerSeeked event) async* {
    if (state is VideoPlayerSuccess) {
      _flutterVideoPlayerController.videoPlayerController
          .seekTo(Duration(seconds: event.position.toInt()));
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
          _flutterVideoPlayerController,
          _flutterVideoPlayerController.videoPlayerController.value,
          currentState.isFullScreen,
          currentState.showControls);
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
          _flutterVideoPlayerController,
          _flutterVideoPlayerController.videoPlayerController.value,
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
        _flutterVideoPlayerController,
        _flutterVideoPlayerController.videoPlayerController.value,
        currentState.isFullScreen,
        !currentState.showControls,
      );
    }
  }

  Stream<VideoPlayerState> _mapControlsHiddenToState() async* {
    if (state is VideoPlayerSuccess) {
      final currentState = (state as VideoPlayerSuccess);
      yield VideoPlayerSuccess(
        _flutterVideoPlayerController,
        _flutterVideoPlayerController.videoPlayerController.value,
        currentState.isFullScreen,
        false,
      );
    }
  }

  Stream<VideoPlayerState> _mapControlsPannedToState(
      VideoPlayerPanned event) async* {
    if (state is VideoPlayerSuccess) {
      final end = _flutterVideoPlayerController
          .videoPlayerController.value.duration.inMilliseconds;
      final skip = (_flutterVideoPlayerController
                  .videoPlayerController.value.position +
              Duration(seconds: event.isForwardPan ? .5.round() : -5.round()))
          .inMilliseconds;
      _flutterVideoPlayerController.videoPlayerController
          .seekTo(Duration(milliseconds: math.min(skip, end)));
    }
  }

  @override
  Future<void> close() {
    _flutterVideoPlayerController.videoPlayerController
        .removeListener(controllerCallBackListener);
    return super.close();
  }
}
