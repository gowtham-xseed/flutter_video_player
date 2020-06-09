import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_video_player/components/progress_bar_colors.dart';
import 'package:video_player/video_player.dart';

class ProgressBar extends StatelessWidget {
  ProgressBar(this.value,
      {ProgressColors colors,
      this.onDragEnd,
      this.onDragStart,
      this.onDragUpdate,
      this.onTapDown})
      : colors = colors ?? ProgressColors();

  final VideoPlayerValue value;
  final ProgressColors colors;
  final Function(DragStartDetails details) onDragStart;
  final Function(DragEndDetails details) onDragEnd;
  final Function(DragUpdateDetails details) onDragUpdate;
  final Function(TapDownDetails details) onTapDown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
              value,
              colors,
            ),
          ),
        ),
      ),
      onHorizontalDragStart: (DragStartDetails details) {
        this.onDragStart(details);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        this.onDragUpdate(details);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        this.onDragEnd(details);
      },
      onTapDown: (TapDownDetails details) {
        this.onTapDown(details);
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.colors);

  VideoPlayerValue value;
  ProgressColors colors;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      colors.backgroundPaint,
    );
    if (!value.initialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, size.height / 2),
            Offset(end, size.height / 2 + height),
          ),
          Radius.circular(4.0),
        ),
        colors.bufferedPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      colors.playedPaint,
    );
    canvas.drawCircle(
      Offset(playedPart, size.height / 2 + height / 2),
      height * 3,
      colors.handlePaint,
    );
  }
}
