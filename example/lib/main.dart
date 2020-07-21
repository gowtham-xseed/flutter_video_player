import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/flutter_video_player.dart';
import 'package:flutter_video_player/utils/video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'http://mirrors.standaloneinstaller.com/video-sample/page18-movie-4.m4v')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  Widget customSkinRenderer(flutterVideoPlayerController) {
    return StreamBuilder(
        stream: flutterVideoPlayerController.videoPlayerStream.stream,
        builder: (context, streamData) {
          if (streamData != null && streamData.data != null) {
            VideoPlayerSuccess state = streamData.data;

            if (true || state.showControls) {
              return InkWell(
                onTap: () {
                  flutterVideoPlayerController.toggleControlsVisibily();
                },
                child: Container(
                    child: Column(
                  children: <Widget>[
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 20,
                            child: Slider(
                              activeColor: Color(0xFF515151),
                              inactiveColor: Colors.white.withOpacity(0.5),
                              min: 0.0,
                              max: state.controllerValue.duration.inSeconds
                                  .toDouble(),
                              value: state.controllerValue.position.inSeconds
                                  .toDouble(),
                              onChanged: (double value) {
                                flutterVideoPlayerController.seekTo(value);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 30,
                        ),
                        InkWell(
                          onTap: () {
                            flutterVideoPlayerController.toggle();
                          },
                          child: Image.asset(
                            state.controllerValue.isPlaying
                                ? 'assets/images/pause.png'
                                : 'assets/images/play.png',
                            height: 15,
                            width: 15,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                            formatDuration(state.controllerValue.position) +
                                ' / ' +
                                formatDuration(state.controllerValue.duration),
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Spacer(),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                )),
              );
            } else {
              return SizedBox(height: 0, width: 0);
            }
          } else {
            return SizedBox(
                height: 50,
                width: 50,
                child: Center(child: CircularProgressIndicator()));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: FlutterVideoPlayer(_controller,
              customSkinRenderer: customSkinRenderer),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
