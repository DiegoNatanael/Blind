// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/object_detection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🎯 App starting...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Object Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: ObjectDetectionScreen(),
    );
  }
}