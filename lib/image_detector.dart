import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageDetector {
  CameraController? _cameraController;
  Timer? _timer;
  String? _latestImagePath; // Store the path of the latest image
  bool _isCapturing = false; // Flag to track capture in progress
  final int counter;

  ImageDetector({required this.counter});

  // ignore: prefer_final_fields
  ValueNotifier<String?> _latestImagePathNotifier =
      ValueNotifier<String?>(null);

  // ignore: prefer_final_fields
  ValueNotifier<int?> _counterTimer = ValueNotifier<int>(0);
  ValueNotifier<CameraController?> _cameraControllerNotifier =
      ValueNotifier<CameraController?>(null);
  // Future<void>loadCamera() async{
  //
  // }
  //

  Future<void> startCapture({
    ResolutionPreset resolution = ResolutionPreset.medium,
    int imageQuality = 90,
  }) async {
    _latestImagePathNotifier.value = null;
    _counterTimer.value = 0;
    try {
      if (_isCapturing) {
        // Already capturing, return immediately to avoid starting a new capture.
        return;
      }

      List<CameraDescription> cameras = await availableCameras();

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[1],
          resolution,
          enableAudio: true,
        );

        await _cameraController!.initialize();
        _cameraControllerNotifier.value = _cameraController;
        print("$_cameraController hello camera");
        if (!_isCapturing) {
          _isCapturing = true;

          int count = 1;
          _timer = Timer.periodic((const Duration(seconds: 1)), (seconds) {
            _counterTimer.value = count;
            showTimer();
            count++;

            if (count > counter) {
              captureImage(imageQuality);
              _timer?.cancel();
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing camera: $e");
      }
    }
  }

  void stopCapture() {
    _cameraController?.dispose();
  }

  Future<void> captureImage(int imageQuality) async {
    try {
      if (!_cameraController!.value.isInitialized) {
        if (kDebugMode) {
          print("Camera is not initialized.");
        }
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

        if (kDebugMode) {
          print("Image captured and saved in $_latestImagePath.");
        }
        // Notify listeners about the updated image path.
        _latestImagePathNotifier.value = _latestImagePath;

        _isCapturing = false; // Reset the flag after capturing is complete.
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing image: $e");
      }
      _isCapturing = false; // Reset the flag in case of an error too.
    }
  }

  Widget showTimer() {
    return ValueListenableBuilder<int?>(
      valueListenable: _counterTimer,
      builder: (context, countTimer, _) {
        return countTimer != 0
            ? Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                "$countTimer",
                style: const TextStyle(
                  fontSize: 100.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
            : const SizedBox();
      },
    );
  }

  // Function to display the latest captured image using the Flutter Image widget.
  Widget showImage() {
    return ValueListenableBuilder<String?>(
      valueListenable: _latestImagePathNotifier,
      builder: (context, latestImagePath, _) {
        if (latestImagePath == null) {
          // If there is no latest image, display the camera preview or return null.
          return ValueListenableBuilder<CameraController?>(
            valueListenable: _cameraControllerNotifier,
            builder: (context, cameraController, _) {
              if (cameraController == null) {
                return Center(child: Text("Loading Camera..."));
              }

              if (!cameraController.value.isInitialized) {
                // Wait for the camera initialization to complete before showing CameraPreview.
                return FutureBuilder<void>(
                  future: cameraController.initialize(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          Container(
                            height: 300,
                            width: 400,
                            child: CameraPreview(cameraController),
                          ),
                          Center(child: showTimer()), // Show the timer above the CameraPreview
                        ],
                      );
                    } else {
                      // While waiting for initialization, show a progress indicator.
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
              } else {
                // Camera is already initialized, show CameraPreview.
                return Stack(
                  children: [
                    Container(
                      height: 300,
                      width: 400,
                      child: CameraPreview(cameraController),
                    ),
                    showTimer(), // Show the timer above the CameraPreview
                  ],
                );
              }
            },
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
  ValueNotifier<String?> get latestImagePathNotifier =>
      _latestImagePathNotifier;

  ValueNotifier<int?> get counterTimer => _counterTimer;

  ValueNotifier<CameraController?> get cameraControllerNotifier =>
      _cameraControllerNotifier;
}
