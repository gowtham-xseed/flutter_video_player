import 'package:flutter/material.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/flutter_video_player.dart';
import 'package:flutter_video_player/utils/video_player.dart';

class YoutubeSkin extends StatelessWidget {
  YoutubeSkin(this.flutterVideoPlayerController, {Key key}) : super();
  final FlutterVideoPlayerController flutterVideoPlayerController;

  static const Color iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: flutterVideoPlayerController.videoPlayerStream.stream,
        builder: (context, streamData) {
          if (streamData != null && streamData.data != null) {
            VideoPlayerSuccess state = streamData.data;

            if (state.showControls) {
              return InkWell(
                onTap: () {
                  flutterVideoPlayerController.toggleControlsVisibily();
                },
                child: Container(
                    child: Column(
                  children: <Widget>[
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        GestureDetector(
                            onTap: () {
                              flutterVideoPlayerController.seekTo(state
                                      .controllerValue.position.inSeconds
                                      .toDouble() -
                                  10);
                            },
                            child: Icon(
                              Icons.fast_rewind,
                              size: 35,
                              color: iconColor,
                            )),
                        Spacer(),
                        IconButton(
                          key: Key("video-player-play-pause-button"),
                          icon: Icon(
                            (state.controllerValue.isPlaying)
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 35,
                            color: iconColor,
                          ),
                          onPressed: () {
                            flutterVideoPlayerController.toggle();
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            flutterVideoPlayerController.seekTo(state
                                    .controllerValue.position.inSeconds
                                    .toDouble() +
                                10);
                          },
                          child: Icon(
                            Icons.fast_forward,
                            size: 35,
                            color: iconColor,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          formatDuration(state.controllerValue.position) +
                              ' / ' +
                              formatDuration(state.controllerValue.duration),
                          style: TextStyle(color: iconColor),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.fullscreen,
                            color: iconColor,
                          ),
                          onPressed: () {
                            flutterVideoPlayerController.toggleFullScreen();
                          },
                        ),
                        SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 45, vertical: 8.0),
                            child: Container(
                              height: 20,
                              child: Slider(
                                activeColor: Colors.red,
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
                          ),
                        )
                      ],
                    ),
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
}
