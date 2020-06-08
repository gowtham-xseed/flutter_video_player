import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:video_player/video_player.dart';

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer({this.videoPlayerController});
  final VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => VideoPlayerBloc(controller: videoPlayerController),
        child: FlutterVideoPlayerLayout(videoPlayerController: videoPlayerController));
  }
}

class FlutterVideoPlayerLayout extends StatelessWidget {
  // final VideoPlayerBloc videoPlayerBloc;
  // VideoPlayerBloc(){this.videoPlayerBloc};
  // TODO: Get it from block
  FlutterVideoPlayerLayout({this.videoPlayerController});
  final VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoPlayerBloc(controller: videoPlayerController),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: _calculateAspectRatio(context),
            child: _buildPlayerWithControls(videoPlayerController, context),
          ),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(
      VideoPlayerController videoPlayerController, BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        Container(),
        Center(
          child: VideoPlayer(videoPlayerController),
        ),
        Container(),
        _buildControls(context,
            videoPlayerBloc: BlocProvider.of<VideoPlayerBloc>(context)),
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
        FlatButton(
          color: Colors.red,
          onPressed: () {
            videoPlayerBloc.add(Start(controller: videoPlayerController));
          },
          child: Text("Play"),
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
}
