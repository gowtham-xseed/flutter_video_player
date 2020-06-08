import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FlutterVideoPlayer extends StatelessWidget {
  FlutterVideoPlayer({this.videoPlayerController});

  AspectRatio aspectRatio;
  VideoPlayerController videoPlayerController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: _calculateAspectRatio(context),
          child: _buildPlayerWithControls(videoPlayerController, context),
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
            child: AspectRatio(
              aspectRatio: _calculateAspectRatio(context),
              child: VideoPlayer(videoPlayerController),
            ),
          ),
          Container(),
          _buildControls(context),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
  ) {
    return Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
