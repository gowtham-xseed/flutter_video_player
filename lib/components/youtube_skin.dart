import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';
import 'package:flutter_video_player/utils/video_player.dart';

class YoutubeSkin extends StatelessWidget {
  YoutubeSkin({Key key, this.theme = 'light'}) : super();

  final String theme;
  static const String DARK_THEME = 'dark';
  static const String LIGHT_THEME = 'light';

  static const Color iconColor = true ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    final VideoPlayerBloc videoPlayerBloc =
        BlocProvider.of<VideoPlayerBloc>(context);

    return BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        builder: (context, state) {
      if (state is VideoPlayerSuccess) {
        if (state.showControls) {
          return InkWell(
            onTap: () {
              BlocProvider.of<VideoPlayerBloc>(context)
                  .add(VideoPlayerControlsToggled());
            },
            child: Container(
                child: Column(
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
                        onTap: () {
                          videoPlayerBloc.add(VideoPlayerSeeked(state
                                  .controllerValue.position.inSeconds
                                  .toDouble() -
                              10));
                        },
                        child: Icon(
                          Icons.fast_rewind,
                          size: 35,
                          color: iconColor,
                        )),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        (state.controllerValue.isPlaying)
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 35,
                        color: iconColor,
                      ),
                      onPressed: () {
                        videoPlayerBloc.add(VideoPlayerToggled());
                      },
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        videoPlayerBloc.add(VideoPlayerSeeked(state
                                .controllerValue.position.inSeconds
                                .toDouble() +
                            10));
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
                        videoPlayerBloc.add(VideoPlayerFullScreenToggled());
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
                              videoPlayerBloc.add((VideoPlayerSeeked(value)));
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
          return Container(
            height: 0,
            width: 0,
          );
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
