import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';

class AlertNotifier {
  static final AlertNotifier _instance = AlertNotifier._internal();

  factory AlertNotifier() {
    return _instance;
  }

  AlertNotifier._internal();

  final ValueNotifier<bool> isAlertingNotifier = ValueNotifier<bool>(false);

  bool get isAlerting => isAlertingNotifier.value;

  set isAlerting(bool value) {
    isAlertingNotifier.value = value;
  }
}

class SoundDetector {
  SoundDetector({required this.threshold, required this.alertDuration});
  final double threshold;
  final int alertDuration;

  final AlertNotifier _alertNotifier = AlertNotifier();
  Timer? _alertTimeout;
  List<int> arr = [];

  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamSubscription<dynamic>? _permissionSubscription;

  // Add a timer to manage the throttle
  Timer? _throttleTimer;
  bool _isThrottling = false;

  void stopSoundDetection() {
    _noiseSubscription?.cancel();
    _permissionSubscription?.cancel();
    _alertTimeout?.cancel();
    // Cancel the throttle timer when stopping the sound detection
    _throttleTimer?.cancel();
  }

  void initializeSoundDetector() async {
    if (await Permission.microphone.request().isGranted) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      final noiseMeter = NoiseMeter();
      try {
        _noiseSubscription = noiseMeter.noise.listen((noiseReading) {
          // Call _processNoise with throttling
          _throttleProcessNoise(noiseReading);
        });
      } catch (e) {
        print("Error starting noise meter: $e");
      }
    } else {
      print("Microphone permission not granted.");
    }
  }

  void _throttleProcessNoise(NoiseReading noiseReading) {
    if (!_isThrottling) {
      // If not throttling, process the noise reading and start the throttle timer
      _processNoise(noiseReading);
      _startThrottleTimer();
    }
  }

  void _startThrottleTimer() {
    _isThrottling = true;
    _throttleTimer = Timer(Duration(seconds: 1), () {
      // After 1 second, reset the throttle flag
      _isThrottling = false;
    });
  }

  void _processNoise(NoiseReading noiseReading) {
    final averageVolume = noiseReading.meanDecibel;
    print(averageVolume);
    if (arr.length >= (alertDuration / 1000)) {
      arr.removeAt(0);
    }
    arr.add(averageVolume > threshold ? 1 : 0);

    int? sum = arr.reduce((value, element) => value + element);
    print(_alertNotifier.isAlerting);
    if (arr.length == (alertDuration / 1000) && sum == (alertDuration / 1000)) {
      _alertNotifier.isAlerting = true;
    } else {
      _alertNotifier.isAlerting = false;
    }
  }
}

