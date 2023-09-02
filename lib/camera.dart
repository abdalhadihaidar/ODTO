import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'dart:math' as math;
import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.isEmpty) {
      print('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) async {
          if (!isDetecting) {
            isDetecting = true;
            int startTime = DateTime.now().millisecondsSinceEpoch;
            if (widget.model == mobilenet) {
              // Load the MobileNet model
              tfl.Interpreter interpreter = await tfl.Interpreter.fromAsset('assets/mobilenet_v1_1.0_224.tflite');
              List<Object> bytesList = img.planes.map((plane) => plane.bytes).toList();
              var outputs = {'imageHeight': img.height, 'imageWidth': img.width, 'numResults': 2};
              interpreter.runForMultipleInputs(bytesList, outputs.cast<int, Object>());
              int endTime = DateTime.now().millisecondsSinceEpoch;
              print(outputs);
              print("Detection took ${endTime - startTime}");
              isDetecting = false;
              interpreter.close();
            }
            // Handle other model cases (posenet, yolo, ssd_mobilenet) here...
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight: screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth: screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
