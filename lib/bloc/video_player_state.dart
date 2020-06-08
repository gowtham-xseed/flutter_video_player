part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerState extends Equatable {
  final VideoPlayerController controller;

  const VideoPlayerState(this.controller);

  @override
  List<Object> get props => [controller];
}

class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial(VideoPlayerController controller)
      : super(controller);
}

class Playing extends VideoPlayerState {
  Playing(VideoPlayerController controller) : super(controller);
}

class Paused extends VideoPlayerState {
  const Paused(VideoPlayerController controller) : super(controller);
}

class Loading extends VideoPlayerState {
  const Loading(VideoPlayerController controller) : super(controller);
}

class Finished extends VideoPlayerState {
  const Finished(VideoPlayerController controller) : super(controller);
}
