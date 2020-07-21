import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/components/youtube_skin.dart';
import 'package:flutter_video_player/flutter_video_player.dart';
import 'package:video_player/video_player.dart';

typedef CustomSkinRenderer = Widget Function(
    FlutterVideoPlayerController flutterVideoPlayerController);

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer(this.videoPlayerController,
      {this.placeholderImage, this.customSkinRenderer});
  final VideoPlayerController videoPlayerController;
  final String placeholderImage;
  final CustomSkinRenderer customSkinRenderer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => VideoPlayerBloc(controller: videoPlayerController),
        child: FlutterVideoPlayerLayout(
            placeholderImage: placeholderImage,
            customSkinRenderer: customSkinRenderer));
  }
}

class FlutterVideoPlayerLayout extends StatelessWidget {
  FlutterVideoPlayerLayout({this.placeholderImage, this.customSkinRenderer});
  final String placeholderImage;
  final CustomSkinRenderer customSkinRenderer;

  FlutterVideoPlayerController flutterVideoPlayerController =
      FlutterVideoPlayerController();

  @override
  Widget build(BuildContext context) {
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

  BlocConsumer _buildPlayerWithControls() {
    return BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
        listener: (BuildContext context, VideoPlayerState state) {
      flutterVideoPlayerController.updateVideoPlayerStream(state);

      if (state is VideoPlayerSuccess && state.isFullScreenChanged == true) {
        if (state.isFullScreen) {
          _pushFullScreenWidget(
              context, BlocProvider.of<VideoPlayerBloc>(context));
        } else {
          _popFullScreenWidget(context);
        }
      }
    }, builder: (context, state) {
      if (state is VideoPlayerSuccess) {
        if (flutterVideoPlayerController != null &&
            !flutterVideoPlayerController.isInitialized) {
          flutterVideoPlayerController.initialize(
              state, BlocProvider.of<VideoPlayerBloc>(context));
        }

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
              Container(),
              Center(
                child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<VideoPlayerBloc>(context)
                          .add(VideoPlayerControlsToggled());
                    },
                    child: VideoPlayer(state.controller)),
              ),
              Container(),
              if (customSkinRenderer != null) ...{
                customSkinRenderer(flutterVideoPlayerController)
              } else ...{
                YoutubeSkin(flutterVideoPlayerController)
              }
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
      } else {
        return Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              image: placeholderImage != null
                  ? DecorationImage(
                      image: NetworkImage(placeholderImage), fit: BoxFit.cover)
                  : null),
          child: InkWell(
            onTap: () {
              BlocProvider.of<VideoPlayerBloc>(context)
                  .add(VideoPlayerToggled());
            },
            child: Image.asset(
              'assets/images/play_with_baground.png',
              height: 35,
              width: 35,
            ),
          ),
        );
      }
    });
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
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
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              body: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: FlutterVideoPlayerLayout(),
              ),
            ));
      },
    );
  }
}
