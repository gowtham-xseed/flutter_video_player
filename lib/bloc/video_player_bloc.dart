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
  VideoPlayerState get initialState => VideoPlayerInitial(_controller);

  @override
  Stream<VideoPlayerState> mapEventToState(
    VideoPlayerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    }
  }

  @override
  Future<void> close() {
    // Stop Video player
    return super.close();
  }

  Stream<VideoPlayerState> _mapStartToState(VideoPlayerEvent event) async* {
    yield Running(_controller);
    _controller.play();
  }
}
