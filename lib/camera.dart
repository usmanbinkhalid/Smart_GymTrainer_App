import 'package:Smart_Workouts/keypoints.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

typedef void Callback(List<dynamic> list);

class CameraScreen extends StatefulWidget {
  final List cameras;
  List<dynamic> _recognitions;
  CameraScreen(this.cameras);

  @override
  _CameraScreen createState() => _CameraScreen();
}

class _CameraScreen extends State<CameraScreen> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        controller.startImageStream((CameraImage img){
          if(!isDetecting){
            isDetecting = true;

            Tflite.runPoseNetOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 2,
            ).then((recognitions) {
              if(mounted){
                setState(() {
                  widget._recognitions = recognitions;
                });
              }
              isDetecting = false;
            });
          }
        });

      });
    }
  }



  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }



  //      B   U   I   L   D           M    E    T    H    O    D
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var previewH = screenSize.height;
    var previewW = screenSize.width;

    return Stack(
      children: [
        OverflowBox(
          maxHeight: screenSize.height,
          maxWidth: screenSize.width,
          child: CameraPreview(controller),
        ),
        Keypoints(widget._recognitions,previewH,previewW)
      ],
    );
  }
}










