// lib/services/yolo_inference.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../models/detection.dart'; // 👈 Add this import
import '../utils/distance_estimator.dart' as utils; // 👈 Add this import

class YoloInference {
  Interpreter? interpreter;
  static const int INPUT_SIZE = 640;
  static const double CONFIDENCE_THRESHOLD = 0.25;
  static const double IOU_THRESHOLD = 0.45;

  Future<void> loadModel() async {
    var interpreterOptions = InterpreterOptions();
    interpreter = await Interpreter.fromAsset(
      'assets/models/yolo11n_float32.tflite',
      options: interpreterOptions,
    );
    interpreter!.allocateTensors();
  }

  Future<List<List<List<List<double>>>>> preprocessImage(img.Image image) async {
    img.Image resized = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);

    var inputTensor = List.generate(
      1,
      (_) => List.generate(
        INPUT_SIZE,
        (_) => List.generate(
          INPUT_SIZE,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < INPUT_SIZE; y++) {
      for (int x = 0; x < INPUT_SIZE; x++) {
        var pixel = resized.getPixel(x, y);
        inputTensor[0][y][x][0] = pixel.r / 255.0;
        inputTensor[0][y][x][1] = pixel.g / 255.0;
        inputTensor[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return inputTensor;
  }

  List<Detection> postProcessOutput(List output, int originalWidth, int originalHeight, List<int> outputShape) {
    List<Detection> detections = [];
    bool isTransposed = outputShape[1] > outputShape[2];

    int numPredictions;
    int numElements;

    if (isTransposed) {
      numPredictions = outputShape[1];
      numElements = outputShape[2];
    } else {
      numElements = outputShape[1];
      numPredictions = outputShape[2];
    }

    for (int i = 0; i < numPredictions; i++) {
      List<double> classScores = [];
      double cx, cy, w, h;

      if (isTransposed) {
        cx = output[0][i][0];
        cy = output[0][i][1];
        w = output[0][i][2];
        h = output[0][i][3];
        for (int c = 4; c < numElements; c++) {
          classScores.add(output[0][i][c]);
        }
      } else {
        cx = output[0][0][i];
        cy = output[0][1][i];
        w = output[0][2][i];
        h = output[0][3][i];
        for (int c = 4; c < numElements; c++) {
          classScores.add(output[0][c][i]);
        }
      }

      double maxConfidence = classScores.reduce((a, b) => math.max(a, b));
      if (maxConfidence < CONFIDENCE_THRESHOLD) continue;

      int classId = classScores.indexOf(maxConfidence);
      if (classId >= COCO_CLASSES.length) continue;

      double scaleX = originalWidth / INPUT_SIZE;
      double scaleY = originalHeight / INPUT_SIZE;

      cx *= scaleX;
      cy *= scaleY;
      w *= scaleX;
      h *= scaleY;

      double distance = utils.estimateDistance(w, h, classId); // ✅ Use from utils

      detections.add(Detection(
        className: COCO_CLASSES[classId],
        confidence: maxConfidence,
        bbox: [cx, cy, w, h],
        distance: distance,
      ));
    }

    return _applyNMS(detections);
  }

  List<Detection> _applyNMS(List<Detection> detections) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    List<Detection> keep = [];

    for (var detection in detections) {
      bool shouldKeep = true;
      for (var kept in keep) {
        double iou = utils.calculateIoU(detection.bbox, kept.bbox); // ✅ Use from utils
        if (iou > IOU_THRESHOLD) {
          shouldKeep = false;
          break;
        }
      }
      if (shouldKeep) keep.add(detection);
    }

    return keep;
  }

  Future<Detection?> runDetection(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Failed to decode image');

      var inputTensor = await preprocessImage(image);

      var outputShape = interpreter!.getOutputTensor(0).shape;
      var output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.filled(outputShape[2], 0.0),
        ),
      );

      interpreter!.run(inputTensor, output);

      List<Detection> detections = postProcessOutput(output, image.width, image.height, outputShape);

      if (detections.isEmpty) return null;

      detections.sort((a, b) => a.distance.compareTo(b.distance));
      return detections.first;
    } catch (e) {
      rethrow;
    }
  }
}