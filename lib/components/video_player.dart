import 'package:flutter/material.dart';
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
}
