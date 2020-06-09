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
        _controller = controller;

  final VideoPlayerController _controller;

  @override
  VideoPlayerState get initialState => _initialState();

  VideoPlayerState _initialState() {
    // _controller.addListener(() {
    //   add(Play());
    // });
    return VideoPlayerInitial(_controller);
  }

  @override
  Stream<VideoPlayerState> mapEventToState(
    VideoPlayerEvent event,
  ) async* {
    if (event is Play) {
      yield* _mapPlayToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Reset) {
      yield* _mapResetToState(event);
    } else if (event is Load) {
      yield* _mapLoadToState(event);
    } else if (event is Load) {
      yield* _mapLoadToState(event);
    } else if (event is SeekToRelativePosition) {
      yield* _mapSeekToRelativePositionToState(event);
    }
  }

  Stream<VideoPlayerState> _mapPlayToState(VideoPlayerEvent event) async* {
    if(!_controller.value.isPlaying) {
      _controller.play();
    }
    yield Playing(_controller);
  }

  Stream<VideoPlayerState> _mapPauseToState(VideoPlayerEvent event) async* {
    _controller.pause();
    yield Paused(_controller);
  }

  Stream<VideoPlayerState> _mapResetToState(VideoPlayerEvent event) async* {
    _controller.seekTo(Duration(seconds: 1));
    _controller.pause();
    yield Finished(_controller);
  }

  Stream<VideoPlayerState> _mapLoadToState(VideoPlayerEvent event) async* {
    yield Loading(_controller);
  }

  Stream<VideoPlayerState> _mapSeekToRelativePositionToState(
      VideoPlayerEvent event) async* {
    print(event);
    // double progressPercentage = event;
  }
}
