import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:test/test.dart';
import 'package:video_player/video_player.dart';

void main() {
  group('VideoPlayerState', () {
    test('VideoPlayerInitial', () {
      expect(
        VideoPlayerInitial().toString(),
        'VideoPlayerInitial',
      );
    });

    test('VideoPlayerLoading', () {
      expect(
        VideoPlayerLoading().toString(),
        'VideoPlayerLoading',
      );
    });

    test('VideoPlayerSuccess', () {
      VideoPlayerController controller = VideoPlayerController.network('');

      expect(
        VideoPlayerSuccess(controller, controller.value, false, false)
            .toString(),
        'VideoPlayerSuccess',
      );
    });
  });
}
