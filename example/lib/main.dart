import 'package:flutter/services.dart';
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
    enablePortrait();

    super.initState();
    _controller = VideoPlayerController.network(
        'http://mirrors.standaloneinstaller.com/video-sample/page18-movie-4.m4v')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  void enablePortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Widget initialWidget(flutterVideoPlayerController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: InkWell(
        onTap: () {
          flutterVideoPlayerController.playPauseToggle();
        },
        child: Image.asset(
          'assets/images/play_with_background.png',
          height: 35,
        ),
      ),
    );
  }

  Widget customSkinRenderer(flutterVideoPlayerController, state, titile) {
    if (state is VideoPlayerSuccess) {
      if (!state.isFullScreen) {
        return initialWidget(flutterVideoPlayerController);
      } else if (state.showControls) {
        return InkWell(
          onTap: () {
            flutterVideoPlayerController.toggleControlsVisibily();
          },
          child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 18, left: 18),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          child:
                              Image.asset('assets/images/back.png', height: 16),
                          onTap: () {
                            flutterVideoPlayerController.toggleFullScreen(
                              enableFullScreen: false,
                            );
                          },
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Video Name',
                            style: TextStyle(fontSize: 14, color: Colors.white))
                      ],
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        child: Image.asset(
                          'assets/images/fast_rewind.png',
                          height: 30,
                        ),
                        onTap: () async {
                          flutterVideoPlayerController.seekTo(state
                                  .controllerValue.position.inSeconds
                                  .toDouble() -
                              10);
                        },
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        child: Image.asset(
                          state.controllerValue.isPlaying
                              ? 'assets/images/pause.png'
                              : 'assets/images/play.png',
                          height: 30,
                        ),
                        onTap: () {
                          flutterVideoPlayerController.playPauseToggle();
                        },
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        child: Image.asset(
                          'assets/images/fast_forward.png',
                          height: 30,
                        ),
                        onTap: () async {
                          flutterVideoPlayerController.seekTo(state
                                  .controllerValue.position.inSeconds
                                  .toDouble() +
                              10);
                        },
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 20,
                          child: Slider(
                            activeColor: Color(0xFF515151),
                            inactiveColor: Color(0xFFDEDEDE),
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
                        width: 15,
                      ),
                      Text(
                          formatDuration(state.controllerValue.position) +
                              ' / ' +
                              formatDuration(state.controllerValue.duration),
                          style: TextStyle(color: Colors.white, fontSize: 14)),
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
      return SizedBox(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Text('Prefix'),
              FlutterVideoPlayer(
                Key(''),
                _controller,
                customSkinRenderer: customSkinRenderer,
                playOnlyInFullScreen: true,
                onPlayerStateChanged: (event) {},
              ),
              Text('Suffix'),
            ],
          ),
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
