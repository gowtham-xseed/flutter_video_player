import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/components/youtube_skin.dart';
import 'package:video_player/video_player.dart';

import '../helpers/video_player_test_helpers.dart';

void main() {
  group("lib/components/youtube_skin.dart", () {
    FakeVideoPlayerPlatform fakeVideoPlayerPlatform;
    setUp(() {
      fakeVideoPlayerPlatform = FakeVideoPlayerPlatform();
    });

    group('initialize', () {
      test('asset', () async {
        final VideoPlayerController controller = VideoPlayerController.asset(
          'a.avi',
        );
        await controller.initialize();

        expect(
            fakeVideoPlayerPlatform.dataSourceDescriptions[0].asset, 'a.avi');
        expect(fakeVideoPlayerPlatform.dataSourceDescriptions[0].packageName,
            null);
      });

      testWidgets('Widget Test - Video Player Initial State',
          (WidgetTester tester) async {
        final FakeController controller = FakeController();
        Widget widget = YoutubeSkin();
        await tester.pumpWidget(MaterialApp(
          home: BlocProvider(
              create: (context) => VideoPlayerBloc(controller: controller),
              child: widget),
        ));

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Widget Test - Video Player Success State',
          (WidgetTester tester) async {
        final VideoPlayerController controller =
            VideoPlayerController.network('https://127.0.0.1');

        await controller.initialize();
        Widget widget = YoutubeSkin();
        VideoPlayerBloc videoPlayerBloc =
            VideoPlayerBloc(controller: controller);
        await tester.pumpWidget(BlocProvider(
            create: (context) => videoPlayerBloc,
            child: MaterialApp(home: widget)));

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        videoPlayerBloc.add(VideoPlayerToggled());

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(Slider), findsOneWidget);

        videoPlayerBloc.add(VideoPlayerToggled());

        await tester.pumpAndSettle(const Duration(seconds: 5));
      });
    });
  });
}
