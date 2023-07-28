import 'package:flutter/material.dart';
import 'package:tracking/image_detector.dart';
import 'package:tracking/sound_tracking.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SoundDetector soundDetector = SoundDetector(threshold: 70, alertDuration: 5000);
  ImageDetector imageDetector =ImageDetector();

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
        title: Text('Image And Sound Detector'),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: AlertNotifier().isAlertingNotifier,
        builder: (context, isAlerting, _) {
          print("main $isAlerting");
          if (isAlerting) {
            // Show SnackBar when isAlerting is true
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print("scaffold");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
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
                child: Center(child: Text('Home Screen Content')),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, top: 25, right: 5, bottom: 25),
                child: ElevatedButton(
                  onPressed: () {
                   imageDetector.startCapture();
                  },
                  child: Text("Start Capture Image"),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: imageDetector.showImage(),
              ),
            ],
          );
        },
      ),
    );
  }
}