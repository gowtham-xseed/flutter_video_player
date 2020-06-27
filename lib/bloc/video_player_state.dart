part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerState extends Equatable {}

class VideoPlayerInitial extends VideoPlayerState {
  @override
  List<Object> get props => throw UnimplementedError();
}

class VideoPlayerLoading extends VideoPlayerState {
  @override
  List<Object> get props => throw UnimplementedError();
}

class VideoPlayerSuccess extends VideoPlayerState {
  VideoPlayerSuccess(this.controller, this.controllerValue);

  final VideoPlayerValue controllerValue;
  final VideoPlayerController controller;

  @override
  List<Object> get props => [controllerValue, controller];
}

class VideoPlayerFailure extends VideoPlayerState {
  @override
  List<Object> get props => throw UnimplementedError();
}
