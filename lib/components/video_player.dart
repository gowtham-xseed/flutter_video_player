import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/components/youtube_skin.dart';
import 'package:flutter_video_player/flutter_video_player.dart';
import 'package:flutter_video_player/video_player_state.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

typedef CustomSkinRenderer = Widget Function(
  FlutterVideoPlayerController flutterVideoPlayerController,
  VideoPlayerState state,
  String title,
);

typedef OnPlayerStateChanged = void Function(
  VideoPlayerStates event,
);

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer(
    Key key,
    this.videoPlayerController, {
    this.placeholderImage,
    this.customSkinRenderer,
    this.playOnlyInFullScreen,
    this.title,
    this.onPlayerStateChanged,
    this.onRetry,
  }) : super(key: key);
  final VideoPlayerController videoPlayerController;
  final String placeholderImage;
  final CustomSkinRenderer customSkinRenderer;
  final String title;
  final bool playOnlyInFullScreen;
  final OnPlayerStateChanged onPlayerStateChanged;
  final Function onRetry;

  Orientation deviceOrientationBeforeFullScreen;

  FlutterVideoPlayerController flutterVideoPlayerController =
      FlutterVideoPlayerController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => VideoPlayerBloc(
              videoPlayerController: videoPlayerController,
              playOnlyInFullScreen: playOnlyInFullScreen || false,
              onPlayerStateChanged: onPlayerStateChanged,
              onRetry: onRetry,
            ),
        child: Column(
          children: <Widget>[
            BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
                listenWhen: (previous, current) {
              if (playOnlyInFullScreen &&
                  previous is VideoPlayerSuccess &&
                  current is VideoPlayerFailure) {
                var isFullScreen =
                    (previous as VideoPlayerSuccess).isFullScreen;
                if (isFullScreen) {
                  _popFullScreenWidget(context);
                }
              }

              return true;
            }, listener: (BuildContext context, VideoPlayerState state) {
              flutterVideoPlayerController.updateVideoPlayerStream(state);

              if (state is VideoPlayerSuccess &&
                  state.isFullScreenChanged == true) {
                handleFullScreenChanged(context, state.isFullScreen);
              }
            }, builder: (context, state) {
              return SizedBox();
            }),
            FlutterVideoPlayerLayout(
                placeholderImage: placeholderImage,
                title: title,
                customSkinRenderer: customSkinRenderer,
                flutterVideoPlayerController: flutterVideoPlayerController)
          ],
        ));
  }

  void handleFullScreenChanged(BuildContext context, bool isFullScreenEnabled) {
    if (isFullScreenEnabled) {
      _pushFullScreenWidget(context, BlocProvider.of<VideoPlayerBloc>(context));
    } else {
      _popFullScreenWidget(context);
    }
  }

  _popFullScreenWidget(BuildContext context) {
    if (deviceOrientationBeforeFullScreen == Orientation.portrait) {
      SystemChrome.setPreferredOrientations(
          <DeviceOrientation>[DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }

    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<dynamic> _pushFullScreenWidget(
      BuildContext context, VideoPlayerBloc videoPlayerBloc) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(pageBuilder:
        (BuildContext builderContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
      return _defaultRoutePageBuilder(
          builderContext, animation, secondaryAnimation, videoPlayerBloc);
    });

    deviceOrientationBeforeFullScreen = MediaQuery.of(context).orientation;

    if (deviceOrientationBeforeFullScreen == Orientation.portrait) {
      if (Platform.isAndroid) {
        SystemChrome.setPreferredOrientations(
            <DeviceOrientation>[DeviceOrientation.landscapeLeft]);
      } else {
        SystemChrome.setPreferredOrientations(
            <DeviceOrientation>[DeviceOrientation.landscapeRight]);
      }
    }

    SystemChrome.setEnabledSystemUIOverlays([]);

    Wakelock.enable();
    await Navigator.of(context, rootNavigator: true).push(route);
    Wakelock.disable();
  }

  AnimatedWidget _defaultRoutePageBuilder(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      VideoPlayerBloc videoPlayerBloc) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return BlocProvider.value(
          value: videoPlayerBloc,
          child: WillPopScope(
            onWillPop: () {
              flutterVideoPlayerController.toggleFullScreen(
                enableFullScreen: false,
              );

              return Future.value(false);
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: FlutterVideoPlayerLayout(
                    placeholderImage: placeholderImage,
                    customSkinRenderer: customSkinRenderer,
                    flutterVideoPlayerController: flutterVideoPlayerController,
                    title: title),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FlutterVideoPlayerLayout extends StatelessWidget {
  FlutterVideoPlayerLayout(
      {this.placeholderImage,
      this.title,
      this.customSkinRenderer,
      this.flutterVideoPlayerController});
  final String placeholderImage;
  final String title;
  final CustomSkinRenderer customSkinRenderer;
  final FlutterVideoPlayerController flutterVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    if (!flutterVideoPlayerController.isInitialized) {
      flutterVideoPlayerController
          .initialize(BlocProvider.of<VideoPlayerBloc>(context));
    }
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: _calculateAspectRatio(context),
          child: _buildPlayerWithControls(),
        ),
      ),
    );
  }

  Widget _buildPlayerWithControls() {
    if (flutterVideoPlayerController != null) {
      return StreamBuilder(
          stream: flutterVideoPlayerController.videoPlayerStream.stream,
          builder: (context, streamData) {
            if (streamData != null && streamData.data != null) {
              VideoPlayerState state = streamData.data;

              if (state is VideoPlayerSuccess) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      // BlocProvider.of<VideoPlayerBloc>(context)
                      //     .add(VideoPlayerPanned(true));
                    } else {
                      // BlocProvider.of<VideoPlayerBloc>(context)
                      //     .add(VideoPlayerPanned(false));
                    }
                  },
                  child: Container(
                      child: Stack(
                    children: <Widget>[
                      Center(
                        child: GestureDetector(
                            onTap: () {
                              BlocProvider.of<VideoPlayerBloc>(context)
                                  .add(VideoPlayerControlsToggled());
                            },
                            child: VideoPlayer(state.controller)),
                      ),
                      Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: customSkinRenderer != null
                            ? customSkinRenderer(
                                flutterVideoPlayerController, state, title)
                            : YoutubeSkin(flutterVideoPlayerController, state),
                      )
                    ],
                  )),
                );
              } else if (state is VideoPlayerFailure) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          flutterVideoPlayerController.playPauseToggle();
                        },
                        icon:
                            Icon(Icons.warning, color: Colors.white, size: 40),
                      ),
                      InkWell(
                        onTap: () {
                          flutterVideoPlayerController.playPauseToggle();
                        },
                        child: Text(
                          '  Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return initialStateWidget();
              }
            } else {
              return Container(
                decoration: BoxDecoration(
                    image: placeholderImage != null
                        ? DecorationImage(
                            image: NetworkImage(placeholderImage),
                            fit: BoxFit.cover)
                        : null),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget initialStateWidget() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          image: placeholderImage != null
              ? DecorationImage(
                  image: NetworkImage(placeholderImage), fit: BoxFit.cover)
              : null),
      child: Center(
        child: InkWell(
          onTap: () {
            flutterVideoPlayerController.playPauseToggle();
          },
          child: Image.asset(
            'assets/images/play_with_background.png',
            height: 55,
          ),
        ),
      ),
    );
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
