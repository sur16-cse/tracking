import 'dart:convert';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageDetector {
  CameraController? _cameraController;
  Timer? _timer;
  String? _latestImagePath; // Store the path of the latest image
  bool _isCapturing = false; // Flag to track capture in progress

  Future<void> startCapture({
    Duration interval = const Duration(seconds: 1),
    ResolutionPreset resolution = ResolutionPreset.medium,
    int imageQuality = 90,
  }) async {
    try {
      List<CameraDescription> cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], resolution);
        await _cameraController!.initialize();

        _timer = Timer.periodic(interval, (timer) {
          if (!_isCapturing) {
            _isCapturing = true;
            captureImage(imageQuality);
          }
        });
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void stopCapture() {
    _timer?.cancel();
    _cameraController?.dispose();
  }

  Future<void> captureImage(int imageQuality) async {
    try {
      if (!_cameraController!.value.isInitialized) {
        print("Camera is not initialized.");
        return;
      }

      final XFile? imageFile = await _cameraController?.takePicture();

      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        final storageDir = await getExternalStorageDirectory();

        // If this is the first image, save it with a unique name.
        if (_latestImagePath == null) {
          final imageName = "image.jpg";
          _latestImagePath = path.join(storageDir!.path, imageName);
        }

        // Update the latest image file with the new image.
        await File(_latestImagePath!).writeAsBytes(imageBytes);

        print("Image captured and saved in $_latestImagePath.");

        _isCapturing = false; // Reset the flag after capturing is complete.
      }
    } catch (e) {
      print("Error capturing image: $e");
      _isCapturing = false; // Reset the flag in case of an error too.
    }
  }
}
