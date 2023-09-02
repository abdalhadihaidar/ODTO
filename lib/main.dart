import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home.dart';

// Define a function to initialize and run the Flutter app.
Future<void> main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Retrieve the list of available cameras
    final cameras = await availableCameras();
    runApp(MyApp(cameras));
  } on CameraException catch (e) {
    // Handle camera initialization error
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
}

// Define the main application widget.
class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  MyApp(this.cameras);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ODTO',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
    );
  }
}
