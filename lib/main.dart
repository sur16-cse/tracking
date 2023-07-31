import 'package:flutter/material.dart';
import 'package:sound_image_tracking/sound_tracking.dart';

import 'image_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoundDetector soundDetector =
      SoundDetector(threshold: 70, alertDuration: 5000);
  ImageDetector imageDetector = ImageDetector(counter: 3);

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
      appBar: AppBar(
        title: const Text('Image And Sound Detector'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AlertNotifier().isAlertingNotifier,
        builder: (context, isAlerting, _) {
          if (isAlerting) {
            // Show SnackBar when isAlerting is true
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert: Some alert message here!'),
                  // duration: Duration(seconds: 5),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: const Center(child: Text('Home Screen Content')),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5, top: 25, right: 5, bottom: 25),
                child: ElevatedButton(
                  onPressed: () {
                    imageDetector.startCapture();
                  },
                  child: const Text("Start Capture Image"),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: imageDetector.showImage(),
              ),
            ],
          );
        },
      ),
    );
  }
}
