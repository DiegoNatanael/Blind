// lib/screens/object_detection_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

import '../models/detection.dart';
import '../services/camera_service.dart';
import '../services/tts_service.dart';
import '../services/yolo_inference.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final CameraService _cameraService = CameraService();
  final TtsService _ttsService = TtsService();
  final YoloInference _yoloInference = YoloInference();

  String detectedObject = "No object detected";
  bool _isLoading = true;
  bool _isProcessing = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = "";
      });
    }

    try {
      await _ttsService.init();
      await _yoloInference.loadModel();
      await _cameraService.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _detectAndSpeak() async {
    if (_isProcessing) return;

    if (_yoloInference.interpreter == null) {
      await _ttsService.speak("Model not loaded. Detection unavailable.");
      return;
    }

    if (_cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
      await _ttsService.speak("Camera not ready");
      return;
    }

    setState(() {
      _isProcessing = true;
      detectedObject = "Processing...";
    });

    try {
      XFile image = await _cameraService.takePicture();
      Detection? closestDetection = await _yoloInference.runDetection(image.path);

      if (closestDetection != null) {
        String result = '${closestDetection.className} is ${closestDetection.distance.toStringAsFixed(1)} meters away';
        setState(() {
          detectedObject = result;
        });
        await _ttsService.speak(result);
      } else {
        setState(() {
          detectedObject = "No object detected";
        });
        await _ttsService.speak("No object detected");
      }

      try {
        await File(image.path).delete();
      } catch (e) {
        // print('⚠️ Could not delete temp file: $e');
      }

    } on CameraException {
      setState(() {
        detectedObject = "Camera error";
      });
      await _ttsService.speak("Camera error occurred");

      try {
        _cameraService.dispose();
        await _cameraService.initialize();
      } catch (reinitError) {
        // print('❌ Camera reinit failed: $reinitError');
      }

    } catch (e) {
      setState(() {
        detectedObject = "Error occurred";
      });
      await _ttsService.speak("Detection failed. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Object Detection'),
          backgroundColor: Colors.blue[700],
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: const CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 6,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Initializing app...',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please wait',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Object Detection'),
          backgroundColor: Colors.red[700],
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red), // ✅ Removed const
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Failed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _initializeApp,
                    icon: const Icon(Icons.refresh, size: 24), // ✅ Keep const
                    label: const Text('Retry Initialization', style: TextStyle(fontSize: 16)), // ✅ Keep const
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Object Detection')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('Camera not ready', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _initializeApp,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraService.controller!.value.previewSize!.height,
                  height: _cameraService.controller!.value.previewSize!.width,
                  child: CameraPreview(_cameraService.controller!),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Object Detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_yoloInference.interpreter == null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.white, size: 16), // ✅ Keep const
                            const SizedBox(width: 4),
                            const Text('No Model', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), // ✅ Keep const
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'DETECTED OBJECT',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detectedObject,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: (_yoloInference.interpreter != null && !_isProcessing) ? _detectAndSpeak : null,
                  icon: _isProcessing 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_enhance, size: 32), // ✅ Keep const
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Detect & Speak',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // ✅ Keep const
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: (_yoloInference.interpreter != null && !_isProcessing) ? Colors.blue[600] : Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _ttsService.stop();
    _yoloInference.interpreter?.close();
    super.dispose();
  }
}