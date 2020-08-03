import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:test/test.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('VideoPlayerEvent', () {
    test('VideoPlayerToggled', () {
      expect(
        VideoPlayerToggled().toString(),
        'VideoPlayerToggled',
      );
    });

    test('VideoPlayerErrorOccured', () {
      expect(
        VideoPlayerErrorOccured().toString(),
        'VideoPlayerErrorOccured',
      );
    });

    test('ProgresUpdated', () {
      var position = VideoPlayerValue(duration: Duration(seconds: 0));
      expect(
        ProgresUpdated(position).toString(),
        'ProgresUpdated',
      );
    });

    test('VideoPlayerSeeked', () {
      expect(
        VideoPlayerSeeked(0.5).toString(),
        'VideoPlayerSeeked',
      );
    });

    test('VideoPlayerFullScreenToggled', () {
      expect(
        VideoPlayerFullScreenToggled().toString(),
        'VideoPlayerFullScreenToggled',
      );
    });

    test('VideoPlayerControlsToggled', () {
      expect(
        VideoPlayerControlsToggled().toString(),
        'VideoPlayerControlsToggled',
      );
    });

    test('VideoPlayerControlsHidden', () {
      expect(
        VideoPlayerControlsHidden().toString(),
        'VideoPlayerControlsHidden',
      );
    });

    test('VideoPlayerPanned', () {
      expect(
        VideoPlayerPanned(true).toString(),
        'VideoPlayerPanned',
      );
    });
  });
}
