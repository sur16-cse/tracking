# Sound And Image tracking
It is sound detector SDK and Image Capture with Camera Preview SDK

Image Detector SDK Functionalities:
- ask Camera Permission
- Camera Preview
- Show Countdown Timer
- Capture Image
- Save  Image to Application Folder
- Show Image

Sound Detector SDK Functionalities:
- ask Audio permission
- Listen Processing Noice
- Compare with Threshold 
- Give Alert if for threshold of that Noice continues for Alert Duration
- Stop Audio Processing if app close

Permissions Required to use this package:
- add this in android manifest
```
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" />
```

- example application is added to see how to use this package

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
