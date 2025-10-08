// lib/services/camera_service.dart

import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  Future<void> initialize() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras found on this device');
    }

    if (controller != null) {
      await controller!.dispose();
      controller = null;
    }

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller!.initialize();

    if (!controller!.value.isInitialized) {
      throw Exception('Camera controller initialization returned false');
    }

    await controller!.setFlashMode(FlashMode.off);
    await controller!.setFocusMode(FocusMode.auto);
  }

  Future<XFile> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    return await controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}