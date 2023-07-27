import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundDetector extends StatefulWidget {
  final double threshold;
  final int alertDuration;

  SoundDetector({required this.threshold, required this.alertDuration});

  @override
  _SoundDetectorState createState() => _SoundDetectorState();
}

class _SoundDetectorState extends State<SoundDetector> {
  bool _isAlerting = false;
  Timer? _alertTimeout;
  late List<int> arr;

  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamSubscription<dynamic>? _permissionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSoundDetector();
    arr = [];
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _permissionSubscription?.cancel();
    _alertTimeout?.cancel();
    super.dispose();
  }

  void _initializeSoundDetector() async {
    if (await Permission.microphone.request().isGranted) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      final noiseMeter = NoiseMeter();
      try {
        _noiseSubscription = noiseMeter.noise.listen((noiseReading) {
          _processNoise(noiseReading);
        });
      } catch (e) {
        print("Error starting noise meter: $e");
      }
    } else {
      print("Microphone permission not granted.");
    }
  }

  //run after every 50 milliseconds approx
  void _processNoise(NoiseReading noiseReading) {
    final averageVolume = noiseReading.meanDecibel;

    if (arr.length >= (widget.alertDuration / 1000)) {
      arr.removeAt(0);
    }
    arr.add(averageVolume > widget.threshold ? 1 : 0);

    int? sum = arr.reduce((value, element) => value + element);
    if (arr.length == (widget.alertDuration / 1000) &&
        sum == (widget.alertDuration / 1000)) {
      setState(() {
        _isAlerting = true;
      });

    } else {
      setState(() {
        _isAlerting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Detector')),
      body: Container(
        color: _isAlerting ? Colors.red : Colors.green,
        child: Center(
          child: Text(
            _isAlerting
                ? 'Sound level exceeded the threshold for ${widget.alertDuration / 1000} seconds!'
                : 'Normal',
            style: const TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
