import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/components/youtube_skin.dart';
import 'package:video_player/video_player.dart';

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer({this.videoPlayerController});
  final VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => VideoPlayerBloc(controller: videoPlayerController),
        child: FlutterVideoPlayerLayout());
  }
}

class FlutterVideoPlayerLayout extends StatelessWidget {
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
              YoutubeSkin()
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
          color: Colors.black,
          child: IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white, size: 60),
            onPressed: () {
              BlocProvider.of<VideoPlayerBloc>(context)
                  .add(VideoPlayerToggled());
            },
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
