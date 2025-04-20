import 'dart:async';
import 'package:flutter/material.dart';

class DeliveryStopwatch extends StatefulWidget {
  const DeliveryStopwatch({super.key});

  @override
  State<DeliveryStopwatch> createState() => _DeliveryStopwatchState();
}

class _DeliveryStopwatchState extends State<DeliveryStopwatch> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {});
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
    _timer.cancel();
  }

  void _resetStopwatch() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.reset();
  }

  String _formatElapsedTime() {
    final elapsed = _stopwatch.elapsed;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatElapsedTime(),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
              child: Text(_isRunning ? 'Stop' : 'Start'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _resetStopwatch,
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}