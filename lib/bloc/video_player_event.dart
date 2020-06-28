part of 'video_player_bloc.dart';

@immutable
abstract class VideoPlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class VideoPlayerToggled extends VideoPlayerEvent {
  @override
  List<Object> get props => [];
}

class VideoPlayerErrorOccured extends VideoPlayerEvent {
  @override
  List<Object> get props => [];
}

class ProgresUpdated extends VideoPlayerEvent {
  ProgresUpdated(this.position);

  final VideoPlayerValue position;
  List<Object> get props => [position];
}

class VideoPlayerSeeked extends VideoPlayerEvent {
  VideoPlayerSeeked(this.position);
  final double position;
  List<Object> get props => [position];
}

class VideoPlayerFullScreenToggled extends VideoPlayerEvent {
  VideoPlayerFullScreenToggled();

  List<Object> get props => [];
}
