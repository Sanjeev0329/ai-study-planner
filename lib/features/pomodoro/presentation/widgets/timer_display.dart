import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../utils/time_helper.dart';
import '../../pomodoro_provider.dart';

class TimerDisplay extends StatelessWidget {
  final PomodoroState state;
  final Color color;
  const TimerDisplay({super.key, required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, height: 240,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox.expand(child: CustomPaint(painter: _ArcPainter(state.progress, color))),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(TimeHelper.formatTimer(state.secondsLeft),
              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700)),
          Text(state.mode == PomodoroMode.focus ? 'Focus' : 'Break',
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    canvas.drawCircle(center, radius,
        Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 10);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round);
  }

  @override bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
