// lib/utils/distance_estimator.dart

import 'dart:math' as math;
import '../models/detection.dart';

double estimateDistance(double width, double height, int classId) {
  Map<String, double> averageSizes = {
    'person': 1.7,
    'car': 4.5,
    'chair': 0.8,
    'bottle': 0.25,
    'cup': 0.12,
    'laptop': 0.35,
    'cell phone': 0.15,
    'book': 0.25,
    'backpack': 0.45,
    'handbag': 0.35,
    'suitcase': 0.6,
    'dog': 0.5,
    'cat': 0.3,
    'tv': 1.0,
    'couch': 2.0,
    'dining table': 1.5,
    'bed': 2.0,
  };

  String className = COCO_CLASSES[classId]; // ✅ Now works
  double realSize = averageSizes[className] ?? 0.5;
  double apparentSizeRatio = width / 640.0;
  const double focalLengthFactor = 1.5; // ✅ Renamed to camelCase

  double distance = (realSize * focalLengthFactor) / math.max(apparentSizeRatio, 0.01);
  return distance.clamp(0.3, 10.0);
}

double calculateIoU(List<double> box1, List<double> box2) {
  double x1Min = box1[0] - box1[2] / 2;
  double y1Min = box1[1] - box1[3] / 2;
  double x1Max = box1[0] + box1[2] / 2;
  double y1Max = box1[1] + box1[3] / 2;

  double x2Min = box2[0] - box2[2] / 2;
  double y2Min = box2[1] - box2[3] / 2;
  double x2Max = box2[0] + box2[2] / 2;
  double y2Max = box2[1] + box2[3] / 2;

  double interXMin = math.max(x1Min, x2Min);
  double interYMin = math.max(y1Min, y2Min);
  double interXMax = math.min(x1Max, x2Max);
  double interYMax = math.min(y1Max, y2Max);

  double interWidth = math.max(0, interXMax - interXMin);
  double interHeight = math.max(0, interYMax - interYMin);
  double interArea = interWidth * interHeight;

  double box1Area = (x1Max - x1Min) * (y1Max - y1Min);
  double box2Area = (x2Max - x2Min) * (y2Max - y2Min);
  double unionArea = box1Area + box2Area - interArea;

  return interArea / math.max(unionArea, 1e-6);
}