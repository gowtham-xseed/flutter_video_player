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
      {this.isFullScreenChanged = false});

  final VideoPlayerValue controllerValue;
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isFullScreenChanged;
  final bool showControls;

  VideoPlayerSuccess copyWith({
    VideoPlayerValue controllerValue,
    VideoPlayerController controller,
    bool isFullScreen,
    bool isFullScreenChanged,
    bool showControls,
  }) =>
      VideoPlayerSuccess(
        controller ?? this.controller,
        controllerValue ?? this.controllerValue,
        isFullScreen ?? this.isFullScreen,
        showControls ?? this.showControls,
        isFullScreenChanged: isFullScreenChanged ?? false,
      );

  @override
  List<Object> get props => [
        controllerValue,
        controller,
        isFullScreen,
        isFullScreenChanged,
        showControls
      ];
}

class VideoPlayerFailure extends VideoPlayerState {
  @override
  List<Object> get props => [];
}
