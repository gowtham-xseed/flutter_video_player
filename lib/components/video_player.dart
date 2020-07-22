import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/components/youtube_skin.dart';
import 'package:flutter_video_player/flutter_video_player.dart';
import 'package:video_player/video_player.dart';

typedef CustomSkinRenderer = Widget Function(
    FlutterVideoPlayerController flutterVideoPlayerController,
    VideoPlayerSuccess state);

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer(this.videoPlayerController,
      {this.placeholderImage,
      this.customSkinRenderer,
      this.playOnlyInFullScreen});
  final VideoPlayerController videoPlayerController;
  final String placeholderImage;
  final CustomSkinRenderer customSkinRenderer;
  final bool playOnlyInFullScreen;
  FlutterVideoPlayerController flutterVideoPlayerController =
      FlutterVideoPlayerController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => VideoPlayerBloc(
            videoPlayerController: videoPlayerController,
            playOnlyInFullScreen: playOnlyInFullScreen || false),
        child: Column(
          children: <Widget>[
            BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
                listener: (BuildContext context, VideoPlayerState state) {
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

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

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await Navigator.of(context, rootNavigator: true).push(route);
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
              flutterVideoPlayerController.toggle();
            },
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: FlutterVideoPlayerLayout(
                    placeholderImage: placeholderImage,
                    customSkinRenderer: customSkinRenderer,
                    flutterVideoPlayerController: flutterVideoPlayerController),
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
      this.customSkinRenderer,
      this.flutterVideoPlayerController});
  final String placeholderImage;
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
              VideoPlayerSuccess state = streamData.data;
              if (state is VideoPlayerSuccess) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0) {
                      BlocProvider.of<VideoPlayerBloc>(context)
                          .add(VideoPlayerPanned(true));
                    } else {
                      BlocProvider.of<VideoPlayerBloc>(context)
                          .add(VideoPlayerPanned(false));
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
                                flutterVideoPlayerController, state)
                            : YoutubeSkin(flutterVideoPlayerController, state),
                      )
                    ],
                  )),
                );
              } else if (state is VideoPlayerFailure) {
                return Container(
                  color: Colors.black,
                  child: IconButton(
                    icon: Icon(Icons.warning, color: Colors.white, size: 40),
                    onPressed: () {},
                  ),
                );
              }
            } else {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    image: placeholderImage != null
                        ? DecorationImage(
                            image: NetworkImage(placeholderImage),
                            fit: BoxFit.cover)
                        : null),
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<VideoPlayerBloc>(context)
                        .add(VideoPlayerToggled());
                  },
                  child: SizedBox(
                    height: 35,
                    child: Image.asset(
                      'assets/images/play_with_baground.png',
                      height: 35,
                    ),
                  ),
                ),
              );
            }
          });
    } else {
      return CircularProgressIndicator();
    }
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
