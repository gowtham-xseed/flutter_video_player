import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

class YoutubeSkin extends StatelessWidget {
  YoutubeSkin({Key key, @required this.videoPlayerBloc, this.theme = 'light'})
      : super();

  final String theme;
  final VideoPlayerBloc videoPlayerBloc;
  static const String DARK_THEME = 'dark';
  static const String LIGHT_THEME = 'light';

  static const Color iconColor = true ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('ontap');
      },
      child: Container(
        child: true
            ? Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 35,
                        color: iconColor,
                      ),
                      Spacer(),
                      Icon(
                        Icons.share,
                        color: iconColor,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.cast_connected,
                        color: iconColor,
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      GestureDetector(
                          onDoubleTap: () async {
                            // VideoPlayerValue value =
                            //     videoPlayerController.value;
                            // final end = value.duration.inMilliseconds;
                            // final skip =
                            //     (value.position - Duration(seconds: 15))
                            //         .inMilliseconds;
                            // videoPlayerController.seekTo(
                            //     Duration(milliseconds: math.min(skip, end)));

                            // double percentage = skip / end;

                            // setState(() {
                            //   sliderValue = percentage;
                            // });
                          },
                          child: Icon(
                            Icons.skip_previous,
                            size: 35,
                            color: iconColor,
                          )),
                      Spacer(),
                      BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                          builder: (context, state) {
                        return IconButton(
                          icon: Icon(
                            (videoPlayerBloc.state is Playing)
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 35,
                            color: iconColor,
                          ),
                          onPressed: () {
                            if (videoPlayerBloc.state is Playing) {
                              videoPlayerBloc.add(Pause());
                            } else {
                              videoPlayerBloc.add(Play());
                            }
                          },
                        );
                      }),
                      Spacer(),
                      GestureDetector(
                        onDoubleTap: () async {
                          // VideoPlayerValue value = videoPlayerController.value;
                          // final end = value.duration.inMilliseconds;
                          // final skip = (value.position + Duration(seconds: 15))
                          //     .inMilliseconds;
                          // videoPlayerController.seekTo(
                          //     Duration(milliseconds: math.min(skip, end)));

                          // double percentage = skip / end;

                          // setState(() {
                          //   sliderValue = percentage;
                          // });
                        },
                        child: Icon(
                          Icons.skip_next,
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
                        'sliderValue',
                        // sliderValue.toStringAsFixed(2),
                        style: TextStyle(color: iconColor),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.fullscreen,
                          color: iconColor,
                        ),
                        onPressed: () {
                          // chewieController.toggleFullScreen();
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
                          padding: const EdgeInsets.all(8.0),
                          child:
                              // MaterialVideoProgressBar(
                              //     videoPlayerController,
                              //     onDragStart: () {
                              //       // _hideTimer?.cancel();
                              //     },
                              //     onDragEnd: () {
                              //       // _startHideTimer();
                              //     },
                              //     colors: chewieController.cupertinoProgressColors ??
                              //         ChewieProgressColors(
                              //           playedColor: Color.fromARGB(
                              //             120,
                              //             255,
                              //             255,
                              //             255,
                              //           ),
                              //           handleColor: Color.fromARGB(
                              //             255,
                              //             255,
                              //             255,
                              //             255,
                              //           ),
                              //           bufferedColor: Color.fromARGB(
                              //             60,
                              //             255,
                              //             255,
                              //             255,
                              //           ),
                              //           backgroundColor: Color.fromARGB(
                              //             20,
                              //             255,
                              //             255,
                              //             255,
                              //           ),
                              //         ),
                              //   ),
                              // ),
                              Slider(
                            activeColor: Colors.red,
                            value: 0.0,
                            onChanged: (val) => {
                              // setState(() {
                              //   double currentPositionInMiliSeconds =
                              //       videoPlayerController
                              //               .value.duration.inMilliseconds *
                              //           val;
                              //   videoPlayerController.seekTo(Duration(
                              //       milliseconds:
                              //           currentPositionInMiliSeconds.round()));

                              //   sliderValue = val;
                              // })
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Text(showControls.toString(), style: TextStyle(color: iconColor),),
                ],
              )
            : null,
      ),
    );
  }
}