import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(milliseconds: 30), _updateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {});
    }
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
    });
  }

  void _stopStopwatch() {
    setState(() {
      _stopwatch.stop();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  void _lapStopwatch() {
    setState(() {
      _laps.add(_formatTime(_stopwatch.elapsed));
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Stopwatch', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff),
        iconTheme: IconThemeData(color: Colors.white), // Back button color
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StopwatchCircleWidget(
            elapsedTime: elapsed,
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stopwatch.isRunning ? Colors.red : Colors.white, // Red color for stop button, white for start button
                ),
                child: Text(
                  _stopwatch.isRunning ? 'Stop' : 'Start',
                  style: TextStyle(color: _stopwatch.isRunning ? Colors.white : Colors.black), // White text for stop button, black for start button
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetStopwatch,
                child: Text('Reset'),
              ),
              SizedBox(width: 20),
              if (_stopwatch.isRunning)
                ElevatedButton(
                  onPressed: _lapStopwatch,
                  child: Text('Lap'),
                ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Lap ${index + 1}: ${_laps[index]}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StopwatchCircleWidget extends StatelessWidget {
  final Duration elapsedTime;

  const StopwatchCircleWidget({
    Key? key,
    required this.elapsedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: CircleProgressPainterWidget(
                progress: elapsedTime.inSeconds % 60 / 60.0,
              ),
              size: Size(250, 250),
            ),
          ),
          Center(
            child: Text(
              '${elapsedTime.inMinutes.remainder(60)}:${elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainterWidget extends CustomPainter {
  final double progress;

  CircleProgressPainterWidget({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // White color for elapsed part
    paint.color = Colors.white;

    double radius = size.width / 2;
    double arcAngle = 2 * progress * pi;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(radius, radius),
        radius: radius - paint.strokeWidth / 2,
      ),
      -pi / 2,
      arcAngle,
      false,
      paint,
    );

    // Light Orange color for remaining part
    paint.color = Color(0xFFF26262A);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(radius, radius),
        radius: radius - paint.strokeWidth / 2,
      ),
      arcAngle - pi / 2,
      2 * pi * (1 - progress),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
