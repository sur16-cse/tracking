import 'package:flutter/material.dart';
import 'package:tracking/sound_tracking.dart';
import 'image_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(), // Use HomeScreen widget as the home property
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoundDetector soundDetector = SoundDetector(threshold: 50, alertDuration: 5000);

  @override
  void initState() {
    super.initState();
    soundDetector.initializeSoundDetector();
  }

  @override
  void dispose() {
    soundDetector.stopSoundDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Image And Sound Detector'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AlertNotifier().isAlertingNotifier,
        builder: (context, isAlerting, _) {
          print("main $isAlerting");
          return Container(
            color: isAlerting ? Colors.red : Colors.white,
            child: Center(child: Text('Home Screen Content')),
          );
        },
      ),
    );
  }
}

