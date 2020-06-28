part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerLoading extends VideoPlayerState {}

class VideoPlayerSuccess extends VideoPlayerState {
  VideoPlayerSuccess(this.controller, this.controllerValue);

  final VideoPlayerValue controllerValue;
  final VideoPlayerController controller;

  @override
  List<Object> get props => [controllerValue, controller];
}

class VideoPlayerFailure extends VideoPlayerState {
  @override
  List<Object> get props => [];
}
