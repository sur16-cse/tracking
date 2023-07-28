import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageDetector {
  CameraController? _cameraController;
  // Timer? _timer;
  String? _latestImagePath; // Store the path of the latest image
  bool _isCapturing = false; // Flag to track capture in progres

  ValueNotifier<String?> _latestImagePathNotifier = ValueNotifier<String?>(null);

  Future<void> startCapture({
    // Duration interval = const Duration(seconds: 1),
    ResolutionPreset resolution = ResolutionPreset.medium,
    int imageQuality = 90,
  }) async {
    try {
      List<CameraDescription> cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[1], resolution,enableAudio: true,);
        await _cameraController!.initialize();

        // _timer = Timer.periodic(interval, (timer) {
          if (!_isCapturing) {
            _isCapturing = true;
            captureImage(imageQuality);
          }
        // });
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void stopCapture() {
    // _timer?.cancel();
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

        // Save the image with a unique name.
        final imageName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        _latestImagePath = path.join(storageDir!.path, imageName);

        // Update the latest image file with the new image.
        await File(_latestImagePath!).writeAsBytes(imageBytes);

        print("Image captured and saved in $_latestImagePath.");
        // Notify listeners about the updated image path.
        _latestImagePathNotifier.value = _latestImagePath;

        _isCapturing = false; // Reset the flag after capturing is complete.
      }
    } catch (e) {
      print("Error capturing image: $e");
      _isCapturing = false; // Reset the flag in case of an error too.
    }
  }


  // Function to display the latest captured image using the Flutter Image widget.
  Widget showImage() {
    print("showImage $_latestImagePath");
    return ValueListenableBuilder<String?>(
      valueListenable: _latestImagePathNotifier,
      builder: (context, latestImagePath, _) {
        if (latestImagePath == null) {
          // If there is no latest image, display a placeholder image or return null.
          return Image.network(
            // Provide an image URL or use some other widget to display an image.
            'https://via.placeholder.com/150',
            height: 150,
            width: 150,
          );
        } else {
          // If there is a latest image, display it using the Image widget.
          return Image.file(
            File(latestImagePath),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
  // Function to get the latest image path as a ValueNotifier.
  ValueNotifier<String?> get latestImagePathNotifier => _latestImagePathNotifier;
}
