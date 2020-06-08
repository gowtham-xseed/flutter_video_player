part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Start extends VideoPlayerEvent {
  final VideoPlayerController controller;

  Start({@required this.controller});

  @override
  String toString() => "Start { controller: $controller }";
}

class Play extends VideoPlayerEvent {}

class Pause extends VideoPlayerEvent {}

class Resume extends VideoPlayerEvent {}

class Reset extends VideoPlayerEvent {}
