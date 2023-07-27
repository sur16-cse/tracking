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
  ImageDetector imageDetector = ImageDetector();

  @override
  void initState() {
    super.initState();
    // Start capturing images when the HomeScreen widget is initialized
    imageDetector.startCapture(interval: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    // Stop capturing images when the widget is disposed to avoid leaks
    imageDetector.stopCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your HomeScreen UI code goes here (if needed)
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detector'),
      ),
      body: Center(
        child: Text('Home Screen Content'),
      ),
    );
  }
}
