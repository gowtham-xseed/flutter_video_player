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
        // expect(find.byType(GestureDetector), findsNWidgets(2));

        await tester.pumpAndSettle(const Duration(seconds: 5));
      });

      testWidgets('Widget Test - Video Player Success State - Button click',
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

        expect(
            find.byKey(Key("video-player-play-pause-button")), findsOneWidget);
        await tester.tap(find.byKey(Key("video-player-play-pause-button")));

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(Slider), findsOneWidget);

        await tester.pumpAndSettle(const Duration(seconds: 5));
      });

      testWidgets('Widget Test - VideoPlayerSeeked',
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
        videoPlayerBloc.add(VideoPlayerToggled());

        await tester.pump();
        Duration duration = controller.value.position;
        videoPlayerBloc.add(
            VideoPlayerSeeked(controller.value.duration.inSeconds.toDouble()));

        VideoPlayerState videoPlayerState = videoPlayerBloc.state;
        if (videoPlayerState is VideoPlayerSuccess) {
          int a = videoPlayerState.controller.value.position.inSeconds;
          print(a);
        }

        Duration newDuration = controller.value.position;
        Duration du = controller.value.duration;
        print(duration.inSeconds);
        print(newDuration.inSeconds);
        print(du.inSeconds);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      });
    });
  });
}
