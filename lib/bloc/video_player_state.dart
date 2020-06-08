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

class Ready extends VideoPlayerState {
  const Ready(VideoPlayerController controller) : super(controller);

  @override
  String toString() => 'Ready { controller: $controller }';
}

class Paused extends VideoPlayerState {
  const Paused(VideoPlayerController controller) : super(controller);

  @override
  String toString() => 'Paused { controller: $controller }';
}

class Running extends VideoPlayerState {
  const Running(VideoPlayerController controller) : super(controller);

  @override
  String toString() => 'Running { controller: $controller }';
}

class Finished extends VideoPlayerState {
  const Finished(VideoPlayerController controller) : super(controller);
}
