part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Play extends VideoPlayerEvent {}

class Pause extends VideoPlayerEvent {}

class Resume extends VideoPlayerEvent {}

class Reset extends VideoPlayerEvent {}

class Load extends VideoPlayerEvent {}

class SeekToRelativePosition extends VideoPlayerEvent {
  SeekToRelativePosition(this.progressPercentage);
  final double progressPercentage;

  @override
  String toString() {
    return super.toString();
  }
}
