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
  VideoPlayerFullScreenToggled({this.enableFullScreen});
  final bool enableFullScreen;

  List<Object> get props => [enableFullScreen];
}

class VideoPlayerControlsToggled extends VideoPlayerEvent {
  VideoPlayerControlsToggled();

  List<Object> get props => [];
}

class VideoPlayerControlsHidden extends VideoPlayerEvent {
  VideoPlayerControlsHidden();

  List<Object> get props => [];
}

class VideoPlayerPanned extends VideoPlayerEvent {
  VideoPlayerPanned(this.isForwardPan);
  final bool isForwardPan;

  List<Object> get props => [];
}
