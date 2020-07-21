part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerLoading extends VideoPlayerState {}

class VideoPlayerSuccess extends VideoPlayerState {
  VideoPlayerSuccess(this.controller, this.controllerValue, this.isFullScreen,
      this.showControls,
      {this.isFullScreenChanged});

  final VideoPlayerValue controllerValue;
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isFullScreenChanged;
  final bool showControls;

  @override
  List<Object> get props => [
        controllerValue,
        controller,
        isFullScreen,
        isFullScreenChanged,
        showControls
      ];

  String toString() =>
      'isFullScreen $isFullScreen isFullScreenChanged $isFullScreenChanged';
}

class VideoPlayerFailure extends VideoPlayerState {
  @override
  List<Object> get props => [];
}
