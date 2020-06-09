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
    final VideoPlayerBloc videoPlayerBloc = context.bloc<VideoPlayerBloc>();

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: _calculateAspectRatio(context),
          child: _buildPlayerWithControls(videoPlayerBloc, context),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(
      VideoPlayerBloc videoPlayerBloc, BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        Container(),
        Center(
          child: VideoPlayer(videoPlayerBloc.state.controller),
        ),
        Container(),
        YoutubeSkin(videoPlayerBloc: videoPlayerBloc),
        Row(
          children: <Widget>[
            FlatButton(
                child: Text("Full Screen"),
                color: Colors.red,
                onPressed: () async {
                  await _pushFullScreenWidget(context, videoPlayerBloc);
                }),
            FlatButton(
                child: Text("Pop Full Screen"),
                color: Colors.red,
                onPressed: () async {
                  await _popFullScreenWidget(context);
                })
          ],
        ),

        // _buildControls(context,
        //     videoPlayerBloc: BlocProvider.of<VideoPlayerBloc>(context)),
      ],
    ));
  }

  Widget _buildControls(BuildContext context,
      {VideoPlayerBloc videoPlayerBloc}) {
    return Container(
        child: Column(
      children: <Widget>[
        BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
          return Text(
            'Test - ' + videoPlayerBloc.state.toString(),
            style: TextStyle(color: Colors.blue),
          );
        }),
        // Text(videoPlayerBloc.state.toString(), style: TextStyle(color: Colors.blue)),
        FlatButton(
          color: Colors.red,
          onPressed: () {
            videoPlayerBloc.add(Play());
          },
          child: Text("Play"),
        ),
        FlatButton(
          color: Colors.red,
          onPressed: () {
            videoPlayerBloc.add(Pause());
          },
          child: Text("PAUSE"),
        ),
        FlatButton(
          color: Colors.red,
          onPressed: () {
            videoPlayerBloc.add(Reset());
          },
          child: Text("Reset"),
        ),
      ],
    ));
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
        return BlocProvider(
            create: (context) =>
                VideoPlayerBloc(controller: videoPlayerBloc.state.controller),
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
